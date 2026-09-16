output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing subnet ID"
  value       = data.aws_subnet.public.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = module.ec2.public_dns
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  value       = data.aws_iam_instance_profile.ec2_s3.name
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ecr_repository_name" {
  description = "Twenty CRM ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "Twenty CRM ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "Twenty CRM ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${module.ec2.public_ip}:3000"
}
