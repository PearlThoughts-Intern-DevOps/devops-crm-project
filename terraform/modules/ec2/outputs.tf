output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "private_ip" {
  description = "EC2 private IP address"
  value       = aws_instance.twenty_crm.private_ip
}

output "subnet_id" {
  description = "Subnet ID used by EC2"
  value       = aws_instance.twenty_crm.subnet_id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}
