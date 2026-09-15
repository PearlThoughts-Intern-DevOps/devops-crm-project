# ============================================================
# modules/alb/outputs.tf — Task 15
# ============================================================

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Full URL to access Twenty CRM via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.main.arn
}
