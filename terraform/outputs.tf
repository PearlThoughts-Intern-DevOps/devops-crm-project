output "vpc_id" {
  description = "ID of the existing default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the selected existing default subnet."
  value       = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IPv4 address assigned to the EC2 instance."
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "Public DNS hostname of the EC2 instance, if available."
  value       = module.ec2.public_dns
}

output "twenty_url" {
  description = "Public URL for Twenty CRM."
  value       = "http://${module.ec2.public_ip}:${var.application_port}"
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance."
  value       = aws_security_group.twenty.id
}

output "key_pair_name" {
  description = "Name of the Terraform-managed EC2 key pair."
  value       = aws_key_pair.task16.key_name
}