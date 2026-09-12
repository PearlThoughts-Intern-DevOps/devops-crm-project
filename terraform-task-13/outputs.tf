output "vpc_id" {
  description = "ID of the existing VPC used by Twenty CRM"
  value       = data.aws_vpc.existing.id
}

output "subnet_id" {
  description = "ID of the existing subnet used by Twenty CRM"
  value       = data.aws_subnet.existing.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Twenty CRM storage"
  value       = aws_s3_bucket.twenty_crm.id
}

output "s3_bucket_arn" {
  description = "ARN of the Twenty CRM S3 bucket"
  value       = aws_s3_bucket.twenty_crm.arn
}

output "security_group_id" {
  description = "Security group ID attached to the Twenty CRM EC2 instance"
  value       = aws_security_group.twenty_crm.id
}