output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "ec2_subnet_id" {
  description = "Subnet ID used by the Twenty CRM EC2 instance"
  value       = data.aws_subnet.public.id
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

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "Twenty CRM URL through the Application Load Balancer"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = module.alb.target_group_arn
}

output "listener_arn" {
  description = "ALB HTTP listener ARN"
  value       = module.alb.listener_arn
}
