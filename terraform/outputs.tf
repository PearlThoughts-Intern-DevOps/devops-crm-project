output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "vpc_id" {
  description = "ID of the default VPC used"
  value       = data.aws_vpc.default.id
}
