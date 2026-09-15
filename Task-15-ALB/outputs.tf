output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
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
  description = "URL for accessing Twenty CRM through the ALB"
  value       = "http://${aws_lb.twenty_crm.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the Twenty CRM target group"
  value       = aws_lb_target_group.twenty_crm.arn
}

output "listener_arn" {
  description = "ARN of the ALB HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security group ID attached to the EC2 instance"
  value       = aws_security_group.ec2.id
}
