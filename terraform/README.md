# Task 13: Twenty CRM + AWS S3 using Terraform

## Overview

Deploys **Twenty CRM** on AWS EC2 with **Amazon S3** as the persistent file storage backend. All infrastructure provisioned using **Terraform**.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AWS (us-east-1)                  │
│                                                     │
│   ┌─────────────────────┐                          │
│   │    Default VPC       │                          │
│   │                     │                          │
│   │  ┌───────────────┐  │     ┌─────────────────┐ │
│   │  │  EC2 Instance  │  │     │    S3 Bucket     │ │
│   │  │  (t3.small)   │──┼────▶│  (File Storage)  │ │
│   │  │               │  │     │                  │ │
│   │  │  Docker        │  │     │  ✅ Versioning   │ │
│   │  │  ├─ postgres   │  │     │  ✅ Encryption   │ │
│   │  │  ├─ redis      │  │     │  ✅ Block Public  │ │
│   │  │  ├─ crm:2020   │  │     └─────────────────┘ │
│   │  │  └─ worker     │  │                          │
│   │  └───────────────┘  │                          │
│   │    EC2S3AccessRole  │                          │
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
| **IAM Role** | Existing `EC2S3AccessRole` attached to EC2 (not created) |
| **VPC** | Default VPC — no new VPC created |
| **Docker** | postgres:16-alpine, redis:7-alpine, twentycrm/twenty:v2.35.0 |

---

## File Structure

```
terraform/
├── providers.tf          # Terraform version + AWS + Random provider config
├── variables.tf          # All input variables with defaults
├── outputs.tf            # Useful values after terraform apply
├── vpc.tf                # Default VPC and subnet (data sources only)
├── sg.tf                 # Security group (idempotent via name_prefix)
├── iam.tf                # Reference existing EC2S3AccessRole (not created)
├── s3.tf                 # S3 bucket with versioning, encryption, public block
├── ec2.tf                # EC2 instance with IAM role + user_data
├── user_data.sh.tpl      # Bootstrap: installs Docker, starts all containers
├── terraform.tfvars      # Variable values (gitignored — do not commit)
└── .gitignore            # Excludes .terraform/, *.tfstate, *.tfvars
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

### EC2 waits for S3 to be fully configured
```hcl
depends_on = [
  aws_s3_bucket.twenty_crm_storage,
  aws_s3_bucket_versioning.twenty_crm_storage,
  aws_s3_bucket_server_side_encryption_configuration.twenty_crm_storage,
  aws_s3_bucket_public_access_block.twenty_crm_storage
]
```

### S3 as Storage Backend
```bash
docker run -d \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="us-east-1" \
  -e STORAGE_S3_NAME="<bucket-name>" \
  twentycrm/twenty:v2.35.0
```

### IMDSv2 for Public IP (secure)
```bash
# Get token first (SSRF-safe)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token to get public IP
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)
```
Uses IMDSv2 (not IMDSv1) to securely fetch the EC2 public IP at boot time.
Required for `SERVER_URL` so Twenty CRM knows its own public address.

### IAM — No credentials in script
```
EC2S3AccessRole is attached to the EC2 instance.
Docker containers inherit EC2 IAM permissions automatically.
No hardcoded AWS keys anywhere.
```

---

## Docker Containers on EC2

| Container | Image | Purpose |
|---|---|---|
| `twenty-db` | `postgres:16-alpine` | Database |
| `twenty-redis` | `redis:7-alpine` | Cache + job queue |
| `twenty-server` | `twentycrm/twenty:v2.35.0` | CRM app (port 2020) |
| `twenty-worker` | `twentycrm/twenty:v2.35.0` | Background job processor |

All containers run on a shared `twenty-network` Docker bridge network.

---

## Prerequisites

- Terraform `>= 1.5.0`
- AWS CLI configured with appropriate permissions
- EC2 Key Pair: `shubhamsingh-task07` must exist in `us-east-1`
- IAM Instance Profile `EC2S3AccessRole` must exist in AWS account

---

## Usage

### 1. Clone and navigate
```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project/terraform
git checkout shubham-task-13
```

### 2. Create terraform.tfvars
```bash
cat > terraform.tfvars << 'TFVARS'
pg_password    = "your-strong-password"
encryption_key = "$(openssl rand -hex 16)"
app_secret     = "$(openssl rand -hex 16)"
TFVARS
```

### 3. Initialize
```bash
terraform init
```

### 4. Validate
```bash
terraform validate
# Expected: Success! The configuration is valid.
```

### 5. Plan
```bash
terraform plan
```

### 6. Apply
```bash
terraform apply -auto-approve
```

### 7. Wait ~3 minutes, then access
```
http://<ec2_public_ip>:2020
```

### 8. Destroy after testing
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
# Get outputs
terraform output

# Verify EC2 is running
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=shubham-singh-twenty-crm-ec2" \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}" \
  --output table

# Verify S3 versioning
aws s3api get-bucket-versioning \
  --bucket $(terraform output -raw s3_bucket_name)

# Verify S3 encryption
aws s3api get-bucket-encryption \
  --bucket $(terraform output -raw s3_bucket_name)

# Verify S3 public access block
aws s3api get-public-access-block \
  --bucket $(terraform output -raw s3_bucket_name)

# SSH into EC2
ssh -i ~/.ssh/shubhamsingh-task07.pem ubuntu@$(terraform output -raw ec2_public_ip)

# Check containers running (run after SSH)
docker ps

# Check bootstrap log (run after SSH)
cat /var/log/user-data.log
```

---

## How S3 and EC2 Work Together

```
User uploads file in Twenty CRM (EC2:2020)
         │
         ▼
Twenty CRM reads STORAGE_TYPE=s3
         │
         ▼
Sends file to S3 via EC2S3AccessRole
(no hardcoded credentials)
         │
         ▼
File stored in S3:
  ✅ AES256 encrypted at rest
  ✅ Versioned (recoverable if deleted)
  ✅ Private (no public access)
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
GitHub: [shubhamsingh74888](https://github.com/shubhamsingh74888)
Branch: `shubham-task-13`
