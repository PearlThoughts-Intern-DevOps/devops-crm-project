# Task 14 – Terraform Modules

## Objective

Refactor the existing Terraform configuration into reusable and structured Terraform modules.

The Terraform configuration was divided into three reusable modules:

- EC2
- ECR
- S3

The modules are called from the root Terraform configuration using module inputs and outputs.

---

## Project Structure

```text
task-14-terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user-data.sh
    ├── ecr/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Terraform Modules

### 1. ECR Module

The ECR module is responsible for creating the Twenty CRM ECR repository.

The module accepts the repository name through a variable and provides the following outputs:

- ECR repository name
- ECR repository URL
- ECR repository ARN

The repository URL output is passed to the EC2 module.

---

### 2. S3 Module

The S3 module creates the storage bucket used by Twenty CRM.

The module includes:

- S3 bucket
- S3 Block Public Access
- S3 bucket versioning
- Server-side encryption using AES256

The bucket name and ARN are exposed through module outputs.

The bucket name output is passed to the EC2 module.

---

### 3. EC2 Module

The EC2 module provisions the Twenty CRM EC2 infrastructure.

It includes:

- EC2 security group
- SSH access on port 22
- Twenty CRM access on port 2020
- Ubuntu EC2 instance
- `t3.small` instance type
- 20 GiB gp3 root volume
- Existing IAM instance profile
- Docker and AWS CLI installation

The EC2 module receives the ECR repository URL and S3 bucket name as inputs.

---

## User Data

The EC2 startup configuration is maintained separately in:

```text
modules/ec2/user-data.sh
```

The script:

1. Updates the system.
2. Installs Docker and AWS CLI.
3. Starts and enables Docker.
4. Authenticates with Amazon ECR.
5. Pulls the Twenty CRM image from ECR.
6. Removes any existing Twenty CRM container.
7. Starts the Twenty CRM container.
8. Configures Twenty CRM to use the S3 bucket for storage.

The script receives the AWS region, ECR repository URL, and S3 bucket name through Terraform's `templatefile()` function.

---

## Root Terraform Configuration

The root `main.tf` calls the three reusable modules:

```text
Root Terraform Configuration
          |
          ├── ECR Module
          |
          ├── S3 Module
          |
          └── EC2 Module
```

The root configuration also uses data sources to retrieve the existing default VPC and its subnets.

The module outputs are used as inputs for the EC2 module:

```hcl
ecr_repository_url = module.ecr.repository_url
s3_bucket_name     = module.s3.bucket_name
```

This allows the modules to remain reusable while still communicating with each other.

---

## Variables

The root `variables.tf` defines configurable values such as:

- AWS region
- EC2 instance name
- EC2 instance type
- AMI ID
- EC2 key pair
- SSH CIDR
- CRM access CIDR
- IAM instance profile
- ECR repository name
- S3 bucket name

Environment-specific values are provided through:

```text
terraform.tfvars
```

The configuration uses:

```text
AWS Region: us-east-1
EC2 Type: t3.small
AMI: ami-0b6d9d3d33ba97d99
Key Pair: task-10-purva
IAM Instance Profile: EC2S3AccessRole
ECR Repository: twenty-crm
S3 Bucket: twenty-crm-task14-purva
```

---

## Terraform Validation

The following Terraform commands were executed as required:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

### Validation Result

```text
Success! The configuration is valid.
```

### Terraform Plan

```text
Plan: 7 to add, 0 to change, 0 to destroy.
```

The plan confirmed that Terraform recognized the resources defined through the EC2, ECR, and S3 modules.

---

## Conclusion

Task 14 was completed successfully by refactoring the Terraform configuration into reusable **EC2, ECR, and S3 modules**.

The modules use variables and outputs, are called from the root Terraform configuration, and environment-specific values are maintained through `terraform.tfvars`.

Terraform initialization, formatting, validation, and planning were completed successfully without running `terraform apply`.

### Thank you! 