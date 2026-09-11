output "vpc_id" {
  description = "Default VPC ID"
  value       = module.ec2.vpc_id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = module.ec2.public_ip
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = module.ec2.application_url
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}