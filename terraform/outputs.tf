output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.task17.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.task17.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.task17.public_dns
}

output "ssh_command" {
  description = "SSH command"
  value       = "ssh -i ${var.project_name}.pem ubuntu@${aws_instance.task17.public_ip}"
}

output "pem_file" {
  description = "Generated PEM file"
  value       = local_file.task17_pem.filename
}