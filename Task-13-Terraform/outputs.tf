output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Selected existing subnet ID"
  value       = data.aws_subnet.selected.id
}

output "s3_bucket_name" {
  description = "Terraform-created S3 bucket"
  value       = aws_s3_bucket.twenty_crm_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the Twenty CRM S3 bucket"
  value       = aws_s3_bucket.twenty_crm_storage.arn
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  value       = var.iam_instance_profile
}

output "twenty_crm_image" {
  description = "Twenty CRM Docker image"
  value       = var.docker_image
}