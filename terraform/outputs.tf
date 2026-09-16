output "instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = module.ec2.public_ip
}

output "instance_public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = module.ec2.public_dns
}

output "application_url" {
  description = "Twenty CRM application URL"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}
