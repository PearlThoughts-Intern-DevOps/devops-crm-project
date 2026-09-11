output "instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}
