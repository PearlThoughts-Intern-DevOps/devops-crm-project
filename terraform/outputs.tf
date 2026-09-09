output "vpc_id" {
  description = "Default VPC ID used by the deployment"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet selected from the default VPC"
  value       = data.aws_subnets.default_vpc.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.public_ip
}

output "ecr_repository_name" {
  description = "Amazon ECR repository name"
  value       = aws_ecr_repository.twenty.name
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = aws_ecr_repository.twenty.repository_url
}

output "ec2_iam_instance_profile" {
  description = "Existing IAM instance profile used by the EC2 instance"
  value       = data.aws_iam_instance_profile.ec2_ecr_profile.name
}
