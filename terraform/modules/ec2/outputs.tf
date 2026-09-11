output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.crm_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.crm_server.public_dns
}

output "ssh_command" {
  description = "SSH command for the EC2 instance"
  value       = "ssh -i ${var.project_name}.pem ec2-user@${aws_instance.crm_server.public_ip}"
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.crm_sg.id
}
