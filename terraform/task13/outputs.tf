output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing default subnet used by EC2"
  value       = local.subnet_id
}

output "s3_bucket_name" {
  description = "Twenty CRM S3 storage bucket"
  value       = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the Twenty CRM S3 bucket"
  value       = aws_s3_bucket.twenty_storage.arn
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty-prabhas.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty-prabhas.public_ip
}

output "twenty_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty-prabhas.public_ip}:8080"
}
