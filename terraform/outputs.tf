output "ec2_instance_id" {
  value = aws_instance.task17.id
}

output "ec2_public_ip" {
  value = aws_instance.task17.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.task17.public_dns
}

output "security_group_id" {
  value = aws_security_group.task17.id
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = data.aws_subnets.default.ids[0]
}
