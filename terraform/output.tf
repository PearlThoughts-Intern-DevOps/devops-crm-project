output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by the EC2 instance"
  value       = data.aws_subnets.default.ids[0]
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.twenty_crm.name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
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

output "twenty_crm_url" {
  description = "URL for accessing Twenty CRM"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}