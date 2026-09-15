# Task 12: Terraform + AWS Infrastructure

## Objective

The objective of this task was to provision AWS infrastructure using Terraform and deploy Twenty CRM using an ECR Docker image and EC2 User Data.

## Infrastructure Created

Terraform was used to configure:

- AWS provider in `us-east-1`
- Existing default VPC
- Existing subnet
- Amazon ECR repository
- Security Group
- EC2 instance
- EC2 IAM instance profile
- Terraform variables and outputs

## AWS Configuration

- Region: `us-east-1`
- EC2 Instance Type: `t3.small`
- AMI: Amazon Linux 2023
- Root Volume: 20 GiB gp3
- VPC: Existing default VPC
- Subnet: Existing default subnet
- IAM Instance Profile: `EC2ECRPullRole`
- Application Port: `2020`
- SSH Port: `22`

No new VPC was created because the task required using the existing/default VPC and subnet.

## Terraform Project Structure

```text
terraform-task-12/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── user_data.sh
├── .gitignore
├── .terraform.lock.hcl
└── TASK-12.md