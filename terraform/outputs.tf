output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing default subnet ID"
  value       = data.aws_subnet.default.id
}

output "security_group_id" {
  description = "Existing Twenty CRM security group ID"
  value       = data.aws_security_group.twenty_crm.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:8080"
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 storage bucket"
  value       = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = aws_s3_bucket.twenty_storage.arn
}

output "ec2_iam_instance_profile" {
  description = "Existing EC2 IAM instance profile used for S3 access"
  value       = data.aws_iam_instance_profile.ec2_s3.name
}
