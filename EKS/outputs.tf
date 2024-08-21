output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "Cluster_ID" {
  value = aws_eks_cluster.eks.id
}

output "node_group_name" {
  value = aws_eks_node_group.node-grp.cluster_name
}

output "worker_node_ID" {
  value = aws_instance.kubectl-server.id
}

output "IAM_role_access" {
  value = aws_iam_role.master.arn
}