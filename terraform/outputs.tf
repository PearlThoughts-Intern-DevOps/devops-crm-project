output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet"
  value       = data.aws_subnets.default.ids[0]
}

output "security_group_id" {
  description = "ID of the Task 13 security group"
  value       = aws_security_group.twenty_crm.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "twenty_crm_url" {
  description = "Browser URL for Twenty CRM"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.twenty_port}"
}

output "s3_bucket_name" {
  description = "Name of the Terraform-created S3 bucket"
  value       = aws_s3_bucket.twenty_crm.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the Terraform-created S3 bucket"
  value       = aws_s3_bucket.twenty_crm.arn
}

output "iam_instance_profile" {
  description = "Provided IAM instance profile used by EC2"
  value       = data.aws_iam_instance_profile.ec2_s3_access.name
}

