output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by EC2"
  value       = var.subnet_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.twenty.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.twenty.public_dns
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty.repository_url
}

output "twenty_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_instance.twenty.public_ip}:2020"
}