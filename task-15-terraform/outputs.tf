output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
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

output "target_group_name" {
  description = "Name of the Twenty CRM target group"
  value       = aws_lb_target_group.twenty_crm.name
}

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}
