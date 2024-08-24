terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider

########################### TF workspace ######################################################


# terraform {
#   cloud {
#     organization = "Terraform_Infra_Automation"
#     workspaces {
#       name = "Kubernetes-Cluster-workspace"
#     }
#   }
# }

