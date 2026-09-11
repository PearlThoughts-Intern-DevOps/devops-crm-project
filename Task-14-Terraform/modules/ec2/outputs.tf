output "instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  description = "Security group ID attached to the Twenty CRM EC2 instance"
  value       = aws_security_group.twenty_crm.id
}
