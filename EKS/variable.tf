variable "region" {
  type    = string
  default = "us-east-1"
}

variable "Environment" {
  type    = string
  default = "EKS-testing"

}

variable "names" {
  type    = string
  default = "EKS-Cluster-Testing"
}

# variable "availability_zone-1" {
#   type    = string
#   default = "us-east-1a"

# }

# variable "availability_zone-2" {
#   type    = string
#   default = "us-east-1b"

# }

variable "Name2" {
  type = string
  default = "EKS-nodeWS"
}

variable "instance_types" {
  type = string
  default = "t2.micro"
}

variable "node_group_names" {
  type = string
  default = "EKS-node-groups"
}

variable "capacity_types" {
  type = string
  default = "ON_DEMAND"
}

variable "disk_sizes" {
  type = number
  default = 100
}

variable "ec2_ssh_keys" {
  type = string
  default = "EKS-test"
}

variable "custome_ami_ids" {
  type = string
  default = "ami-0c0b74d29acd0cd97"
}