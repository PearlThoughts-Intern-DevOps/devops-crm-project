output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "twenty_crm_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.host_port}"
}