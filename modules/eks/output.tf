output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "node_group_name" {
  description = "The name of the EKS node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "The version of the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_id" {
  value = aws_eks_node_group.this.id
}