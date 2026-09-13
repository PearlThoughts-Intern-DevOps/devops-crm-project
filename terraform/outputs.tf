output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.twenty_crm.name
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing default subnet ID"
  value       = data.aws_subnets.default.ids[0]
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}
