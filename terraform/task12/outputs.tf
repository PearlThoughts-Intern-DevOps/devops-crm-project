output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Default subnet ID used by EC2"
  value       = local.subnet_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty.repository_url
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP address of Twenty CRM EC2"
  value       = aws_instance.twenty.public_ip
}

output "twenty_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_instance.twenty.public_ip}:8080"
}
