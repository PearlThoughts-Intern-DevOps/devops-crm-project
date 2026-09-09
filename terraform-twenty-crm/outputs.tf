output "ecr_repository_url" {
  description = "URL of the ECR repository — use this to tag/push the Twenty CRM image"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.twenty_crm.arn
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance running Twenty CRM"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "app_url" {
  description = "URL where Twenty CRM should be reachable once it boots"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}

output "vpc_id" {
  description = "VPC ID used (existing/default)"
  value       = local.vpc_id
}

output "subnet_id" {
  description = "Subnet ID used (existing/default)"
  value       = local.subnet_id
}
