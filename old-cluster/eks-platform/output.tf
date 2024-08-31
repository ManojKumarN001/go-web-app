output "vpc_id" {
  value = module.vpc.vpc_id
}

output "publi_subnet_id" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_name" {
  value = module.eks.cluster_name
}

output "node_group_id" {
  value = module.eks.node_group_id
}