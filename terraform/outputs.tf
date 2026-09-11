output "vpc_id" {
  description = "Existing default VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "Subnet used by EC2"
  value       = module.vpc.subnet_ids[0]
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = module.ec2.public_dns
}

output "ec2_instance_type" {
  description = "EC2 instance type"
  value       = module.ec2.instance_type
}

output "ec2_ami_id" {
  description = "EC2 AMI ID"
  value       = module.ec2.ami_id
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile"
  value       = data.aws_iam_instance_profile.ec2_s3_access.name
}
