############################################
# Outputs
############################################

output "vpc_id" {
  description = "ID of the default VPC used for deployment"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "IDs of the subnets available in the default VPC"
  value       = data.aws_subnets.default.ids
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = aws_security_group.app_sg.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository, used to push/pull the Twenty CRM image"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app_repo.arn
}
