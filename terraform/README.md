# Task 13: Twenty CRM + AWS S3 using Terraform

## Overview

This task deploys **Twenty CRM** on an AWS EC2 instance and configures **Amazon S3** as the persistent file storage backend. All infrastructure is provisioned using **Terraform** following best practices.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AWS (us-east-1)                  │
│                                                     │
│   ┌─────────────────────┐                          │
│   │   Default VPC        │                          │
│   │                     │                          │
│   │  ┌───────────────┐  │     ┌─────────────────┐ │
│   │  │  EC2 Instance  │  │     │    S3 Bucket     │ │
│   │  │  (t3.small)   │──┼────▶│  (File Storage)  │ │
│   │  │               │  │     │                  │ │
│   │  │  Docker        │  │     │  ✅ Versioning   │ │
│   │  │  Twenty CRM   │  │     │  ✅ Encryption   │ │
│   │  │  :2020        │  │     │  ✅ Block Public  │ │
│   │  └───────────────┘  │     └─────────────────┘ │
│   │         │           │                          │
│   │  EC2S3AccessRole    │                          │
│   └─────────────────────┘                          │
└─────────────────────────────────────────────────────┘
         ▲
         │
    User Browser
  http://<ip>:2020
```

---

## Infrastructure Components

| Resource | Details |
|---|---|
| **EC2 Instance** | `t3.small`, AMI `ami-0b6d9d3d33ba97d99`, Ubuntu |
| **S3 Bucket** | Versioning + AES256 Encryption + Block Public Access |
| **Security Group** | Ports 22 (SSH), 80 (HTTP), 2020 (Twenty CRM) |
| **IAM Role** | Existing `EC2S3AccessRole` attached to EC2 |
| **VPC** | Default VPC — no new VPC created |
| **Docker Image** | `twentycrm/twenty:latest` from Docker Hub |

---

## File Structure

```
terraform/
├── main.tf               # Provider configuration (AWS + Random)
├── vpc.tf                # Default VPC and subnet data sources
├── sg.tf                 # Security group with idempotent name_prefix
├── iam.tf                # Reference existing EC2S3AccessRole
├── s3.tf                 # S3 bucket with versioning, encryption, public access block
├── ec2.tf                # EC2 instance with IAM role and user_data
├── variables.tf          # All input variables
├── outputs.tf            # Useful outputs after apply
├── terraform.tfvars      # Variable values
├── user_data.sh.tpl      # Bootstrap script — installs Docker, runs Twenty CRM
└── .gitignore            # Excludes .terraform/, tfstate, tfvars
```

---

## Key Design Decisions

### Idempotent S3 Bucket Name
```hcl
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
locals {
  bucket_name = "${var.s3_bucket_name}-${random_id.bucket_suffix.hex}"
}
```
Random suffix prevents `BucketAlreadyExists` errors on re-apply.

### Idempotent Security Group
```hcl
resource "aws_security_group" "twenty_crm" {
  name_prefix = "${var.project_name}-sg-"
  lifecycle {
    create_before_destroy = true
  }
}
```
`name_prefix` prevents `InvalidGroup.Duplicate` errors on re-apply.

### EC2 waits for S3
```hcl
depends_on = [
  aws_s3_bucket.twenty_crm_storage,
  aws_s3_bucket_versioning.twenty_crm_storage,
  aws_s3_bucket_server_side_encryption_configuration.twenty_crm_storage,
  aws_s3_bucket_public_access_block.twenty_crm_storage
]
```
EC2 only starts after S3 bucket is fully configured.

### S3 as Storage Backend
Twenty CRM is configured via environment variables to use S3:
```bash
docker run -d \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="us-east-1" \
  -e STORAGE_S3_NAME="<bucket-name>" \
  twentycrm/twenty:latest
```

---

## Prerequisites

- Terraform `>= 1.5.0`
- AWS CLI configured with appropriate permissions
- EC2 Key Pair: `shubhamsingh-task07`
- Existing IAM Instance Profile: `EC2S3AccessRole`

---

## Usage

### 1. Clone and navigate
```bash
git clone https://github.com/shubhamsingh74888/devops-crm-project.git
cd devops-crm-project/terraform
```

### 2. Initialize
```bash
terraform init
```

### 3. Validate
```bash
terraform validate
# Expected: Success! The configuration is valid.
```

### 4. Plan
```bash
terraform plan
```

### 5. Apply
```bash
terraform apply -auto-approve
```

### 6. Access the app
```
http://<ec2_public_ip>:2020
```

### 7. Destroy
```bash
terraform destroy -auto-approve
```

---

## Outputs

| Output | Description |
|---|---|
| `ec2_public_ip` | Public IP of the EC2 instance |
| `ec2_instance_id` | EC2 instance ID |
| `app_url` | Direct URL to access Twenty CRM |
| `ssh_command` | SSH command to connect to EC2 |
| `s3_bucket_name` | S3 bucket name (with random suffix) |
| `s3_bucket_arn` | S3 bucket ARN |
| `vpc_id` | Default VPC ID used |

---

## Verification Commands

```bash
# Verify EC2 is running
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=shubham-singh-twenty-crm-ec2" \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}" \
  --output table

# Verify S3 versioning
aws s3api get-bucket-versioning \
  --bucket <bucket-name>

# Verify S3 encryption
aws s3api get-bucket-encryption \
  --bucket <bucket-name>

# Verify S3 public access block
aws s3api get-public-access-block \
  --bucket <bucket-name>

# SSH into EC2 and check Docker
ssh -i ~/.ssh/shubhamsingh-task07.pem ubuntu@<public-ip>
docker ps
cat /var/log/user-data.log
```

---

## How S3 and EC2 Work Together

```
User uploads file in Twenty CRM (running on EC2)
         │
         ▼
Twenty CRM reads STORAGE_TYPE=s3 env var
         │
         ▼
Sends file to S3 bucket using EC2S3AccessRole
(no hardcoded credentials needed)
         │
         ▼
File stored securely in S3:
  ✅ AES256 encrypted at rest
  ✅ Versioned (recoverable if deleted)
  ✅ No public access
  ✅ Survives EC2 termination
```

---

## Tags Applied to All Resources

```hcl
{
  Project     = "twenty-crm"
  Environment = "dev"
  ManagedBy   = "terraform"
  Owner       = "shubham-singh"
  Task        = "task-13"
}
```

---

## Author

**Shubham Singh**
MCA 2026 — Garden City University, Bangalore
Branch: `shubham-task-13`
