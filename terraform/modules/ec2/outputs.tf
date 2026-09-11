output "vpc_id" {
  description = "VPC ID associated with the EC2 subnet"
  value       = data.aws_subnet.default.vpc_id
}

output "subnet_id" {
  description = "EC2 subnet ID"
  value       = data.aws_subnet.default.id
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = data.aws_security_group.twenty_crm.id
}

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

output "iam_instance_profile" {
  description = "IAM instance profile used by EC2"
  value       = data.aws_iam_instance_profile.ec2_s3.name
}
