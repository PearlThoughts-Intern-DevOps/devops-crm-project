output "vpc_id" {
  description = "The ID of the VPC being used"
  value       = data.aws_vpc.default.id
}

output "ec2_security_group_id" {
  description = "The ID of the security group attached to the EC2 instance"
  value       = aws_security_group.twenty_crm_sg.id
}

output "ec2_instance_id" {
  description = "The ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}
