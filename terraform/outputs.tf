output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.twenty.dns_name
}

output "alb_url" {
  description = "Twenty CRM URL through the Application Load Balancer"
  value       = "http://${aws_lb.twenty.dns_name}"
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.twenty.arn
}
