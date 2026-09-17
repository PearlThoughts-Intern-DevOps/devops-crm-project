output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}

output "security_group_id" {
  description = "The security group ID assigned to the EC2 instance"
  value       = aws_security_group.twenty_crm_sg.id
}

output "key_name" {
  description = "The key pair name used for the instance"
  value       = aws_key_pair.task17_key.key_name
}

output "twenty_crm_url" {
  description = "The access URL for Twenty CRM application"
  value       = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ${var.public_key_path} ubuntu@${aws_instance.twenty_crm.public_ip}"
}

output "ansible_inventory_line" {
  description = "Formatted entry for Ansible inventory.ini"
  value       = "twenty-node-1 ansible_host=${aws_instance.twenty_crm.public_ip} ansible_user=ubuntu"
}
