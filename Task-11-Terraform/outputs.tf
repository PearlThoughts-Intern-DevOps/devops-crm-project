output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected subnet"
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
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

output "ecr_repository_url" {
  description = "URL of the Twenty CRM ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}
