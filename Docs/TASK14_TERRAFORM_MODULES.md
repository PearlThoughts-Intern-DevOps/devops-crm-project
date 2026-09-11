# Task 14: Terraform Modules

## 1. Overview

Task 14 refactors the Terraform configuration into reusable Terraform modules.

The configuration is divided into three reusable modules:

- EC2
- ECR
- S3

The root Terraform configuration calls these modules and passes the required values through variables and `terraform.tfvars`.

No Terraform infrastructure was applied for this task, as required.

---

## 2. Objectives

1. Create reusable Terraform modules for EC2, ECR and S3.
2. Use `variables.tf` and `outputs.tf` for module inputs and outputs.
3. Call the modules from the root Terraform configuration.
4. Use `terraform.tfvars` for environment-specific values.
5. Keep the Terraform configuration reusable and properly structured.
6. Run `terraform init`, `terraform fmt`, `terraform validate` and `terraform plan`.
7. Do not run `terraform apply`.

---

## 3. Project Structure

```text
terraform/task14/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfvars.example
├── .gitignore
├── .terraform.lock.hcl
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
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

## 4. Module Architecture

```text
                    Root Module
                  terraform/task14
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
      EC2 Module      ECR Module      S3 Module
          |              |              |
          v              v              v
      EC2 Instance   ECR Repository   S3 Bucket
```

Each module manages a specific infrastructure component independently.

---

## 5. EC2 Module

Location:

```text
terraform/task14/modules/ec2/
```

The EC2 module creates an EC2 instance using:

- AMI ID
- Instance type
- Subnet ID
- Security group IDs
- Instance name

The instance uses `vpc_security_group_ids` for security group association.

The root block device uses:

- 20 GB storage
- gp3 volume type

Outputs:

- EC2 instance ID
- Public IP
- Private IP

The EC2 module is intentionally generic and does not contain application-specific user-data or IAM configuration.

---

## 6. ECR Module

Location:

```text
terraform/task14/modules/ecr/
```

The ECR module creates an Amazon Elastic Container Registry repository.

Inputs:

- Repository name
- Image tag mutability
- Image scanning configuration

Image scanning on push is enabled.

Outputs:

- Repository name
- Repository URL
- Repository ARN

---

## 7. S3 Module

Location:

```text
terraform/task14/modules/s3/
```

The S3 module creates an Amazon S3 bucket.

Inputs:

- Bucket name
- Environment
- Purpose

The bucket is configured with versioning, AES256 server-side encryption, and Block Public Access.

All four Block Public Access settings are enabled:

```text
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

Outputs:

- Bucket name
- Bucket ARN
- Bucket ID

---

## 8. Root Module

Location:

```text
terraform/task14/main.tf
```

The root module configures the AWS provider and uses the existing default VPC and an existing default subnet.

The three reusable modules are called with:

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

The root module passes values into the child modules using variables and consumes their outputs.

---

## 9. Variables

The root configuration uses variables for:

- AWS region
- AMI ID
- EC2 instance type
- S3 bucket name
- ECR repository name
- SSH CIDR
- Docker image tag

The EC2 instance type is restricted to:

```text
t3.small
```

The AWS region is:

```text
us-east-1
```

---

## 10. Terraform Variables File

Environment-specific values are provided through:

```text
terraform.tfvars
```

A reusable example is also provided:

```text
terraform.tfvars.example
```

The actual `terraform.tfvars` file is excluded from Git using `.gitignore`.

---

## 11. Terraform Outputs

The root module exposes:

```text
vpc_id
subnet_id
ec2_instance_id
ec2_public_ip
s3_bucket_name
s3_bucket_arn
ecr_repository_name
ecr_repository_url
```

These outputs allow values from the child modules to be accessed from the root configuration.

---

## 12. Terraform Commands

The following commands were executed:

### Initialize

```bash
terraform init
```

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

The configuration passed Terraform validation successfully.

### Plan

```bash
terraform plan
```

Final plan result:

```text
Plan: 7 to add, 0 to change, 0 to destroy.
```

---

## 13. Terraform Apply

Terraform apply was intentionally **not executed**.

This follows the Task 14 requirement:

> Do not run `terraform apply`.

Therefore, no Task 14 infrastructure was provisioned through Terraform.

---

## 14. Reusability

The configuration follows a modular design.

Each infrastructure component is separated into its own module:

```text
modules/ec2
modules/ecr
modules/s3
```

Each module contains:

```text
main.tf
variables.tf
outputs.tf
```

The modules can be reused in other Terraform configurations by providing different input values.

---

## 15. Conclusion

Task 14 refactors the Terraform configuration into reusable EC2, ECR and S3 modules.

The root Terraform configuration calls the modules and passes configuration values through variables and `terraform.tfvars`.

Terraform initialization, formatting, validation and planning were completed successfully.

Final Terraform plan:

```text
Plan: 7 to add, 0 to change, 0 to destroy.
```

No Terraform apply operation was performed, as required by the task.
