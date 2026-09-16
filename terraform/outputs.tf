output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the existing default subnet"
  value       = data.aws_subnets.default.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance from the EC2 module"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "security_group_id" {
  description = "Security group ID from the EC2 module"
  value       = module.ec2.security_group_id
}

output "ecr_repository_name" {
  description = "ECR repository name from the ECR module"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL from the ECR module"
  value       = module.ecr.repository_url
}

output "s3_bucket_name" {
  description = "S3 bucket name from the S3 module"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN from the S3 module"
  value       = module.s3.bucket_arn
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile used by EC2"
  value       = data.aws_iam_instance_profile.ec2_s3_access.name
}

output "twenty_crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${module.ec2.public_ip}:${var.twenty_port}"
}

