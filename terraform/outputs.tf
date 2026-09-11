output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = module.ec2.public_dns
}

output "s3_bucket_name" {
  description = "Name of the Twenty CRM S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the Twenty CRM S3 bucket"
  value       = module.s3.bucket_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}