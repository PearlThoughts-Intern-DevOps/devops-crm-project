output "alb_id" {
  description = "Application Load Balancer ID"
  value       = aws_lb.twenty_crm.id
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.twenty_crm.arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.twenty_crm.dns_name
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.twenty_crm.arn
}

output "listener_arn" {
  description = "ALB HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}
