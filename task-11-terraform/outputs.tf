output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected default VPC subnet"
  value       = data.aws_subnets.default.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "URL of the Twenty CRM ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}
