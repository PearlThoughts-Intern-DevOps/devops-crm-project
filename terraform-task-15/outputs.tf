output "ec2_public_ip" {
  description = "Public IP address of Twenty CRM EC2"
  value       = aws_instance.twenty_crm.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.twenty_crm.dns_name
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = aws_lb_target_group.twenty_crm.arn
}