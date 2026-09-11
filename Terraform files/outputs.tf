output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.ec2.public_dns
}

output "app_url" {
  description = "URL to reach Twenty CRM once the stack is up"
  value       = "http://${module.ec2.public_ip}:2020"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Twenty CRM storage"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
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

output "vpc_id" {
  description = "Default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used"
  value       = data.aws_subnet.selected.id
}
