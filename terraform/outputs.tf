output "vpc_id" {
  description = "ID of the default VPC being used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the subnet the EC2 instance is launched in"
  value       = data.aws_subnet.selected.id
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = aws_security_group.twenty_crm.id
}

output "instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for Twenty CRM images (use this to tag/push your local image)"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for Twenty CRM images"
  value       = aws_ecr_repository.twenty_crm.arn
}
output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to the EC2 instance"
  value       = var.iam_instance_profile
}
output "app_url" {
  description = "URL to access the Twenty CRM application once it is running"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}
