output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.twenty_alb.dns_name
}

output "instance_id" {
  description = "EC2 instance ID running Twenty CRM"
  value       = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.twenty_tg.arn
}