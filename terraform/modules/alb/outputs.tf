output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.twenty_crm.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = aws_lb_target_group.twenty_crm.arn
}
