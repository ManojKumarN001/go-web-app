locals {
  org = "platofrm"
  env = "prod"
}

module "eks" {
  source = "../module"

  env                   = local.env
  cluster-name          = "${local.org}-${local.env}-eks-cluster}"
  cidr-block            = "10.16.0.0/16"
  vpc-name              = "${local.org}-${local.env}-vpc"
  igw-name              = "${local.org}-${local.env}-IGW"
  pub-subnet-count      = "2"
  pub-cidr-block        = ["10.16.0.0/20", "10.16.16.0/20"]
  pub-availability-zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
  pub-sub-name          = "${local.org}-${local.env}-public-subnet"
  pri-subnet-count      = "2"
  pri-cidr-block        = ["10.16.128.0/20", "10.16.144.0/20"]
  pri-availability-zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
  pri-sub-name          = "${local.org}-${local.env}-private-subnet"
  public-rt-name        = "${local.org}-${local.env}-public-subnet-route-table"
  private-rt-name       = "${local.org}-${local.env}-private-subnet-route-table"
  eip-name              = "${local.org}-${local.env}-elasticip-ngw"
  ngw-name              = "${local.org}-${local.env}-NAT"
  eks-sg                = "${local.org}-${local.env}-eks-sg"

  is_eks_role_enabled           = true
  is_eks_nodegroup_role_enabled = true
  ondemand_instance_types       = ["t3a.medium"]
  spot_instance_types           = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]
  desired_capacity_on_demand    = "1"
  min_capacity_on_demand        = "1"
  max_capacity_on_demand        = "5"
  desired_capacity_spot         = "1"
  min_capacity_spot             = "1"
  max_capacity_spot             = "10"
  is-eks-cluster-enabled        = true
  cluster-version               = "1.29"
  endpoint-private-access       = true
  endpoint-public-access        = true
  addons = [
    {
      name    = "vpc-cni",
      version = "v1.18.1-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.11.1-eksbuild.9"
    },
    {
      name    = "kube-proxy"
      version = "v1.29.3-eksbuild.2"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.30.0-eksbuild.1"
    }
  ]
}
