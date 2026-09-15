output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = module.ec2.public_dns
}

output "vpc_id" {
  description = "ID of the existing default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the existing default subnet"
  value       = data.aws_subnet.selected.id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = module.ec2.ssh_command
}

output "crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = module.alb.alb_security_group_id
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = module.alb.target_group_arn
}