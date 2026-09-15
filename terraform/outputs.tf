# ============================================================
# outputs.tf — Task 15
# ============================================================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "Access Twenty CRM via ALB"
  value       = module.alb.alb_url
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.alb.target_group_arn
}

output "default_vpc_id" {
  description = "Default VPC ID used"
  value       = data.aws_vpc.default.id
}

output "ssh_command" {
  description = "SSH into EC2"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${module.ec2.public_ip}"
}
