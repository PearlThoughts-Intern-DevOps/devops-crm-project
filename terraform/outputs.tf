output "aws_region" {
  description = "AWS Region where resources are provisioned"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the default Subnet where the EC2 instance is launched"
  value       = data.aws_subnets.default.ids[0]
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = aws_security_group.twenty_crm.id
}

output "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  value       = aws_ecr_repository.twenty_crm.name
}

output "ecr_repository_url" {
  description = "URL of the Amazon ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "twenty_crm_url" {
  description = "URL to access the Twenty CRM application"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}
