output "vpc_id" {
  description = "Default VPC ID used by the deployment"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet selected from the default VPC"
  value       = data.aws_subnets.default_vpc.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance (the stable Elastic IP, not the ephemeral auto-assigned address)"
  value       = aws_eip.twenty.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the Twenty CRM EC2 instance"
  value       = module.ec2.private_ip
}

output "ec2_iam_instance_profile" {
  description = "Existing IAM instance profile attached to the EC2 instance"
  value       = data.aws_iam_instance_profile.s3_access.name
}

output "s3_bucket_name" {
  description = "S3 bucket used as Twenty CRM storage backend"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 storage bucket"
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
