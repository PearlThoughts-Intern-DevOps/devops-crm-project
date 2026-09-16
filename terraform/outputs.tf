output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnets used by the ALB"
  value       = slice(sort(data.aws_subnets.default.ids), 0, 2)
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.dns_name
}

output "alb_url" {
  description = "Twenty CRM URL through the ALB"
  value       = "http://${module.alb.dns_name}"
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = module.alb.target_group_arn
}
