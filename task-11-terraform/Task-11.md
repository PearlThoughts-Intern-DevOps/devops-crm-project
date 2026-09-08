# Task 11: Terraform Preparation

## Objective

The objective of this task was to prepare Terraform configuration for the AWS infrastructure required for the Twenty CRM application.

The configuration covers the default VPC, EC2, and Amazon ECR using a variable-based Terraform structure.

---

### File Description

- `provider.tf` – Configures the AWS provider and `us-east-1` region.
- `variables.tf` – Defines configurable Terraform variables.
- `vpc.tf` – References the existing/default AWS VPC and its subnets.
- `ec2.tf` – Defines the EC2 instance and security group.
- `ecr.tf` – Defines the Amazon ECR repository.
- `outputs.tf` – Provides important resource information.
- `.gitignore` – Excludes Terraform state, working files, and other generated files.

---

## AWS Provider

The AWS provider is configured to use:

```text
us-east-1
```
---

## VPC

The default AWS VPC is referenced using Terraform data sources.

---

## EC2

Terraform defines the Twenty CRM EC2 infrastructure using:

- Configurable AMI ID
- Configurable instance type
- Existing/default VPC subnet
- Security group
- SSH access
- Twenty CRM port `2020`
- Public IP association

---

## Amazon ECR

An Amazon ECR repository is defined for the Twenty CRM application.

The repository uses:

- Configurable repository name
- Mutable image tags
- Image scanning on push

---

## Variables and Outputs

Configurable values are defined in `variables.tf`.

Important resource information is exposed through `outputs.tf`, including:

- VPC ID
- Subnet ID
- EC2 instance ID
- EC2 public IP
- ECR repository URL

---

## Terraform Validation

The configuration was formatted using:

```bash
terraform fmt
```

Terraform was initialized using:

```bash
terraform init
```

The configuration was validated using:

```bash
terraform validate
```

Validation completed successfully.

---


## Conclusion

Task 11 successfully prepared a clean Terraform configuration for the existing/default VPC, EC2, and Amazon ECR.

### Thank you!