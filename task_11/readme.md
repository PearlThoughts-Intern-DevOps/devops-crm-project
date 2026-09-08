# Task 11: Terraform Preparation

## Overview

This task focuses on preparing Terraform configuration for the AWS infrastructure used by the **Twenty CRM application**.

The Terraform project defines the required AWS provider, VPC networking, EC2 instance, and Amazon ECR repository while using variables and outputs to keep the configuration reusable and easy to manage.

## AWS Infrastructure

The following resources are defined using Terraform:

* **VPC** – Provides the network environment.
* **Public Subnet** – Hosts the EC2 instance.
* **Internet Gateway** – Provides internet connectivity.
* **Route Table** – Routes public traffic through the Internet Gateway.
* **Security Group** – Allows SSH and Twenty CRM traffic on port `3000`.
* **EC2** – Hosts the Twenty CRM application.
* **Amazon ECR** – Stores the Twenty CRM Docker image.

## Project Structure

```text
task_11/
├── main.tf
├── variables.tf
├── outputs.tf
└── .terraform.lock.hcl
```

### `main.tf`

Contains:

* Terraform and AWS provider configuration
* VPC and networking resources
* Security group
* EC2 instance
* Amazon ECR repository

### `variables.tf`

Contains configurable values such as:

* AWS region
* Project name
* VPC CIDR
* Subnet CIDR
* Availability Zone
* AMI ID
* EC2 instance type
* EC2 key pair
* ECR repository name

### `outputs.tf`

Provides important infrastructure information such as:

* VPC ID
* Subnet ID
* EC2 instance ID
* EC2 public IP
* ECR repository URL

## AWS Provider

The AWS provider is configured for:

```text
Region: us-east-1
```

## Terraform Commands

### Initialize Terraform

```bash
terraform init
```

This initializes the Terraform working directory and installs the required AWS provider.

### Validate Configuration

```bash
terraform validate
```

The configuration was successfully validated:

```text
Success! The configuration is valid.
```

### Generate Infrastructure Plan

```bash
terraform plan
```

This command is used to review the infrastructure changes Terraform intends to make before applying them.

## Key Terraform Practices Used

* Provider configuration is separated from resource definitions.
* Configurable values are managed through Terraform variables.
* Important resource information is exposed through outputs.
* Resource names use a consistent project naming convention.
* Terraform provider versions are managed through the provider configuration.
* `.terraform.lock.hcl` is maintained to lock the selected provider version.

## Validation Status

| Check                     | Status                              |
| ------------------------- | ----------------------------------  |
| Terraform initialization  | ✅ Successful                       |
| AWS provider installation | ✅ Successful                       |
| Terraform validation      | ✅ Successful                       |
| Terraform plan            | ✅ Successful                       |

## Conclusion

The Terraform configuration for the Twenty CRM AWS infrastructure has been prepared successfully. The configuration is structured to be reusable, maintainable, and easy to understand, with the required VPC, EC2, and ECR resources defined using Terraform.
