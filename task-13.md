# Task 13: Twenty CRM + AWS S3 using Terraform

## Objective

Deploy Twenty CRM on AWS EC2 using Terraform and configure Amazon S3 as the storage backend.

## AWS Configuration

- Region: `us-east-1`
- VPC: Existing/default VPC
- Subnet: Existing subnet
- EC2 Instance Type: `t3.small`
- AMI: `ami-0b6d9d3d33ba97d99`
- IAM Instance Profile: `EC2S3AccessRole`
- New IAM users, roles, or policies were not created.

## Terraform Files

### provider.tf
Configures the AWS provider and Terraform version.

### variables.tf
Defines reusable variables such as AWS region, project name, instance type, VPC, subnet, and S3 bucket name.

### terraform.tfvars
Contains the values used for this deployment.

### main.tf
Creates the EC2 instance and configures Twenty CRM using EC2 user data.

The user data:
- Installs Docker and AWS CLI.
- Starts PostgreSQL.
- Starts Redis.
- Deploys Twenty CRM.
- Deploys the Twenty CRM worker.
- Configures Twenty CRM to use Amazon S3 for storage.

### s3.tf
Creates and configures the S3 bucket.

The S3 configuration includes:
- Block Public Access
- Versioning
- Server-side encryption using AES256
- Project and task tags

### outputs.tf
Provides important Terraform outputs such as:
- EC2 instance ID
- EC2 public IP
- S3 bucket name
- S3 bucket ARN
- VPC ID

## Twenty CRM Configuration

Twenty CRM was deployed using Docker.

The following containers were configured:

- Twenty CRM
- Twenty CRM Worker
- PostgreSQL
- Redis

Twenty CRM was configured with:

- `STORAGE_TYPE=s3`
- AWS region
- Terraform-created S3 bucket
- S3 endpoint

## Verification

The deployment was verified using Terraform, AWS CLI, and EC2 commands.

### Terraform

- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply`

Terraform apply completed successfully.

### EC2

The EC2 instance was verified successfully.

### Docker

All required containers were running:

- `twenty-crm`
- `twenty-worker`
- `twenty-postgres`
- `twenty-redis`

### Twenty CRM

Twenty CRM was accessed successfully and returned HTTP `200 OK`.

### IAM

The EC2 instance was verified to use the existing:

`EC2S3AccessRole`

### S3

The S3 bucket was verified for:

- Versioning enabled
- Block Public Access enabled
- AES256 encryption enabled
- EC2 access to the bucket
- Twenty CRM objects stored in the bucket

## Cleanup

After testing and verification, Terraform destroy was executed successfully.

All Terraform-managed resources created for this task were removed successfully.

## Result

Twenty CRM was successfully deployed on AWS EC2 using Terraform and configured with Amazon S3 as its storage backend.
