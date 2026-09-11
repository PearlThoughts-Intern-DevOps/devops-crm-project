output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "EC2 subnet ID"
  value       = module.ec2.subnet_id
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = module.ec2.security_group_id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Twenty CRM public IP"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM public DNS"
  value       = module.ec2.public_dns
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${module.ec2.public_ip}:8080"
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 storage bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "ec2_iam_instance_profile" {
  description = "IAM instance profile used by EC2"
  value       = module.ec2.iam_instance_profile
}
