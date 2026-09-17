output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "instance_public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}
