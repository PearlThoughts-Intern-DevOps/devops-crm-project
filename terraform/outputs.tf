output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet"
  value       = data.aws_subnets.default.ids[0]
}

output "security_group_id" {
  description = "ID of the Task 12 security group"
  value       = aws_security_group.twenty_crm.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "URL of the Twenty CRM ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "twenty_crm_url" {
  description = "Browser URL for Twenty CRM"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.twenty_port}"
}

output "iam_role_name" {
  description = "IAM role used by the EC2 instance"
  value       = aws_iam_role.ec2_ecr_pull.name
}

output "iam_instance_profile" {
  description = "IAM instance profile attached to the EC2 instance"
  value       = aws_iam_instance_profile.ec2_ecr_pull.name
}

