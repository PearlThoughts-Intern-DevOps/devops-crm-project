# Task 14 - Terraform Modules

**Name:** Harish
**Task:** Terraform Modules
**Date:** 11 September 2026
**PR link:**
**Loom link:**

## Objective

Create reusable Terraform modules for EC2, S3, and ECR.

Separate infrastructure into modules to make the Terraform code reusable and easier to maintain.

Use variables, outputs, and terraform.tfvars to manage module inputs and values.

Call the EC2, S3, and ECR modules from the root Terraform configuration.

Validate the configuration using Terraform commands without applying the infrastructure.

## Work Completed

Created separate Terraform modules for:

- EC2
- S3
- ECR

Each module contains:

- main.tf
- variables.tf
- outputs.tf

The root Terraform configuration calls all three modules.

Added terraform.tfvars to provide the required infrastructure values.

Used module outputs and inputs to pass the S3 bucket name to the EC2 module.

Added moved blocks to migrate the existing Task 13 Terraform resource addresses into the new module structure.

## Terraform Validation

The following commands were executed successfully:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
Terraform plan completed successfully.

No terraform apply was executed because Task 14 requires plan only.

## Important Note

The previous Task 13 AWS resources were no longer present in AWS when the Task 14 plan was executed.

Terraform therefore planned to recreate the missing resources along with the new ECR repository.

The infrastructure was not applied.

## Final Structure

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── user_data.sh
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Status

Task 14 Terraform module implementation completed.

Terraform init, formatting, validation, and planning completed successfully.

Terraform apply was intentionally not performed.