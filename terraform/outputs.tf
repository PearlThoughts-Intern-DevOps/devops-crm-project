output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = module.ec2.public_dns
}

output "s3_bucket_name" {
  description = "Name of the provisioned S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the provisioned S3 bucket"
  value       = module.s3.bucket_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the existing default subnet"
  value       = data.aws_subnet.selected.id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = module.ec2.ssh_command
}

output "crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}
