output "alb_dns_name" {
  description = "DNS name of the AWS Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "twenty_crm_url" {
  description = "Public URL to access Twenty CRM through the ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = module.alb.target_group_arn
}

output "target_group_name" {
  description = "Name of the ALB Target Group"
  value       = module.alb.target_group_name
}

output "alb_security_group_id" {
  description = "ID of the ALB Security Group"
  value       = module.alb.security_group_id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 Security Group"
  value       = module.ec2.security_group_id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "health_check_path" {
  description = "Configured health check path for Twenty CRM"
  value       = var.health_check_path
}
