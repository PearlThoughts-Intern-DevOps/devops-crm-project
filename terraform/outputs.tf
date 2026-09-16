# ============================================================
# outputs.tf — Task 16
# ============================================================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2.public_ip
}

output "app_url" {
  description = "Access Twenty CRM directly"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "SSH into EC2"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${module.ec2.public_ip}"
}
