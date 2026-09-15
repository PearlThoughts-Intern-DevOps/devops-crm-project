# ============================================================
# modules/ec2/outputs.tf
# ============================================================

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "EC2 public DNS hostname"
  value       = aws_instance.this.public_dns
}

output "private_ip" {
  description = "EC2 private IP address"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security Group ID attached to EC2"
  value       = aws_security_group.this.id
}

output "ami_id_used" {
  description = "Actual AMI ID used for this instance"
  value       = aws_instance.this.ami
}
