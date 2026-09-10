output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing subnet ID"
  value       = data.aws_subnet.public.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  value       = data.aws_iam_instance_profile.ec2_s3.name
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 bucket name"
  value       = aws_s3_bucket.twenty_crm.bucket
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = aws_s3_bucket.twenty_crm.arn
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:3000"
}
