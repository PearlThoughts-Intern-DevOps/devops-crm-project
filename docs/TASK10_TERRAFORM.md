# Task 11: Terraform Preparation

**Name:** Harish
**Date:** September 8, 2026
**Task:** Prepare Terraform configuration for the AWS infrastructure used for the Twenty CRM application.
**PR link**[]
**Loom link** [https://drive.google.com/file/d/1VgBjMlcvtmrv9Hyv3bXC13Vd8CSh2Qzq/view?usp=drive_link]

## 1. Objective

The objective of this task was to prepare Terraform configuration for the AWS infrastructure required for the Twenty CRM application.

The Terraform configuration covers:

* Existing/default AWS VPC
* Default subnet
* Security Group
* EC2 instance
* Amazon ECR repository

The infrastructure was prepared, validated, and planned using Terraform.

As instructed, **Terraform Apply was not executed.**

## 2. Terraform Project Structure

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars.example
└── .gitignore
```

## 3. Terraform Configuration

### main.tf

The `main.tf` file contains the AWS infrastructure resources:

* Default VPC
* Default subnet
* Security group
* EC2 instance
* Amazon ECR repository

### variables.tf

The `variables.tf` file defines configurable values such as:

```text
aws_region
environment
vpc_id
subnet_id
ami_id
instance_type
instance_name
ecr_repo_name
```

Variables make the configuration reusable and avoid unnecessary hardcoding.

### outputs.tf

The following outputs were configured:

```text
vpc_id
ec2_security_group_id
ec2_instance_id
ec2_public_ip
ecr_repository_url
```

### versions.tf

The Terraform and AWS provider versions are defined in `versions.tf`.

The AWS provider is configured for:

```text
us-east-1
```

## 4. terraform.tfvars.example

The example variable file is located at:

```text
terraform/terraform.tfvars.example
```

It contains:

```hcl
aws_region    = "us-east-1"
environment   = "dev"
instance_type = "t3.medium"
instance_name = "twenty-crm-server"
ecr_repo_name = "twenty-crm-repo"
ami_id        = "ami-0c7217cdde317cfec"
```

This provides example values for configuring the Terraform infrastructure.

## 5. VPC and Subnet

The configuration uses the existing/default AWS VPC.

A default subnet in `us-east-1a` is configured for the EC2 instance.

This follows the requirement to use the existing/default VPC setup where applicable.

## 6. Security Group

A security group was configured for the Twenty CRM EC2 instance.

### Inbound Access

| Port | Purpose                |
| ---- | ---------------------- |
| 22   | SSH                    |
| 80   | HTTP                   |
| 3000 | Twenty CRM application |

Outbound traffic is allowed.

## 7. EC2 Instance

The EC2 instance is configured using Terraform variables.

Configuration includes:

* **AMI:** `ami-0c7217cdde317cfec`
* **Instance type:** `t3.medium`
* **Instance name:** `twenty-crm-server`
* **Root volume:** 30 GB
* **Volume type:** gp3
* **Encryption:** Enabled
* **Delete on termination:** Enabled

## 8. Amazon ECR

An Amazon ECR repository was configured for Twenty CRM Docker images.

Configuration:

* **Repository:** `twenty-crm-repo`
* **Image tag mutability:** `MUTABLE`
* **Scan on push:** Enabled

# 9. Terraform Commands Executed

The following commands were executed one by one.

## Step 1: Terraform Version

Command:

```bash
terraform version
```

Status

NOT EXECUTED

The task specifically instructed not to run terraform apply.

Therefore, no infrastructure was created or modified through Terraform.