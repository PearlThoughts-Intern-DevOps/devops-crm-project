# output "instance_hostname" {
#   description = "Private DNS name of the EC2 instance."
#   value       = aws_instance.app_server.private_dns
# }

output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet selected for the EC2 instance"
  value       = data.aws_subnets.default_vpc.ids[0]
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.twenty_crm.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}