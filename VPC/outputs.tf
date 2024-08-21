output "vpc_id" {
  value = aws_vpc.TF_vpc.id
}

output "pub_subnet_id" {
  value = aws_subnet.pub_sub-1
}

output "prv_subnet_id" {
  value = aws_subnet.prv_sub-2
}


output "security_groups" {
  value = aws_security_group.TF_sec.id
}
 