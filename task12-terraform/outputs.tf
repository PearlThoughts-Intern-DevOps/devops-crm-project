output "ecr_repository_url" {
  value = aws_ecr_repository.twenty_crm.repository_url
}

output "ec2_instance_id" {
  value = aws_instance.twenty_crm.id
}

output "ec2_public_ip" {
  value = aws_instance.twenty_crm.public_ip
}

output "twenty_crm_url" {
  value = "http://${aws_instance.twenty_crm.public_ip}:2020"
}
