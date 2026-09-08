output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by the EC2 instance"
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty EC2 instance"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP of the Twenty EC2 instance"
  value       = aws_instance.twenty.public_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.twenty.repository_url
}