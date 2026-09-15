output "instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  description = "Twenty CRM EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}
