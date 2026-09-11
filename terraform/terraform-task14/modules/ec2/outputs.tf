output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "Public IP address of Twenty CRM EC2"
  value       = aws_instance.twenty_crm.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}