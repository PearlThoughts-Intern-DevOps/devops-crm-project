output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.twenty.dns_name
}

output "twenty_crm_url" {
  description = "Twenty CRM URL"
  value       = "http://${aws_lb.twenty.dns_name}"
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.twenty.arn
}

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnets_used" {
  description = "Subnets used by ALB"
  value = [
    data.aws_subnets.default.ids[0],
    data.aws_subnets.default.ids[1]
  ]
}