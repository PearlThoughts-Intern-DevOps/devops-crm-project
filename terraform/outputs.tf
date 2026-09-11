output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = var.vpc_id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "s3_bucket_name" {
  description = "Name of the Twenty CRM S3 storage bucket"
  value       = aws_s3_bucket.twenty_crm.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the Twenty CRM S3 storage bucket"
  value       = aws_s3_bucket.twenty_crm.arn
}