output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet used by EC2"
  value       = data.aws_subnets.default.ids[0]
}

output "key_name" {
  description = "Terraform-created EC2 key pair name"
  value       = aws_key_pair.prabhas.key_name
}

output "private_key_file" {
  description = "Local path to the generated private key"
  value       = local_sensitive_file.prabhas_private_key.filename
}

output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.prabhas_twenty.id
}

output "ec2_public_ip" {
  description = "Twenty CRM EC2 public IP"
  value       = aws_instance.prabhas_twenty.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.twenty.dns_name
}

output "alb_url" {
  description = "Twenty CRM URL through the ALB"
  value       = "http://${aws_lb.twenty.dns_name}"
}

output "target_group_arn" {
  description = "Twenty CRM target group ARN"
  value       = aws_lb_target_group.prabhas_twenty.arn
}
