output "vpc_id" {
  description = "Default VPC ID"
  value       = module.ec2.vpc_id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "twenty_crm_ec2_url" {
  description = "Twenty CRM direct EC2 URL"
  value       = module.ec2.application_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "twenty_crm_alb_url" {
  description = "Twenty CRM URL through ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = module.alb.target_group_arn
}