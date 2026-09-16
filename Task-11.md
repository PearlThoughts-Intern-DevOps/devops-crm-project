# Task 11: Terraform Preparation for Twenty CRM

**Name:** Mujtaba Shaikh
**Task:** Terraform Preparation for Twenty CRM AWS Infrastructure
**Date:** 8 September 2026

## Objective

The objective of this task was to prepare a Terraform configuration for the Twenty CRM AWS infrastructure using Terraform best practices.

The infrastructure was prepared for deployment but was not actually deployed. Terraform was used to initialize, validate, and generate an execution plan.

## Work Completed

### 1. Terraform Project Structure

Created a dedicated `terraform/` directory containing:

```text
terraform/
├── .gitignore
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── .terraform.lock.hcl
```

### 2. AWS Provider Configuration

Configured the HashiCorp AWS provider with:

* AWS region: `us-east-1`
* AWS provider version constraint: `~> 6.0`
* Terraform minimum version: `>= 1.5.0`

The AWS region is configurable through the `aws_region` variable.

### 3. Terraform Variables

Created reusable variables for:

* AWS region
* EC2 instance type
* Ubuntu AMI ID
* EC2 key pair name
* ECR repository name
* Project name

Default values were provided for the required configuration so that the Terraform plan could be generated without interactive input.

### 4. Existing Default VPC

Instead of creating a new VPC, Terraform references the existing AWS default VPC using a data source.

The default VPC detected during planning was:

```text
vpc-014579b2a2e3a88bf
```

Terraform also discovers the subnets available in the default VPC and uses an available subnet for the EC2 instance.

### 5. EC2 Configuration

Configured an EC2 instance for Twenty CRM with:

* AMI: `ami-025d99823a4caad37`
* OS: Ubuntu 24.04
* Instance type: `t2.micro`
* Key pair: `terra-key`
* Existing default VPC subnet
* Twenty CRM security group

The AMI ID was obtained by searching the available Ubuntu 24.04 AMIs in the `us-east-1` region using AWS CLI.

The `terra-key` key pair was selected from the existing EC2 key pairs in the AWS account.

Terraform requires the AWS key pair name, not the local `.pem` private key file.

### 6. Security Group

Created a security group for the Twenty CRM EC2 instance.

Configured inbound access for:

* SSH: TCP port `22`
* Twenty CRM: TCP port `2020`

Outbound traffic is allowed.

The security group is attached to the EC2 instance.

### 7. Amazon ECR

Created an Amazon Elastic Container Registry repository named:

```text
twenty-crm
```

The repository is configured with:

* Mutable image tags
* Image scanning enabled on push

The ECR repository is intended to store the Twenty CRM Docker image.

No Docker image was built or pushed as part of this task.

### 8. Terraform Outputs

Configured outputs for important infrastructure information:

* Default VPC ID
* EC2 instance ID
* EC2 public IP
* ECR repository URL

These outputs make important resource information available after infrastructure creation.

### 9. Terraform `.gitignore`

Added `.gitignore` to prevent Terraform-generated files and state files from being committed to Git.

Examples include:

```text
.terraform/
*.tfstate
*.tfstate.*
```

The Terraform provider lock file `.terraform.lock.hcl` is kept for provider version consistency.

## Terraform Validation

The following commands were successfully executed.

### Terraform Init

```bash
terraform init
```

Result:

```text
Terraform has been successfully initialized!
```

### Terraform Validate

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

### Terraform Plan

```bash
terraform plan
```

Result:

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

The plan included:

* EC2 instance
* Security group
* ECR repository

The existing default VPC and subnet were successfully detected.

## Deployment Status

`terraform apply` was **not executed**.

This task was limited to Terraform preparation, validation, and planning. Therefore, no AWS infrastructure was created through Terraform during this task.

## Summary

Completed the Terraform preparation for Twenty CRM by creating a clean Terraform structure, configuring the AWS provider, defining variables, referencing the existing default VPC, preparing EC2 and security group configuration, creating an ECR repository configuration, adding outputs, and validating the configuration with Terraform.

The Terraform configuration successfully passed:

```text
terraform init
terraform validate
terraform plan
```

Final plan:

```text
3 to add, 0 to change, 0 to destroy
```

