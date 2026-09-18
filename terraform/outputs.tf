# ============================================================
# outputs.tf — Task 17
# ============================================================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP — paste into ansible/inventory/hosts.ini"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = module.ec2.public_dns
}

output "app_url" {
  description = "Twenty CRM URL (available after Ansible completes)"
  value       = "http://${module.ec2.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "SSH into EC2"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${module.ec2.public_ip}"
}

output "ansible_run_command" {
  description = "Run this after terraform apply"
  value       = "ansible-playbook -i inventory/hosts.ini site.yml"
}

output "update_inventory_command" {
  description = "Update inventory with the EC2 public IP"
  value       = "sed -i 's/REPLACE_WITH_EC2_IP/${module.ec2.public_ip}/' ../ansible/inventory/hosts.ini"
}
