provider "aws" {
  alias  = "use1"
  region = "us-east-1"
} 


#--------------- data sources ------------------#

data "aws_availability_zones" "available" {}

#---------------------------- VPC ----------------------- #


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


module "eks" {
  source = "../../modules/eks"

  region           = "us-east-1"
  cluster_name     = "my-eks-cluster"
  subnet_ids       = ["subnet-12345678", "subnet-87654321"]
  instance_types   = ["t2.micro"]
  cluster_version  = "1.28"
  desired_capacity = 2
  max_size         = 3
  min_size         = 1
  tags = {
    "Environment" = "dev"
  }
  cluster_iam_policies = {
    "AmazonEKSClusterPolicy"         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    "AmazonEKSServicePolicy"         = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    "AmazonEKSVPCResourceController" = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
  node_group_iam_policies = {
    "AmazonEKSWorkerNodePolicy"          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "AmazonEKS_CNI_Policy"               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}


