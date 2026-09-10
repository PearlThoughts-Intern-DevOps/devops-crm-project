output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of Twenty CRM EC2"
  value       = aws_instance.twenty_crm.public_ip
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 bucket name"
  value       = aws_s3_bucket.twenty_crm.bucket
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = aws_s3_bucket.twenty_crm.arn
}

output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing subnet ID"
  value       = var.subnet_id
}