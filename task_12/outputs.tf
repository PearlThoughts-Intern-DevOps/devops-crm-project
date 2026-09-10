output "vpc_id" {
  description = "Existing default VPC ID"
  value       = var.vpc_id
}

output "subnet_id" {
  description = "Existing subnet ID"
  value       = var.subnet_id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "ecr_repository_url" {
  description = "Existing ECR repository URL"
  value       = data.aws_ecr_repository.twenty_crm.repository_url
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:3000"
}
