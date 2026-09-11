output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing default subnet used by EC2"
  value       = data.aws_subnets.default.ids[0]
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "twenty_crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}

output "s3_bucket_name" {
  description = "Terraform-created S3 bucket"
  value       = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  description = "Terraform-created S3 bucket ARN"
  value       = aws_s3_bucket.twenty_storage.arn
}
