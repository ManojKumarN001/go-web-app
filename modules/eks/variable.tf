variable "region" {
  description = "The AWS region to deploy the EKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for the EKS node group."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired capacity for the EKS node group."
  type        = number
}

variable "max_size" {
  description = "Maximum size for the EKS node group."
  type        = number
}

variable "min_size" {
  description = "Minimum size for the EKS node group."
  type        = number
}

variable "tags" {
  description = "Tags to apply to EKS resources."
  type        = map(string)
  default     = {}
}

variable "cluster_iam_policies" {
  description = "Map of IAM policies to attach to the EKS cluster role."
  type        = map(string)
}

variable "node_group_iam_policies" {
  description = "Map of IAM policies to attach to the EKS node group role."
  type        = map(string)
}

variable "cluster_version" {
  description = "mentione required kubernets version for eks"
}