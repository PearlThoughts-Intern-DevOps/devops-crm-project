output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address assigned to the instance"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "The public DNS name assigned to the instance"
  value       = aws_instance.this.public_dns
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "The ID of the security group created for the EC2 instance"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.this.arn
}
