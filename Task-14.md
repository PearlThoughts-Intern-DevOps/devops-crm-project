# Task 14: Terraform Modules

## Overview

Refactored the existing Terraform configuration into reusable Terraform modules for EC2, ECR, and S3.

## Objectives

* Create reusable Terraform modules.
* Separate EC2, ECR, and S3 resources into modules.
* Use `variables.tf` and `outputs.tf`.
* Call the modules from the root Terraform configuration.
* Use `terraform.tfvars` for configuration values.
* Validate the Terraform configuration using Terraform commands.

## Project Structure

```text
terraform/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh
    ├── ecr/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Modules

### EC2 Module

The EC2 module provisions the Twenty CRM EC2 infrastructure.

It includes:

* Existing default VPC and subnet lookup
* Existing IAM instance profile lookup
* Security group
* EC2 instance
* EC2 user data
* Configurable AMI, instance type, key pair and ports

The module outputs the EC2 instance ID, public IP, VPC ID and application URL.

### ECR Module

The ECR module creates the Amazon ECR repository used for the Twenty CRM Docker image.

It includes:

* ECR repository
* Mutable image tags
* Image scanning on push

The module outputs the repository URL and ARN.

### S3 Module

The S3 module creates the bucket used by the Twenty CRM configuration.

It includes:

* S3 bucket
* Versioning
* AES256 server-side encryption
* S3 Block Public Access

The module outputs the bucket name and ARN.

## Root Configuration

The root `main.tf` calls the three modules:

```hcl
module "s3" {
  source = "./modules/s3"
}

module "ecr" {
  source = "./modules/ecr"
}

module "ec2" {
  source = "./modules/ec2"
}
```

The root configuration passes required variables and module outputs between the modules.

For example, the S3 bucket name and ECR repository URL are passed to the EC2 module.

## Terraform Variables

The root `variables.tf` defines reusable inputs such as:

* AWS region
* EC2 instance type
* AMI ID
* Key pair
* Container and host ports
* Project name
* S3 bucket prefix
* IAM instance profile
* ECR repository name

The values are provided through `terraform.tfvars`.

## Terraform Outputs

The root `outputs.tf` provides:

* EC2 instance ID
* EC2 public IP
* Twenty CRM URL
* VPC ID
* S3 bucket name and ARN
* ECR repository URL and ARN

## Validation

The following commands were executed:

```bash
terraform init
```

Terraform initialized successfully and loaded the EC2, ECR and S3 modules.

```bash
terraform fmt -recursive
```

Terraform configuration was formatted, including the module directories.

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

```bash
terraform plan
```

The Terraform plan completed successfully:

```text
Plan: 7 to add, 0 to change, 0 to destroy.
```

## Conclusion

Task 14 refactored the Terraform configuration into reusable EC2, ECR and S3 modules. The configuration was formatted, initialized, validated and successfully planned.

