output "ec2_instance_id" {
  value = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  value = aws_instance.twenty_crm.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.twenty_crm.public_dns
}

output "app_url" {
  value = "http://${aws_instance.twenty_crm.public_ip}:${var.app_port}"
}
