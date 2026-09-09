# Terraform Infrastructure Configuration
## Twenty CRM — AWS Infrastructure as Code

> **Task 11** | DevOps Internship — PearlsThoughts
> **Author:** Shubham Singh
> **Region:** us-east-1 (N. Virginia)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Resources](#resources)
- [Variables](#variables)
- [Outputs](#outputs)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Validation Results](#validation-results)
- [Best Practices Applied](#best-practices-applied)

---

## Overview

This repository contains Terraform configuration files that define
the complete AWS infrastructure for the **Twenty CRM** application.
Twenty CRM is an open-source customer relationship management system
deployed using Docker containers on AWS EC2.

The infrastructure is defined as code using **HashiCorp Terraform**,
following Infrastructure as Code (IaC) principles. This means the
entire AWS environment — networking, compute, and container registry —
can be created, modified, or destroyed using simple commands, making
it repeatable, version-controlled, and auditable.

### What this configuration provisions

```
AWS Cloud (us-east-1)
│
├── VPC (Virtual Private Cloud)
│   ├── Public Subnet (us-east-1a)
│   ├── Internet Gateway
│   └── Route Table → routes traffic to internet
│
├── EC2 Instance (t3.small)
│   ├── Ubuntu 22.04 LTS
│   ├── 20GB gp3 EBS volume
│   ├── Security Group (ports 22, 80, 443, 3000)
│   └── Twenty CRM running via Docker
│
└── ECR (Elastic Container Registry)
    ├── Repository: twenty-crm
    ├── Image scanning on push
    └── Lifecycle policy (keeps last 10 images)
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Cloud (us-east-1)                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              VPC (10.0.0.0/16)                       │  │
│  │                                                      │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │         Public Subnet (10.0.1.0/24)         │    │  │
│  │  │         Availability Zone: us-east-1a       │    │  │
│  │  │                                             │    │  │
│  │  │   ┌─────────────────────────────────────┐  │    │  │
│  │  │   │        EC2 Instance (t3.small)       │  │    │  │
│  │  │   │        Ubuntu 22.04 LTS              │  │    │  │
│  │  │   │        20GB gp3 EBS Volume           │  │    │  │
│  │  │   │                                     │  │    │  │
│  │  │   │   ┌─────────────────────────────┐   │  │    │  │
│  │  │   │   │    Docker Containers         │   │  │    │  │
│  │  │   │   │  ┌──────────────────────┐   │   │  │    │  │
│  │  │   │   │  │  Twenty CRM Server   │   │   │  │    │  │
│  │  │   │   │  │  Port: 3000          │   │   │  │    │  │
│  │  │   │   │  └──────────────────────┘   │   │  │    │  │
│  │  │   │   │  ┌──────────────────────┐   │   │  │    │  │
│  │  │   │   │  │  PostgreSQL DB        │   │   │  │    │  │
│  │  │   │   │  └──────────────────────┘   │   │  │    │  │
│  │  │   │   │  ┌──────────────────────┐   │   │  │    │  │
│  │  │   │   │  │  Redis Cache         │   │   │  │    │  │
│  │  │   │   │  └──────────────────────┘   │   │  │    │  │
│  │  │   │   └─────────────────────────────┘   │  │    │  │
│  │  │   └─────────────────────────────────────┘  │    │  │
│  │  └─────────────────────────────────────────────┘    │  │
│  │                         │                            │  │
│  │              Internet Gateway                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                               │
│                        Internet                            │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         ECR (Elastic Container Registry)            │  │
│  │         Repository: twenty-crm                      │  │
│  │         Image scanning: enabled                     │  │
│  │         Lifecycle: keeps last 10 images             │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
terraform/
│
├── provider.tf          # AWS provider configuration and
│                        # Terraform version constraints
│
├── variables.tf         # All input variable declarations
│                        # with types, descriptions, defaults
│
├── main.tf              # Core infrastructure resources
│                        # VPC, Subnet, IGW, Route Table,
│                        # Security Group, EC2, ECR
│
├── outputs.tf           # Output values exported after apply
│                        # IDs, IPs, URLs of created resources
│
├── terraform.tfvars     # Actual values assigned to variables
│                        # environment-specific configuration
│
└── README.md            # This documentation file
```

### Why this structure?

Each file has a single clear responsibility:

| File | Responsibility |
|------|---------------|
| `provider.tf` | Tells Terraform which cloud provider to use and version |
| `variables.tf` | Defines all configurable inputs — no hardcoded values |
| `main.tf` | The actual infrastructure resources being created |
| `outputs.tf` | Exposes important values after resources are created |
| `terraform.tfvars` | The actual values injected into variables |

---

## Resources

### 1. VPC (Virtual Private Cloud)

The VPC is the isolated network environment where all resources live.

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

| Property | Value | Reason |
|----------|-------|--------|
| CIDR block | `10.0.0.0/16` | Provides 65,536 IP addresses |
| DNS hostnames | enabled | EC2 instances get public DNS names |
| DNS support | enabled | Required for DNS resolution inside VPC |

---

### 2. Public Subnet

The subnet is a subdivision of the VPC where EC2 lives.

```hcl
resource "aws_subnet" "public" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
```

| Property | Value | Reason |
|----------|-------|--------|
| CIDR block | `10.0.1.0/24` | 256 IPs for public resources |
| AZ | `us-east-1a` | Single AZ for simplicity |
| Auto public IP | true | EC2 gets public IP automatically |

---

### 3. Internet Gateway + Route Table

Allows resources inside the VPC to communicate with the internet.

```
EC2 Instance
    │
    ▼
Route Table (0.0.0.0/0 → IGW)
    │
    ▼
Internet Gateway
    │
    ▼
Internet
```

---

### 4. Security Group

Controls inbound and outbound traffic to the EC2 instance.

#### Inbound Rules

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | 0.0.0.0/0 | SSH access for administration |
| 80 | TCP | 0.0.0.0/0 | HTTP web traffic |
| 443 | TCP | 0.0.0.0/0 | HTTPS secure web traffic |
| 3000 | TCP | 0.0.0.0/0 | Twenty CRM application port |

#### Outbound Rules

| Port | Protocol | Destination | Purpose |
|------|----------|-------------|---------|
| All | All | 0.0.0.0/0 | Allow all outbound traffic |

---

### 5. EC2 Instance

The virtual machine running the Twenty CRM application.

```hcl
resource "aws_instance" "twenty_crm" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t3.small"
}
```

| Property | Value | Reason |
|----------|-------|--------|
| AMI | Ubuntu 22.04 LTS | Stable LTS Linux distribution |
| Instance type | t3.small | 2 vCPU, 2GB RAM — sufficient for CRM |
| Volume size | 20GB | Enough for OS + Docker + CRM data |
| Volume type | gp3 | Better performance than gp2, lower cost |
| Key pair | instance1-key | Existing key for SSH access |

---

### 6. ECR (Elastic Container Registry)

Private Docker image registry for storing Twenty CRM container images.

```hcl
resource "aws_ecr_repository" "twenty_crm" {
  name                 = "twenty-crm"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

| Property | Value | Reason |
|----------|-------|--------|
| Name | `twenty-crm` | Repository for CRM images |
| Tag mutability | MUTABLE | Allows overwriting tags (e.g. latest) |
| Scan on push | true | Auto security scan on every image push |

#### ECR Lifecycle Policy

Automatically removes old images to save storage costs:

```
Rule: Keep only the last 10 images
→ When 11th image is pushed
→ Oldest image is automatically deleted
→ Keeps storage costs minimal
```

---

## Variables

All configurable values are defined as variables — no hardcoded
values exist in the resource definitions. This makes the
configuration reusable across different environments.

### Complete Variables Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for all resources |
| `project_name` | string | `twenty-crm` | Used in resource names and tags |
| `environment` | string | `dev` | Environment (dev/staging/prod) |
| `vpc_cidr` | string | `10.0.0.0/16` | CIDR block for VPC |
| `public_subnet_cidr` | string | `10.0.1.0/24` | CIDR for public subnet |
| `availability_zone` | string | `us-east-1a` | AZ for subnet placement |
| `instance_type` | string | `t3.small` | EC2 instance size |
| `ami_id` | string | `ami-0866a3c8686eaeeba` | Ubuntu 22.04 LTS AMI |
| `key_name` | string | `instance1-key` | SSH key pair name |
| `root_volume_size` | number | `20` | EBS volume size in GB |
| `ecr_repo_name` | string | `twenty-crm` | ECR repository name |
| `image_tag_mutability` | string | `MUTABLE` | ECR image tag setting |

### How variables flow through the configuration

```
terraform.tfvars            variables.tf             main.tf
────────────────────        ────────────             ───────
aws_region = "us-east-1" →  var.aws_region       →  provider region
instance_type = "t3.small"→  var.instance_type   →  aws_instance
ecr_repo_name = "twenty"  →  var.ecr_repo_name   →  aws_ecr_repository
```

---

## Outputs

After `terraform apply`, these values are printed to the terminal
and can be used by other systems or CI/CD pipelines.

| Output | Description | Example Value |
|--------|-------------|---------------|
| `vpc_id` | VPC unique identifier | `vpc-0abc123def456` |
| `vpc_cidr` | VPC IP range | `10.0.0.0/16` |
| `public_subnet_id` | Subnet identifier | `subnet-0abc123` |
| `ec2_instance_id` | EC2 instance ID | `i-0abc123def456789` |
| `ec2_public_ip` | Public IP address | `54.123.45.67` |
| `ec2_public_dns` | Public DNS hostname | `ec2-54-123-45-67.compute-1.amazonaws.com` |
| `ec2_instance_type` | Instance size used | `t3.small` |
| `security_group_id` | Security group ID | `sg-0abc123def` |
| `ecr_repository_url` | Full ECR URL for docker push | `123456789.dkr.ecr.us-east-1.amazonaws.com/twenty-crm` |
| `ecr_repository_name` | ECR repo name | `twenty-crm` |
| `ecr_registry_id` | ECR registry ID | `123456789012` |

---

## Prerequisites

### 1. Terraform installed (>= 1.0)
```bash
terraform version
# Terraform v1.16.1
```

### 2. AWS credentials configured
Required only for `terraform plan` and `terraform apply`.
For this task (`init` and `validate` only) — no credentials needed.

---

## Usage

### Step 1 — Clone and navigate
```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project/terraform
```

### Step 2 — Initialize Terraform
```bash
terraform init
```
Downloads the AWS provider plugin. Run once per project setup.

```
Initializing provider plugins...
- Installing hashicorp/aws v5.100.0...
Terraform has been successfully initialized! ✅
```

### Step 3 — Validate configuration
```bash
terraform validate
```
Checks syntax and internal consistency. No AWS API calls made.
No credentials required.

```
Success! The configuration is valid. ✅
```

---

## Validation Results

Both required commands completed successfully on this configuration:

```bash
$ terraform init

Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.100.0

Terraform has been successfully initialized! ✅

$ terraform validate

Success! The configuration is valid. ✅
```

---

## Best Practices Applied

### 1. No hardcoded values
```hcl
# ❌ Bad practice
instance_type = "t3.small"

# ✅ Good practice (what we do)
instance_type = var.instance_type
```

### 2. Consistent tagging on all resources
```hcl
tags = {
  Name        = "${var.project_name}-vpc"
  Environment = var.environment
  Project     = var.project_name
}
```
Every resource tagged for cost tracking and identification.

### 3. Variables with descriptions and types
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}
```

### 4. Outputs for all important values
All resource IDs, IPs, and URLs exported as outputs for
use in CI/CD pipelines or other Terraform configurations.

### 5. Principle of least privilege on security group
Only required ports opened — no unnecessary access.

### 6. ECR lifecycle policy
Automatic cleanup of old images prevents storage cost growth.

### 7. gp3 over gp2 for EBS volumes
gp3 is 20% cheaper with better baseline performance than gp2.

### 8. Clean file separation
Each file has one clear purpose — easy to navigate and maintain.

---

## Author

| Field | Details |
|-------|---------|
| Name | Shubham Singh |
| Role | Cloud Support Engineer Intern |
| Education | MCA 2026 — Garden City University, Bangalore |
| Task | Task-11 — Terraform Preparation |
| Organization | PearlsThoughts DevOps Internship |
| Date | September 2026 |

---

*This configuration is part of the PearlsThoughts DevOps Internship program.*
