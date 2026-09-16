output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "target_group_id" {
  description = "The ID of the Target Group"
  value       = aws_lb_target_group.this.id
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "The name of the Target Group"
  value       = aws_lb_target_group.this.name
}

output "security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
