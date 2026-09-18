output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Selected subnet ID"
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}