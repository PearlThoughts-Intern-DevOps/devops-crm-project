output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.twenty.dns_name
}

output "alb_url" {
  description = "Twenty CRM URL through ALB"
  value       = "http://${aws_lb.twenty.dns_name}"
}

output "instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "instance_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty.public_ip
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.twenty.arn
}