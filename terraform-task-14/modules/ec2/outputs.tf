output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}