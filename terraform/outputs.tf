output "ecr_repository_url" {
  value = aws_ecr_repository.crm_repo.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.crm_instance.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.crm_instance.id
}

output "crm_app_url" {
  value = "http://${aws_instance.crm_instance.public_ip}:${var.app_port}"
}

output "private_key_pem" {
  value     = tls_private_key.crm_key.private_key_pem
  sensitive = true
}
