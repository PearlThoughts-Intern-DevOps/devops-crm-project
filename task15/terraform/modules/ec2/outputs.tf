output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  description = "EC2 public DNS name"
  value       = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.twenty_crm.id
}
