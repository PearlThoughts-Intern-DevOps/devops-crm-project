output "instance_id" {
  description = "Task 17 EC2 instance ID"
  value       = aws_instance.prabhas_instance.id
}

output "public_ip" {
  description = "Task 17 EC2 public IP"
  value       = aws_instance.prabhas_instance.public_ip
}

output "private_key_path" {
  description = "Path to the generated private key"
  value       = local_sensitive_file.task17_private_key.filename
}
