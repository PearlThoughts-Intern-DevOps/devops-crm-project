output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance (not directly internet-reachable by design)"
  value       = aws_instance.twenty_crm.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB — this is how you access Twenty CRM"
  value       = aws_lb.twenty_crm.dns_name
}

output "app_url" {
  description = "URL to reach Twenty CRM through the ALB"
  value       = "http://${aws_lb.twenty_crm.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.twenty_crm.arn
}

output "vpc_id" {
  description = "Default VPC used"
  value       = data.aws_vpc.default.id
}

output "alb_subnet_ids" {
  description = "Subnets used by the ALB (one per AZ)"
  value       = local.alb_subnet_ids
}
