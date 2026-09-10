output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "ecr_repository_url" {
  description = "ECR repository URL for docker push"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "app_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}

output "docker_login_command" {
  description = "Command to authenticate Docker with ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.twenty_crm.repository_url}"
}

output "docker_tag_command" {
  description = "Command to tag image for ECR"
  value       = "docker tag shubham-singh-twenty-crm:latest ${aws_ecr_repository.twenty_crm.repository_url}:latest"
}

output "docker_push_command" {
  description = "Command to push image to ECR"
  value       = "docker push ${aws_ecr_repository.twenty_crm.repository_url}:latest"
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_instance.twenty_crm.public_ip}"
}
