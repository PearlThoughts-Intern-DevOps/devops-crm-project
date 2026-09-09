output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "app_url" {
  description = "URL to access Twenty CRM"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}

output "vpc_id" {
  description = "Default VPC used"
  value       = local.vpc_id
}

output "subnet_id" {
  description = "Subnet used"
  value       = data.aws_subnet.selected.id
}
