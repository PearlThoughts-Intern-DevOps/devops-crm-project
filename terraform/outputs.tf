output "vpc_id" {
  description = "ID of the existing default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected default subnet."
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance."
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = aws_instance.twenty.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance, if available."
  value       = aws_instance.twenty.public_dns
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance."
  value       = aws_security_group.twenty.id
}

output "ecr_repository_url" {
  description = "ECR repository URL used when tagging and pushing container images."
  value       = aws_ecr_repository.twenty.repository_url
}
