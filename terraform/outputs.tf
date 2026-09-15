output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Selected subnet ID"
  value       = data.aws_subnet.selected.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "instance_public_dns" {
  description = "EC2 public DNS"
  value       = module.ec2.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2.security_group_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL to access Twenty CRM through the ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}