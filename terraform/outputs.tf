output "instance_id" {
  value = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  value = aws_instance.twenty_crm.public_ip
}

output "instance_public_dns" {
  value = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  value = aws_security_group.twenty_crm.id
}