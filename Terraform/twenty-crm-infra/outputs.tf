output "vpc_id" {
  description = "ID of the default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the subnet used for the EC2 instance"
  value       = data.aws_subnet.selected.id
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = aws_security_group.twenty_crm_sg.id
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
  description = "URL of the ECR repository (used for docker push/pull)"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.twenty_crm.arn
}
