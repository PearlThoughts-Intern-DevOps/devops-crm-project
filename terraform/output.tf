output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by EC2"
  value       = data.aws_subnets.default.ids[0]
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP of Twenty CRM server"
  value       = aws_instance.twenty.public_ip
}

output "twenty_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_instance.twenty.public_ip}:3000"
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 storage bucket"
  value       = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  description = "Twenty CRM S3 bucket ARN"
  value       = aws_s3_bucket.twenty_storage.arn
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  value       = var.iam_role_name
}