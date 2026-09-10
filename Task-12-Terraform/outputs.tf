output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the subnet selected for EC2"
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Terraform-created EC2 instance"
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
  description = "URL of the Twenty CRM ECR repository"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "ecr_image_uri" {
  description = "Full ECR image URI that EC2 will pull"
  value       = "${aws_ecr_repository.twenty_crm.repository_url}:${var.docker_image_tag}"
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  value       = var.iam_instance_profile
}