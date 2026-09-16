# Task 15 - AWS Application Load Balancer

Deploys Twenty CRM on EC2 behind an AWS Application Load Balancer using Terraform.

Architecture:

Internet -> ALB -> Target Group -> EC2 -> Twenty CRM

Resources:
- Default VPC and two default-VPC subnets for the ALB
- EC2 t3.small
- ALB security group
- EC2 security group
- Application Load Balancer
- Target Group
- HTTP listener on port 80
- Twenty CRM health check on /healthz

Validation:
- terraform init
- terraform fmt
- terraform validate
- terraform plan
- terraform apply

After verification:
- terraform destroy
