variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for the worker nodes"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS cluster API server"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS cluster API server"
  type        = bool
  default     = true
}

variable "cluster_iam_policies" {
  description = "List of IAM policies to attach to the EKS cluster role"
  type        = map(string)
}

variable "node_group_iam_policies" {
  description = "List of IAM policies to attach to the node group role"
  type        = map(string)
}

variable "cluster_security_group_ingress_cidrs" {
  description = "List of CIDR blocks for security group ingress"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}


# variable "coredns_version" {
#   description = "mention the suported vesrion of coredns of eks"
# }

variable "kube_proxy_version" {
  description = "mention the suported vesrion od kube proxy of eks"
}

variable "vpc_cni_version" {
   description = "mention the suported vesrion of vpc_cni of eks"
}