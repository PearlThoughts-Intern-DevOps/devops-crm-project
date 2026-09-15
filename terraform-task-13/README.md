# Task 13 - Twenty CRM + AWS S3 using Terraform

## Overview

This project deploys Twenty CRM on an AWS EC2 instance and configures Amazon S3 as the storage backend.

All AWS infrastructure is provisioned using Terraform.

## AWS Configuration

- Region: `us-east-1`
- VPC: Existing default VPC
- Subnet: Existing default subnet
- EC2 Instance Type: `t3.small`
- Approved AMI: `ami-0b6d9d3d33ba97d99`
- IAM Instance Profile: `EC2S3AccessRole`
- Storage: Amazon S3

## Infrastructure

Terraform provisions:

1. One EC2 instance
2. One security group
3. One S3 bucket
4. S3 Block Public Access
5. S3 versioning
6. S3 server-side encryption

The existing default VPC and subnet are used. No new VPC or subnet is created.

The existing `EC2S3AccessRole` IAM instance profile is attached to the EC2 instance.

## Terraform Commands

Initialize Terraform:

```bash
terraform init