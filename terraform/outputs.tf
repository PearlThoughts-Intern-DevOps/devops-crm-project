output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.twenty_crm.dns_name
}

output "alb_url" {
  description = "URL to access Twenty CRM through the ALB"
  value       = "http://${aws_lb.twenty_crm.dns_name}"
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.twenty_crm.arn
}
