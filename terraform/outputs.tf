output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = module.vpc.vpc_id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the Twenty CRM EC2 instance"
  value       = module.ec2.public_dns
}

output "security_group_id" {
  description = "Security group ID attached to the Twenty CRM EC2 instance"
  value       = module.ec2.security_group_id
}

output "ecr_repository_name" {
  description = "Amazon ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "Amazon ECR repository ARN"
  value       = module.ecr.repository_arn
}
