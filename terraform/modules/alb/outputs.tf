output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.crm_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.crm_alb.arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = aws_lb_target_group.crm_tg.arn
}
