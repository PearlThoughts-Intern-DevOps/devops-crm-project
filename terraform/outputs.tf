output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Selected subnet ID"
  value       = data.aws_subnet.selected.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "instance_public_dns" {
  description = "EC2 public DNS"
  value       = module.ec2.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2.security_group_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "app_url" {
  description = "Application URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}