# Task 11: Terraform AWS Infrastructure

## 1. Overview

This task implements AWS infrastructure using Terraform as Infrastructure as Code (IaC).

The implementation is designed to:

- Configure the AWS provider in `us-east-1`.
- Use the existing/default VPC where applicable.
- Retrieve an existing subnet and default security group.
- Dynamically select an Amazon Linux 2023 AMI.
- Define an EC2 instance for the Twenty CRM environment.
- Define an Amazon ECR repository for Twenty CRM container images.
- Use Terraform variables for configurable values.
- Use Terraform outputs for important infrastructure information.
- Validate the Terraform configuration.
- Generate a Terraform plan without applying the infrastructure.

> **Important:** As required by the assignment, `terraform apply` was **not** executed.

## 2. Git Branch

The implementation is developed on:

```text
netaji-task11
```

## 3. Project Structure

```text
terraform/
├── versions.tf
├── provider.tf
├── variables.tf
├── data.tf
├── main.tf
├── outputs.tf
└── terraform.tfvars.example
```

| File | Purpose |
|---|---|
| `versions.tf` | Terraform and AWS provider version requirements |
| `provider.tf` | AWS provider configuration |
| `variables.tf` | Configurable Terraform variables |
| `data.tf` | Existing AWS resources and AMI lookups |
| `main.tf` | EC2 and ECR resources |
| `outputs.tf` | Infrastructure outputs |
| `terraform.tfvars.example` | Example variable values |

## 4. Terraform Version and Provider

### `versions.tf`

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

The configuration requires Terraform 1.6.0 or newer and the HashiCorp AWS provider compatible with the 6.x release series.

## 5. AWS Provider

### `provider.tf`

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS provider uses the `aws_region` Terraform variable. The default region is `us-east-1`.

Using a variable makes the configuration easier to reuse.

## 6. Terraform Variables

### `variables.tf`

The implementation defines variables for the main configurable parts of the infrastructure.

### AWS Region

```hcl
variable "aws_region" {
  description = "AWS region for the Terraform deployment"
  type        = string
  default     = "us-east-1"
}
```

### EC2 Instance Type

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}
```

### EC2 Key Pair

```hcl
variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = null
}
```

### ECR Repository

```hcl
variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "twenty-crm"
}
```

### Environment

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
```

### Project Name

```hcl
variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "twenty-crm"
}
```

## 7. AWS Data Sources

### `data.tf`

The implementation retrieves existing AWS infrastructure instead of unnecessarily creating duplicate networking resources.

### Default VPC

```hcl
data "aws_vpc" "default" {
  default = true
}
```

This retrieves the account's default VPC.

### Default VPC Subnets

```hcl
data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

This retrieves the subnets belonging to the default VPC.

The EC2 instance uses the first available subnet:

```hcl
data.aws_subnets.default_vpc.ids[0]
```

### Existing Default Security Group

```hcl
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}
```

The configuration uses the existing default security group instead of creating a new security group.

### Amazon Linux 2023 AMI

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```

The AMI is selected dynamically instead of hardcoding an AMI ID.

The lookup searches for an Amazon-owned, Amazon Linux 2023, x86_64, EBS-backed image and selects the most recent match.

## 8. EC2 Infrastructure

### `main.tf`

```hcl
resource "aws_instance" "twenty" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}
```

This defines the EC2 instance for the Twenty CRM environment.

- The AMI comes from the Amazon Linux data source.
- The instance type is configurable.
- The first subnet in the default VPC is selected.
- The existing default security group is used.
- A public IP is requested.
- Tags identify the project and environment.

## 9. Amazon ECR Repository

```hcl
resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
    Project     = var.project_name
  }
}
```

The ECR repository provides a location for Twenty CRM container images.

Image scanning is enabled on push:

```hcl
image_scanning_configuration {
  scan_on_push = true
}
```

The repository also uses project and environment tags.

## 10. Terraform Outputs

### `outputs.tf`

The implementation exposes:

- Default VPC ID.
- Selected subnet ID.
- EC2 instance ID.
- EC2 public IP.
- ECR repository name.
- ECR repository URL.

Example:

```hcl
output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.id
}
```

These outputs make important infrastructure information easily accessible after deployment.

## 11. Example Variables

### `terraform.tfvars.example`

```hcl
aws_region          = "us-east-1"
instance_type       = "t3.small"
key_name            = "demo-value"
ecr_repository_name = "twenty-crm"
environment         = "dev"
project_name        = "twenty-crm"
```

`demo-value` is only a placeholder for an existing EC2 key-pair name.

Environment-specific values should be supplied separately.

## 12. Terraform Initialization

The configuration was initialized using:

```bash
terraform init
```

Result:

```text
Terraform has been successfully initialized!
```

The AWS provider was installed successfully.

Selected provider:

```text
hashicorp/aws v6.63.0
```

Terraform also generated:

```text
.terraform.lock.hcl
```

The lock file records the selected provider version and should be committed to version control.

## 13. Terraform Validation

The configuration was validated using:

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

This confirms that the Terraform configuration is syntactically and structurally valid.


## 14. No Terraform Apply

The assignment explicitly requires the infrastructure to be planned without applying it.

Therefore:

```bash
terraform apply
```

was **not executed**.

The workflow stops after:

```bash
terraform init
terraform validate
```

## 15. Security Considerations

No AWS credentials, private keys, API keys, or other secrets are included in the Terraform source code.

The EC2 `.pem` private key is not part of the Terraform implementation and should never be committed to Git.

The example variables file contains only placeholder values.

## 16. Testing and Verification

The Terraform workflow includes:

```bash
terraform init
```

```bash
terraform validate
```

Initialization completed successfully and validation returned:

```text
Success! The configuration is valid.
```

The plan is used to preview the intended infrastructure without provisioning it.


## 18. Final Summary

The Task 11 Terraform implementation provides:

- AWS provider configuration for `us-east-1`.
- Terraform and AWS provider version constraints.
- Configurable deployment variables.
- Default VPC lookup.
- Default VPC subnet lookup.
- Existing default security group lookup.
- Dynamic Amazon Linux 2023 AMI lookup.
- EC2 instance definition.
- Amazon ECR repository definition.
- Resource tagging.
- Terraform outputs.
- Example variable configuration.
- Successful `terraform init`.
- Successful `terraform validate`.
- Terraform planning without applying infrastructure.

The implementation is maintained on:

```text
netaji-task11
```

The next submission steps are to commit the Terraform implementation and documentation, push the branch, raise the required pull request, and provide the Loom walkthrough.
