output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "app_url" {
  description = "URL to reach Twenty CRM once the stack is up"
  value       = "http://${aws_instance.twenty_crm.public_ip}:2020"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Twenty CRM storage"
  value       = aws_s3_bucket.twenty_crm_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.twenty_crm_storage.arn
}

output "vpc_id" {
  description = "Default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used"
  value       = data.aws_subnet.selected.id
}

output "iam_instance_profile_used" {
  description = "Existing IAM instance profile attached to the instance"
  value       = var.existing_iam_role_name
}
