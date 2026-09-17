output "instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  description = "Public DNS of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty_crm.public_dns
}