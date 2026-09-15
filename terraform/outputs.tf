

# =========================
# VPC OUTPUTS
# =========================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "Subnet ID used by EC2"
  value       = module.vpc.subnet_ids[0]
}


# =========================
# EC2 OUTPUTS
# =========================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.ec2.private_ip
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = module.ec2.public_dns
}

output "ec2_instance_type" {
  description = "EC2 instance type"
  value       = module.ec2.instance_type
}

output "ec2_ami_id" {
  description = "EC2 AMI ID"
  value       = module.ec2.ami_id
}


# =========================
# SECURITY GROUP OUTPUTS
# =========================

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2.security_group_id
}

output "security_group_name" {
  description = "Security group name"
  value       = module.ec2.security_group_name
}


output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_url" {
  value = module.alb.alb_url
}




