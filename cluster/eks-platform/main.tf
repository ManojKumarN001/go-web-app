#-------------------------- Provider --------------------#

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
} 


#------------------------ terraform provider --------------#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


#------------------- Terrform cloud backend -------------------#


terraform {
  cloud {
    organization = "Terraform_Infra_Automation"
    workspaces {
      name = "Kubernetes-Cluster-workspace"
    }
  }
}

#----------------------- data sources ----------------------#

data "aws_availability_zones" "available" {}


#---------------------------- VPC -------------------------- #


module "vpc" {
  source = "../../modules/vpc"

  cidr_block         = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  name_prefix        = "test"
  tags = {
    "Environment" = "dev"
    "Project"     = "eks-project"
  }
}

#---------------------------- EKS -------------------------- #


module "eks" {
  source = "../../modules/eks"
  depends_on = [ module.vpc ]

  region                   = "us-east-1"
  cluster_name             = "demo-cluster"
  subnet_ids               = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  endpoint_private_access  = false
  endpoint_public_access   = true
  tags                     = {
    "Environment" = "dev"
    "Project"     = "eks-project"
  }
  name_prefix              = "my-project"
  instance_types           = ["t2.micro"]
  cluster_version          = "1.28"
  desired_capacity         = 2
  max_size                 = 3
  min_size                 = 1
  cluster_iam_policies     = {
    "AmazonEKSClusterPolicy"    = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    "AmazonEKSVPCResourceController" = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
  node_group_iam_policies  = {
    "AmazonEKSWorkerNodePolicy" = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  vpc_id                   = module.vpc.vpc_id
  cluster_security_group_ingress_cidrs = ["0.0.0.0/0"]
  coredns_version         = "v1.11.1-eksbuild.11"
  kube_proxy_version      = "v1.30.0-eksbuild.3"
  vpc_cni_version         = "v1.18.3-eksbuild.2"
}