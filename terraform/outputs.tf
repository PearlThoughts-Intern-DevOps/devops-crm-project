output "vpc_id" {
  description = "ID of the existing default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet."
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IPv4 address assigned to the EC2 instance."
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance, if available."
  value       = module.ec2.public_dns
}

output "twenty_url" {
  description = "Public HTTP URL for Twenty CRM through the ALB."
  value       = "http://${module.alb.dns_name}"
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance."
  value       = aws_security_group.twenty.id
}

output "key_pair_name" {
  description = "Name of the Terraform-managed EC2 key pair."
  value       = aws_key_pair.task15.key_name
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.load_balancer_arn
}

output "alb_target_group_arn" {
  description = "ARN of the Twenty CRM target group."
  value       = module.alb.target_group_arn
}

output "alb_security_group_id" {
  description = "ID of the security group attached to the ALB."
  value       = aws_security_group.alb.id
}

output "alb_subnet_ids" {
  description = "Default-VPC subnet IDs used by the ALB."
  value       = sort(data.aws_subnets.default.ids)
}