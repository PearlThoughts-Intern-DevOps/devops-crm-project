# Task 11 - Terraform AWS Infrastructure

This directory contains the Terraform configuration prepared for the AWS infrastructure required for the Twenty CRM application.

## Objective

The objective of this task is to prepare Infrastructure as Code (IaC) using Terraform for the following AWS resources:

- Existing/default VPC
- EC2 instance
- Amazon ECR repository

The configuration is designed to be reusable, configurable through variables, and easy to maintain.

## AWS Region

The default AWS region is:

`us-east-1`

The region is configurable through the `aws_region` variable.

## Project Structure

```text
terraform/
├── versions.tf
├── provider.tf
├── variables.tf
├── data.tf
├── security_group.tf
├── ec2.tf
├── ecr.tf
├── outputs.tf
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

## Terraform Files

### `versions.tf`

Defines the required Terraform version and AWS provider.

### `provider.tf`

Configures the AWS provider and applies common project tags.

### `variables.tf`

Defines configurable values such as AWS region, project name, EC2 instance type, key pair, SSH CIDR, and ECR repository name.

### `data.tf`

Retrieves the existing default VPC, default subnet, and latest Ubuntu 24.04 AMD64 AMI.

The default VPC is referenced instead of creating a new VPC.

### `security_group.tf`

Defines the EC2 security group with SSH access on port `22`, Twenty CRM access on port `8080`, and outbound traffic.

SSH access is configurable using the `allowed_ssh_cidr` variable.

### `ec2.tf`

Defines the Twenty CRM EC2 instance using Ubuntu 24.04, a configurable instance type, an existing key pair, the default VPC subnet, a security group, a public IP, and a 20 GB encrypted GP3 root volume.

### `ecr.tf`

Defines the Amazon ECR repository with immutable image tags, image scanning on push, and AES256 encryption.

### `outputs.tf`

Provides the VPC ID, subnet ID, EC2 instance ID, EC2 public IP, EC2 public DNS, ECR repository URL, and ECR repository ARN.

## Variables

The configurable values are defined in `variables.tf`.

An example values file is provided as `terraform.tfvars.example`.

Example:

```hcl
aws_region          = "us-east-1"
project_name        = "twenty-crm"
instance_type       = "t3.small"
key_name            = "YOUR_EXISTING_KEY_PAIR_NAME"
allowed_ssh_cidr    = "YOUR_PUBLIC_IP/32"
ecr_repository_name = "twenty-crm"
```

Environment-specific values should not be committed to Git.

## Terraform Workflow

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Format the configuration

```bash
terraform fmt -recursive
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Generate the Terraform Plan

```bash
terraform plan
```

`terraform plan` is used to review the changes Terraform would make to the AWS environment.

## Important

This task is for **Terraform preparation, validation, and planning only**.

The following command must **not** be executed for this task:

```bash
terraform apply
```

No AWS resources should be created or modified as part of Task 11.

## Security Considerations

- AWS credentials must not be stored in Terraform files.
- `terraform.tfvars` is excluded from Git.
- Terraform state files are excluded from Git.
- SSH access can be restricted using the `allowed_ssh_cidr` variable.
- The EC2 root volume is configured with encryption.
- ECR image scanning is enabled on push.
