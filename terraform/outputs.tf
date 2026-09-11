output "vpc_id" {
  description = "ID of the existing default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet."
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IPv4 address assigned to the EC2 instance."
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance, if available."
  value       = module.ec2.public_dns
}

output "twenty_url" {
  description = "HTTP URL for the Twenty CRM web application."
  value       = "http://${module.ec2.public_ip}:${var.application_port}"
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance."
  value       = aws_security_group.twenty.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository."
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository."
  value       = module.ecr.repository_arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket used by Twenty CRM."
  value       = module.s3.bucket_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used by Twenty CRM."
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used by Twenty CRM."
  value       = module.s3.bucket_arn
}

output "iam_instance_profile_name" {
  description = "Existing IAM instance profile attached to EC2; it is not managed by Terraform."
  value       = var.iam_instance_profile_name
}