output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.twenty_crm.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.twenty_crm.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.twenty_crm.private_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.twenty_crm.public_dns
}

output "instance_type" {
  description = "EC2 instance type"
  value       = aws_instance.twenty_crm.instance_type
}

output "ami_id" {
  description = "AMI ID"
  value       = aws_instance.twenty_crm.ami
}
