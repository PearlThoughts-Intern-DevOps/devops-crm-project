output "vpc_id" {
  description = "ID of the Twenty CRM VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "URL of the Twenty CRM ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}
output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

