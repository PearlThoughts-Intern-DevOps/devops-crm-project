output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ansible_target.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.ansible_target.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.ansible_target.public_dns
}
