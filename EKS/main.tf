terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  cloud {
    organization = "Terraform_Infra_Automation"
    workspaces {
      name = "Kubernetes-Cluster-workspace"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Retrieve remote state from VPC workspace
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "Terraform_Infra_Automation"
    workspaces = {
      name = "Kubernetes-VPC-workspace"
    }
  }
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.names
  role_arn = aws_iam_role.master.arn
  version  = "1.27"  # Specify the desired Kubernetes version

  vpc_config {
    subnet_ids = concat([
      data.terraform_remote_state.vpc.outputs.pub_subnet_id, 
      data.terraform_remote_state.vpc.outputs.prv_subnet_id
    ])
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

# Add-ons for EKS Cluster
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"
  addon_version = "v1.10.1-eksbuild.1" # Optional: Specify a version or use latest
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"
  addon_version = "v1.27.0-eksbuild.1" # Optional: Specify a version or use latest
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"
  addon_version = "v1.13.1-eksbuild.1" # Optional: Specify a version or use latest
  resolve_conflicts = "OVERWRITE"
}

# EC2 Instance for kubectl access
resource "aws_instance" "kubectl-server" {
  ami                         = var.custome_ami_ids
  key_name                    = var.ec2_ssh_keys
  instance_type               = var.instance_types
  associate_public_ip_address = true
  subnet_id                   = [data.terraform_remote_state.vpc.outputs.pub_subnet_id]
  vpc_security_group_ids      = data.terraform_remote_state.vpc.outputs.security_groups

  tags = {
    Name = var.Name2
  }
}

# EKS Node Group
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_names
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = concat(
    data.terraform_remote_state.vpc.outputs.subnets_id, 
    data.terraform_remote_state.vpc.outputs.subnet_ids
  )
  capacity_type   = var.capacity_types
  disk_size       = var.disk_sizes
  instance_types  = [var.instance_types]

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_keys
    source_security_group_ids = data.terraform_remote_state.vpc.outputs.security_groups
  }

  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# IAM Role for EKS Master
resource "aws_iam_role" "master" {
  name = "ed-eks-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Role Policy Attachments for EKS Master
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "worker" {
  name = "ed-eks-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Policy for Auto Scaling
resource "aws_iam_policy" "autoscaler" {
  name   = "ed-eks-autoscaler-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM Role Policy Attachments for EKS Worker Nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

# IAM Instance Profile for Worker Nodes
resource "aws_iam_instance_profile" "worker" {
  depends_on = [aws_iam_role.worker]
  name       = "ed-eks-worker-new-profile"
  role       = aws_iam_role.worker.name
}
