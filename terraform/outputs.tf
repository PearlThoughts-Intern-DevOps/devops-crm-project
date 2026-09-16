output "instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty.id
}

output "public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty.public_ip
}

output "application_url" {
  description = "Twenty CRM application URL"
  value       = "http://${aws_instance.twenty.public_ip}:3000"
}
