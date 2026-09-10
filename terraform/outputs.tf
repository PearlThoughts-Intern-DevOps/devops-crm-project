output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.crm_server.public_ip
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.crm_server.id
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.crm_repo.repository_url
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.crm_server.public_ip}:3000"
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.crm_sg.id
}