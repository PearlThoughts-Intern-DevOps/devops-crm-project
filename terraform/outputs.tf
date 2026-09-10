
output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.crm_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = aws_instance.crm_server.public_dns
}

output "s3_bucket_name" {
  description = "Name of the provisioned S3 bucket"
  value       = aws_s3_bucket.crm_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the provisioned S3 bucket"
  value       = aws_s3_bucket.crm_storage.arn
}

output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the existing default subnet"
  value       = data.aws_subnet.selected.id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${var.project_name}.pem ec2-user@${aws_instance.crm_server.public_ip}"
}

output "crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_instance.crm_server.public_ip}:${var.app_port}"
}