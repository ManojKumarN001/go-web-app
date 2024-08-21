output "vpc_id" {
  value = aws_vpc.TF_vpc.id
}

output "subnets_id" {
  value = aws_subnet.pub_sub-1.id
}

output "subnet_ids" {
  value = aws_subnet.pub_sub-2.id
}


output "security_groups" {
  value = aws_security_group.TF_sec.id
}
 