output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS of the instance"
  value       = aws_instance.this.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}