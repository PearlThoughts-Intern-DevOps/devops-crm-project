# Task 13 — Twenty CRM + AWS S3 using Terraform

Deploy Twenty CRM on AWS EC2 and configure Amazon S3 as the storage backend.
All infrastructure provisioned using Terraform in the KodeKloud AWS playground.

---

## 1. Overview

This Terraform project creates:

| Resource | Purpose |
|---|---|
| **Amazon S3 bucket** | Storage backend for Twenty CRM (Block Public Access + Versioning + SSE-S3) |
| **Security Group** | Allows SSH (22) and app traffic (2020) |
| **EC2 instance** (`twenty-crm-dev`) | Hosts Docker, Postgres 16, Redis 7, Twenty CRM |
| **IAM instance profile** `EC2S3AccessRole` | Grants EC2 access to S3 |

Uses the **existing default VPC** and the first available subnet —
no new VPC created, per task requirements.

On first boot, `user_data.sh.tpl` automatically:

1. Forces sshd up first
2. Adds 2 GB swap (t3.small has only 2 GB RAM)
3. Installs Docker, AWS CLI, OpenSSL, curl
4. Creates Docker network `twenty-net`
5. Starts Postgres 16 and Redis 7
6. Waits for the IAM role credentials from IMDS
7. Verifies S3 access with `aws s3 ls`
8. Pulls `twentycrm/twenty:latest` from Docker Hub
9. Starts Twenty CRM with `STORAGE_TYPE=s3` pointing at the Terraform-created bucket

---

## 2. Architecture

```
                ┌─────────────────────────────────────────────────────────┐
                │                     Default VPC                          │
                │  ┌───────────────────────────────────────────────────┐  │
                │  │             Subnet (auto-selected)                │  │
                │  │                                                   │  │
   Internet ────┼──┼──► Security Group (sg-*)                          │  │
     :22, :2020 │  │       ├── Port 22   ← allowed_ssh_cidr           │  │
                │  │       └── Port 2020 ← 0.0.0.0/0                   │  │
                │  │                                                   │  │
                │  │   EC2 (t3.small, 20 GiB gp3)                      │  │
                │  │   ├── IAM Profile: EC2S3AccessRole                │  │
                │  │   ├── User Data: user_data.sh.tpl                 │  │
                │  │   └── Docker network: twenty-net                  │  │
                │  │       ├── twenty-crm    (2020→3000)               │  │
                │  │       ├── twenty-db     (postgres:16)             │  │
                │  │       └── twenty-redis  (redis:7)                 │  │
                │  └───────────────────────────────────────────────────┘  │
                └───────────────────────────────┬─────────────────────────┘
                                                │
                                                │ S3 read/write via IAM role
                                                ▼
                                   ┌────────────────────────┐
                                   │  S3 Bucket             │
                                   │  Block Public Access ✓ │
                                   │  Versioning ✓          │
                                   │  SSE-S3 (AES256) ✓     │
                                   └────────────────────────┘
```

---

## 3. Project Structure

```
terraform/
├── provider.tf            # AWS + random providers
├── variables.tf           # Input variable declarations
├── terraform.tfvars       # Values for variables (gitignored)
├── vpc.tf                 # Default VPC + subnet data sources
├── s3.tf                  # S3 bucket + BPA + versioning + encryption
├── ec2.tf                 # Security Group + EC2 instance
├── user_data.sh.tpl       # Cloud-init bootstrap (Docker stack + S3)
├── outputs.tf             # Output values
└── README.md              # This file
```

---

## 4. Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with credentials (KodeKloud sandbox in this run)
- EC2 Key Pair (`sakhisurakhya-task13-key`)
- IAM instance profile `EC2S3AccessRole` with S3 access

---

## 5. Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region |
| `project_name` | `twenty-crm` | Used for naming/tags |
| `environment` | `dev` | Environment tag |
| `instance_type` | `t3.small` | EC2 instance type |
| `root_volume_size` | `20` | Root EBS volume in GiB |
| `key_pair_name` | *(required)* | EC2 Key Pair |
| `allowed_ssh_cidr` | `0.0.0.0/0` | CIDR allowed to SSH |
| `app_port` | `2020` | Host port for Twenty CRM |
| `iam_instance_profile` | `EC2S3AccessRole` | IAM role for S3 access |

Example `terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
project_name         = "twenty-crm"
environment          = "dev"
instance_type        = "t3.small"
root_volume_size     = 20
key_pair_name        = "sakhisurakhya-task13-key"
allowed_ssh_cidr     = "157.41.243.122/32"
app_port             = 2020
iam_instance_profile = "EC2S3AccessRole"
```

---

## 6. Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
terraform destroy -auto-approve
```

---

## 7. Verification

### 7.1 Terraform outputs

```
app_url              = "http://44.203.93.171:2020"
iam_instance_profile = "EC2S3AccessRole"
instance_id          = "i-0c060f822840f49d5"
instance_public_ip   = "44.203.93.171"
s3_bucket_arn        = "arn:aws:s3:::twenty-crm-dev-storage-b3510d55"
s3_bucket_name       = "twenty-crm-dev-storage-b3510d55"
s3_bucket_region     = "us-east-1"
security_group_id    = "sg-039fb3955f949f402"
subnet_id            = "subnet-0dbc21cf238ffad29"
vpc_id               = "vpc-011995cf3c1b7fa40"
```

### 7.2 S3 bucket configuration (AWS CLI)

```bash
aws s3api get-public-access-block --bucket $BUCKET
```
```json
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

```bash
aws s3api get-bucket-versioning --bucket $BUCKET
```
```json
{ "Status": "Enabled" }
```

```bash
aws s3api get-bucket-encryption --bucket $BUCKET
```
```json
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" },
            "BucketKeyEnabled": true
        }]
    }
}
```

### 7.3 IAM role attached

```bash
aws ec2 describe-instances --instance-ids i-0c060f822840f49d5 \
  --query "Reservations[0].Instances[0].IamInstanceProfile.Arn" --output text
```
```
arn:aws:iam::730335578330:instance-profile/EC2S3AccessRole
```

### 7.4 Application

Browser at `http://44.203.93.171:2020/objects/companies` → Twenty CRM dashboard loaded.

---

## 8. Issues Encountered and Resolutions

| # | Symptom | Root Cause | Resolution |
|---|---|---|---|
| 1 | `ec2:CreateSecurityGroup` explicitly denied in work account | IAM policy time-restriction after 6 PM | Switched to KodeKloud AWS Playground per Jayani ma'am's guidance |
| 2 | KodeKloud had no `EC2S3AccessRole` | KodeKloud provides `EC2-role` / `iampolicy_ravi` only | Created `EC2S3AccessRole` manually: `aws iam create-role`, attached `AmazonS3FullAccess`, created instance profile — per Jayani ma'am's instruction ("See if you can create?") |
| 3 | SSH `Connection refused` on EC2 | AMI generated SSH host keys slowly (t=304s in console output); sshd not yet listening | Not required for Task 13 — verification done via Terraform, AWS CLI, and browser |
| 4 | CloudShell used instance role, no `~/.aws/credentials` file | Expected CloudShell behavior | Created access key via Console → Security Credentials |
| 5 | Initial profile had wrong secret (`...LSH` vs `...LS`) | Manual copy error | Re-set with single-quoted secret from CSV download |

---

## 9. Cleanup

```bash
terraform destroy -auto-approve
```

Verification:
```bash
terraform state list       # empty
aws s3 ls | findstr twenty # no match
```

All 7 resources destroyed:
- random_id.bucket_suffix
- aws_s3_bucket.twenty_crm
- aws_s3_bucket_public_access_block.twenty_crm
- aws_s3_bucket_versioning.twenty_crm
- aws_s3_bucket_server_side_encryption_configuration.twenty_crm
- aws_security_group.twenty_crm
- aws_instance.twenty_crm

The IAM role `EC2S3AccessRole` and instance profile are **not** managed by this Terraform
(created manually due to KodeKloud's role constraints) and remain in the sandbox until
the session expires.

---

## 10. Notes for the Reviewer

- **KodeKloud substitution**: The task requires `EC2S3AccessRole`, which does not exist
  in the KodeKloud playground. Per Jayani ma'am's guidance, the role was created manually
  in KodeKloud with equivalent permissions (`AmazonS3FullAccess`) before `terraform apply`.
  Terraform's `iam_instance_profile` variable references it, and the attachment is verified
  via `aws ec2 describe-instances`.
- **AMI**: `ami-0b6d9d3d33ba97d99` (instructor-approved Ubuntu 26.04).
- **SSH not verified**: KodeKloud's Ubuntu 26.04 AMI generated SSH host keys very slowly
  on first boot (~5 min). Verification was completed through Terraform, AWS CLI, and the
  browser. SSH is not a Task 13 deliverable.

---

