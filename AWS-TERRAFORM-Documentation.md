# AWS Terraform Documentation

## Task 11 – Terraform Preparation

Prepared Terraform configuration for the Twenty CRM AWS infrastructure.

### What I configured

- Configured AWS provider for `us-east-1`.
- Used the existing/default VPC using Terraform data sources.
- Configured an EC2 instance with a security group.
- Configured an Amazon ECR repository.
- Added variables for configurable values such as region, project name, instance type, and ECR repository name.
- Added Terraform outputs for VPC ID, EC2 instance ID, public IP, and ECR repository URL.
- Added AWS provider version constraints.

### Terraform Files

- `provider.tf` – AWS provider and Terraform version configuration.
- `variables.tf` – Configurable variables.
- `terraform.tfvars` – Variable values.
- `main.tf` – VPC data source, EC2, security group, and ECR configuration.
- `outputs.tf` – Important resource outputs.

### Validation

```bash
terraform init
terraform validate

- Both commands completed successfully.
- terraform plan was skipped as instructed by the task coordinator.
- terraform apply was not run as required.