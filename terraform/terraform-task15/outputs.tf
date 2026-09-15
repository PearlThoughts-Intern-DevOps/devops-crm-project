output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.twenty_crm.dns_name
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.twenty_crm.arn
}