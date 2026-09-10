# Task 12: Terraform + AWS Infrastructure for Twenty CRM

**Name:** Shubham Singh
**Task:** Terraform + AWS Infrastructure with ECR Image Push
**Date:** 09-09-2026
**Region:** US East (N. Virginia) — us-east-1
**Organization:** PearlThoughts DevOps Internship

---

## Table of Contents

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Architecture](#architecture)
4. [Prerequisites](#prerequisites)
5. [Terraform Configuration](#terraform-configuration)
6. [Deployment Steps](#deployment-steps)
7. [Docker Image Build & ECR Push](#docker-image-build--ecr-push)
8. [EC2 User Data](#ec2-user-data)
9. [Verification](#verification)
10. [Terraform Destroy](#terraform-destroy)
11. [Issues Faced & Solutions](#issues-faced--solutions)
12. [Conclusion](#conclusion)

---

## Overview

This task provisions the complete AWS infrastructure for the Twenty CRM application using Terraform and deploys the Docker image through Amazon ECR.

**What this task covers:**
- Provisioning EC2 and ECR using Terraform (existing default VPC reused)
- Building the Twenty CRM Docker image locally
- Pushing the image to ECR
- Configuring EC2 User Data for automatic Docker install, ECR auth, image pull, and container startup
- Verifying Twenty CRM running on the EC2 instance
- Running `terraform destroy` and verifying full cleanup

---

## Project Structure

```
terraform/
├── main.tf                  # AWS provider and Terraform version constraints
├── vpc.tf                   # Data sources for existing default VPC and subnet
├── ec2.tf                   # EC2 instance resource
├── ecr.tf                   # ECR repository and lifecycle policy
├── iam.tf                   # IAM instance profile for ECR access
├── sg.tf                    # Security group with inbound rules
├── variables.tf             # All input variable declarations
├── outputs.tf               # Output values (IP, ECR URL, SSH command, app URL)
├── terraform.tfvars         # Actual variable values
├── terraform.tfvars.example # Example values for reference
└── user_data.sh.tpl         # EC2 User Data shell script template
```

---

## Architecture

```
AWS Cloud (us-east-1)
│
├── Default VPC (existing — not created by Terraform)
│   └── Default Subnet
│       └── EC2 Instance (t3.small)
│           ├── Ubuntu LTS
│           ├── IAM Role: EC2ECRPullRole
│           ├── Security Group (ports 22, 2020)
│           └── User Data → auto-installs Docker, pulls from ECR, runs container
│
└── ECR Repository: shubham-singh-twenty-crm
    ├── Image scanning on push: enabled
    └── Lifecycle policy: keep last 10 images
```

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Terraform | >= 1.5 | Infrastructure provisioning |
| AWS CLI | v2 | ECR authentication, resource lookup |
| Docker | latest | Image build and push |
| Git | latest | Repository clone |

**AWS credentials configured via:**
```bash
aws configure
# AWS Access Key ID:     → provided by mentor
# AWS Secret Access Key: → provided by mentor
# Default region:        → us-east-1
# Default output format: → json
```

---

## Terraform Configuration

### Provider (`main.tf`)

Configured for `us-east-1` with default tags applied to all resources:

```hcl
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

### VPC (`vpc.tf`)

Reused the existing default VPC and subnet — no new VPC created:

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
}
```

### Security Group (`sg.tf`)

| Port | Protocol | Purpose |
|---|---|---|
| 22 | TCP | SSH access |
| 2020 | TCP | Twenty CRM application |

### EC2 Instance (`ec2.tf`)

| Setting | Value |
|---|---|
| AMI | `ami-0b6d9d3d33ba97d99` (Ubuntu LTS) |
| Instance Type | `t3.small` |
| IAM Profile | `EC2ECRPullRole` |
| User Data | `user_data.sh.tpl` |

### ECR Repository (`ecr.tf`)

| Setting | Value |
|---|---|
| Repository Name | `shubham-singh-twenty-crm` |
| Image Scanning | Enabled on push |
| Tag Mutability | MUTABLE |
| Lifecycle Policy | Keep last 10 images |

### Variables (`variables.tf`)

All configurable values are defined as variables — no hardcoded values in resource definitions.

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region |
| `project_name` | `twenty-crm` | Used in resource names and tags |
| `environment` | `dev` | Environment tag |
| `instance_type` | `t3.small` | EC2 instance size |
| `ami_id` | `ami-0b6d9d3d33ba97d99` | Ubuntu LTS AMI |
| `app_port` | `2020` | Twenty CRM application port |

### Outputs (`outputs.tf`)

| Output | Description |
|---|---|
| `ec2_public_ip` | Public IP of the EC2 instance |
| `app_url` | Full URL to access Twenty CRM |
| `ssh_command` | Ready-to-use SSH command |
| `ecr_repository_url` | ECR URL for Docker push |

---

## Deployment Steps

### Step 1 — Initialize Terraform

```bash
cd terraform/
terraform init
```

```
Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized! ✅
```

### Step 2 — Validate Configuration

```bash
terraform validate
```

```
Success! The configuration is valid. ✅
```

### Step 3 — Plan

```bash
terraform plan
```

```
Plan: 4 to add, 0 to change, 0 to destroy. ✅
```

Resources to be created:
- `aws_ecr_repository.twenty_crm`
- `aws_ecr_lifecycle_policy.twenty_crm`
- `aws_security_group.twenty_crm`
- `aws_instance.twenty_crm`

### Step 4 — Apply

```bash
terraform apply
```

```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed. ✅
```

---

## Docker Image Build & ECR Push

### Build the Image

```bash
cd ~/devops-crm-project
docker build -t twenty-crm:latest .
```

### Authenticate with ECR

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/shubham-singh-twenty-crm
```

### Tag and Push

```bash
# Tag
docker tag twenty-crm:latest \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/shubham-singh-twenty-crm:latest

# Push
docker push \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/shubham-singh-twenty-crm:latest
```

---

## EC2 User Data

The `user_data.sh.tpl` script runs automatically on EC2 launch and:

1. Installs Docker and required dependencies
2. Authenticates with Amazon ECR using the attached IAM role
3. Attempts to pull the Twenty CRM image from ECR with retry logic (retries every 30 seconds if image not yet available)
4. Runs the Twenty CRM container on port 2020

```bash
# Retry logic used in user_data.sh.tpl
until docker pull ${ecr_image_url}; do
  echo "Image not ready yet — retrying in 30 seconds..."
  sleep 30
done

docker run -d \
  --name shubham-singh-twenty-crm \
  --restart unless-stopped \
  -p 2020:3000 \
  -e NODE_ENV=production \
  ${ecr_image_url}
```

---

## Verification

### Twenty CRM Running

After EC2 launched and User Data completed:

```bash
# Health check
curl http://44.204.186.237:2020/healthz
# Response: {"status":"ok"} ✅
```

Twenty CRM accessible at: `http://44.204.186.237:2020` ✅

---

## Terraform Destroy

After verification, all resources were cleaned up:

```bash
terraform destroy
```

```
Destroy complete! Resources: 4 destroyed. ✅
```

All resources confirmed deleted — EC2 instance, ECR repository, and Security Group.

---

## Issues Faced & Solutions

### Issue 1 — Wrong Windows Username in WSL

**Problem:** `.pem` file copy from Windows to WSL failed — `cp: cannot stat` error
**Root Cause:** Windows username was `shubh` not `shubham`
**Solution:** Ran `ls /mnt/c/Users/` to find correct username, then used correct path `/mnt/c/Users/shubh/Downloads/`

### Issue 2 — AMI Lookup Failure

**Problem:** Terraform's `data "aws_ami"` data source returned no results in the sandbox account
**Root Cause:** Sandbox account has restricted AMI visibility
**Solution:** Fetched a valid AMI ID directly via AWS CLI:
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*24.04*amd64*" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text
```
Passed the result explicitly through the `ami_id` variable.

### Issue 3 — EC2 ModifyInstanceAttribute Permission Denied

**Problem:** `terraform apply` failed when changing `app_port` — `ec2:ModifyInstanceAttribute` blocked
**Root Cause:** Sandbox IAM user lacks permission to modify user_data on a running instance
**Solution:** Ignored the user_data update error (Security Group port was already updated correctly), SSH'd into EC2 and manually restarted the container on port 2020

### Issue 4 — nvm Not Found After SSH Reconnect

**Problem:** `nvm: command not found` on new SSH session
**Root Cause:** nvm is a shell function loaded per session, not a persistent binary
**Solution:** Manually reloaded nvm each session:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

---

## Conclusion

### Final Status Summary

| Task | Status | Details |
|---|---|---|
| Terraform project structure created | ✅ Done | 8 separate `.tf` files |
| AWS provider configured | ✅ Done | `us-east-1` |
| Default VPC/subnet reused | ✅ Done | No new VPC created |
| ECR repository created | ✅ Done | `shubham-singh-twenty-crm` |
| Security Group created | ✅ Done | Ports 22 and 2020 |
| EC2 instance provisioned | ✅ Done | `t3.small`, Ubuntu LTS |
| `terraform init` | ✅ Done | No errors |
| `terraform validate` | ✅ Done | Configuration valid |
| `terraform plan` | ✅ Done | 4 to add, 0 errors |
| `terraform apply` | ✅ Done | 4 resources created |
| Docker image built | ✅ Done | `twenty-crm:latest` |
| Image pushed to ECR | ✅ Done | ECR URL tagged and pushed |
| EC2 User Data configured | ✅ Done | Auto-installs Docker, pulls from ECR, runs container |
| Twenty CRM verified | ✅ Done | `{"status":"ok"}` at port 2020 |
| `terraform destroy` | ✅ Done | All 4 resources destroyed |
| Branch and PR raised | ✅ Done | `shubham-task-12` |

### Key Learnings

- **Default VPC saves time** — no need to create networking from scratch for dev tasks
- **IAM role on EC2 is essential** — without it, User Data cannot authenticate with ECR
- **User Data retry logic is critical** — ECR push and EC2 launch happen in parallel; retry ensures the container starts even if image arrives late
- **Variables over hardcoding** — makes the same config reusable across environments
- **`terraform destroy` is non-negotiable** — always clean up to avoid unexpected AWS charges

---

*Documentation by Shubham Singh | Task 12 | PearlThoughts DevOps Internship | September 2026*
