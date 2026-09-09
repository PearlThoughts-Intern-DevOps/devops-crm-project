output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by the EC2 instance"
  value       = data.aws_subnets.default.ids[0]
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "ecr_repository_name" {
  description = "Twenty CRM ECR repository name"
  value       = aws_ecr_repository.twenty_crm.name
}

output "ecr_repository_url" {
  description = "Twenty CRM ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_iam_role" {
  description = "Existing IAM instance profile used by EC2"
  value       = data.aws_iam_instance_profile.ec2_ecr_profile.name
}
