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


provider "aws" {
  region = "us-east-1"
}
