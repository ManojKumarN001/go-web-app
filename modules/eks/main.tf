provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.control_plane.id]
  }

  tags = merge(var.tags, { "Name" = "${var.name_prefix}/ControlPlane" })
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  version         = var.cluster_version

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = merge(var.tags, { "Name" = "${var.name_prefix}/NodeGroup" })
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  for_each   = var.cluster_iam_policies
  role       = aws_iam_role.eks_cluster.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks_node_group" {
  name               = "${var.cluster_name}-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_node_group" {
  for_each   = var.node_group_iam_policies
  role       = aws_iam_role.eks_node_group.name
  policy_arn = each.value
}

resource "aws_security_group" "control_plane" {
  vpc_id = var.vpc_id
  name   = "${var.cluster_name}-control-plane-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = var.cluster_security_group_ingress_cidrs
  }

  tags = merge(var.tags, { "Name" = "${var.name_prefix}/ControlPlaneSecurityGroup" })
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  addon_version = var.coredns_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version
  resolve_conflicts = "OVERWRITE"
}