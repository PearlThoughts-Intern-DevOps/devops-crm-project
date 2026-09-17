output "instance_id" {
  description = "Task 17 EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "public_ip" {
  description = "Task 17 EC2 public IP"
  value       = aws_instance.twenty.public_ip
}

output "public_dns" {
  description = "Task 17 EC2 public DNS"
  value       = aws_instance.twenty.public_dns
}

output "subnet_id" {
  description = "Subnet used by the EC2"
  value       = aws_instance.twenty.subnet_id
}
