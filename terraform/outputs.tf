output "vpc_id" {
  description = "Default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet the instance was launched into"
  value       = data.aws_subnets.default_vpc.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP -- this is the value that goes into the Ansible inventory"
  value       = aws_instance.twenty.public_ip
}

output "app_url" {
  description = "URL to reach Twenty CRM once Ansible has deployed it"
  value       = "http://${aws_instance.twenty.public_ip}:${var.app_port}"
}

# Writes the Ansible inventory directly from Terraform's known public
# IP, so the handoff between the two tools is automatic rather than a
# manual copy-paste step that can go stale on every apply.
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  content = <<-INVENTORY
    [twenty_crm]
    twenty-server ansible_host=${aws_instance.twenty.public_ip}

    [twenty_crm:vars]
    ansible_user=ec2-user
    ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  INVENTORY
}
