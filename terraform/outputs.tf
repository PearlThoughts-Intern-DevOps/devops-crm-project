# ============================================================
# outputs.tf — Root module outputs
# ============================================================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS hostname"
  value       = module.ec2.public_dns
}

output "app_url" {
  description = "Twenty CRM application URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${module.ec2.public_ip}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for docker push"
  value       = module.ecr.repository_url
}

output "ecr_docker_login_command" {
  description = "Command to authenticate Docker with ECR"
  value       = module.ecr.docker_login_command
}

output "s3_bucket_name" {
  description = "S3 bucket name including random suffix"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "vpc_id" {
  description = "VPC ID created for this deployment"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "Public subnet 1 ID"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "Public subnet 2 ID"
  value       = aws_subnet.public_2.id
}

output "iam_instance_profile" {
  description = "Existing IAM instance profile used by EC2"
  value       = data.aws_iam_instance_profile.ec2_profile.name
}
