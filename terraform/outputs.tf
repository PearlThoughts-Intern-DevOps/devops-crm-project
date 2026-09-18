output "vpc_id" {
  description = "Default VPC ID"
  value       = module.ec2.vpc_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "twenty_crm_url" {
  description = "Twenty CRM direct EC2 URL"
  value       = module.ec2.application_url
}