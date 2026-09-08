

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}
