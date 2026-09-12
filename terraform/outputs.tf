output "aws_region" {
  description = "AWS Region where resources are provisioned"
  value       = var.aws_region
}

output "vpc_id" {
  description = "Default VPC ID used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet ID where the EC2 instance is located"
  value       = data.aws_subnets.default.ids[0]
}

output "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  value       = module.ec2.security_group_id
}

output "s3_bucket_name" {
  description = "Name of the provisioned S3 bucket for Twenty CRM storage"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the provisioned S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_bucket_id" {
  description = "ID of the provisioned S3 bucket"
  value       = module.s3.bucket_id
}

output "ecr_repository_name" {
  description = "Name of the provisioned ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the provisioned ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the provisioned ECR repository"
  value       = module.ecr.repository_arn
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_iam_instance_profile" {
  description = "IAM instance profile attached to the EC2 instance"
  value       = var.iam_instance_profile
}

output "twenty_crm_url_2020" {
  description = "URL to access Twenty CRM on port 2020"
  value       = "http://${module.ec2.public_ip}:2020"
}

output "twenty_crm_url_3000" {
  description = "URL to access Twenty CRM on port 3000"
  value       = "http://${module.ec2.public_ip}:3000"
}
