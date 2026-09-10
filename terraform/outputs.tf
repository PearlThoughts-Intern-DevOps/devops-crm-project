output "vpc_id" {
  description = "ID of the existing default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet."
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance."
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = aws_instance.twenty.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance, if available."
  value       = aws_instance.twenty.public_dns
}

output "twenty_url" {
  description = "HTTP URL for the Twenty CRM web application."
  value       = "http://${aws_instance.twenty.public_ip}:${var.application_port}"
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance."
  value       = aws_security_group.twenty.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used by Twenty CRM."
  value       = aws_s3_bucket.twenty_storage.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used by Twenty CRM."
  value       = aws_s3_bucket.twenty_storage.arn
}

output "iam_instance_profile_name" {
  description = "Existing IAM instance profile attached to EC2; it is not managed by Terraform."
  value       = var.iam_instance_profile_name
}
