output "instance_id" {
  value = aws_instance.twenty_crm.id
}

output "public_ip" {
  value = aws_instance.twenty_crm.public_ip
}

output "public_dns" {
  value = aws_instance.twenty_crm.public_dns
}
