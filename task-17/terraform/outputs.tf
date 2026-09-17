output "instance_id" {
  description = "ID of the Task 17 EC2 instance."
  value       = aws_instance.twenty.id
}

output "public_ip" {
  description = "Public IPv4 address used by Ansible."
  value       = aws_instance.twenty.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.twenty.public_dns
}

output "ssh_command" {
  description = "Command for connecting to the EC2 instance."
  value       = "ssh -i ${pathexpand(var.private_key_path)} ${var.ssh_user}@${aws_instance.twenty.public_ip}"
}

output "application_url" {
  description = "Public Twenty CRM URL."
  value       = "http://${aws_instance.twenty.public_ip}:${var.application_port}"
}