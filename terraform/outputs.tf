output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Existing default subnet used by EC2"
  value       = local.default_subnet_id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = module.ec2.public_dns
}

output "twenty_crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}

output "s3_bucket_name" {
  description = "S3 bucket used by Twenty CRM"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "iam_role_name" {
  description = "IAM role attached to EC2"
  value       = aws_iam_role.ec2_s3_access.name
}


output "alb_dns_name" {
  description = "DNS name of the Twenty CRM Application Load Balancer"
  value       = aws_lb.twenty_crm.dns_name
}

output "alb_url" {
  description = "URL to access Twenty CRM through the ALB"
  value       = "http://${aws_lb.twenty_crm.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = aws_lb_target_group.twenty_crm.arn
}
