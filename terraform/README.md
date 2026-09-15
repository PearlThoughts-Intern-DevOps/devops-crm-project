# DevOps CRM Project — Terraform Infrastructure

A fully automated AWS infrastructure deployment for the Twenty CRM application using Terraform, Docker, and ECR.

---

## Project Structure

```
terraform/
├── main.tf                  # Root — VPC, subnets, IGW, route tables, module calls
├── variables.tf             # All input variables (sensitive vars via env)
├── outputs.tf               # All root outputs
├── providers.tf             # AWS + random providers, version constraints
├── terraform.tfvars         # Non-sensitive variable values
├── user_data.sh.tpl         # EC2 bootstrap script (Terraform templatefile)
└── modules/
    ├── ec2/
    │   ├── main.tf          # Security group + EC2 instance (dynamic AMI lookup)
    │   ├── variables.tf     # All EC2 module inputs
    │   └── outputs.tf       # instance_id, public_ip, public_dns, sg_id, ami_id
    ├── ecr/
    │   ├── main.tf          # ECR repository + lifecycle policy
    │   ├── variables.tf     # repository_name, scan_on_push, max_image_count
    │   └── outputs.tf       # repository_url, repository_arn, docker_login_command
    └── s3/
        ├── main.tf          # S3 bucket + versioning + SSE + public access block + lifecycle
        ├── variables.tf     # bucket_name, versioning, sse_algorithm, lifecycle config
        └── outputs.tf       # bucket_name, bucket_arn, bucket_id, domain_name
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS ap-south-1                          │
│                                                              │
│  ┌───────────────────── VPC 10.0.0.0/16 ─────────────────┐  │
│  │                                                         │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │            Public Subnet 1 — 10.0.1.0/24 (AZ-a)  │  │  │
│  │  │                                                    │  │  │
│  │  │   ┌─────────────────────────────────────────┐     │  │  │
│  │  │   │         EC2 t3.small                     │     │  │  │
│  │  │   │         Ubuntu 22.04 LTS                 │     │  │  │
│  │  │   │         Twenty CRM :2020                 │     │  │  │
│  │  │   └─────────────────────────────────────────┘     │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                                                         │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │            Public Subnet 2 — 10.0.2.0/24 (AZ-b)  │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                                                         │  │
│  └─────────────────────────────────────┬───────────────────┘  │
│                                        │ IGW                   │
│  ┌──────────────────┐   ┌──────────────────────────────────┐  │
│  │       ECR        │   │         S3                        │  │
│  │  Private container│  │   Storage + Backups               │  │
│  │  registry        │   │                                   │  │
│  └──────────────────┘   └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured
- [Docker](https://docs.docker.com/get-docker/) installed
- AWS account with appropriate permissions
- An EC2 Key Pair created in `ap-south-1`

---

## Quick Start

### 1. Clone and configure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region          = "ap-south-1"
project_name        = "shubham-singh-twenty-crm"
instance_type       = "t3.small"
key_pair_name       = "instance1-key"        # No .pem extension
app_port            = 2020
vpc_cidr            = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview changes

```bash
terraform plan
```

### 4. Deploy infrastructure

```bash
terraform apply -auto-approve
```

### 5. Destroy infrastructure

```bash
terraform destroy -auto-approve
```

---

## Terraform Commands Reference

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize providers and modules |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Create or update infrastructure |
| `terraform apply -auto-approve` | Apply without confirmation prompt |
| `terraform destroy` | Destroy all managed resources |
| `terraform destroy -auto-approve` | Destroy without confirmation |
| `terraform show` | Show current state |
| `terraform state list` | List all resources in state |
| `terraform state show <resource>` | Show specific resource details |
| `terraform output` | Show all output values |
| `terraform validate` | Validate configuration files |
| `terraform fmt` | Format configuration files |
| `terraform refresh` | Sync state with real infrastructure |
| `terraform taint <resource>` | Force resource recreation on next apply |

---

## AWS Resources Created

| Resource | Details |
|----------|---------|
| VPC | 10.0.0.0/16 |
| Public Subnet 1 | 10.0.1.0/24 — ap-south-1a |
| Public Subnet 2 | 10.0.2.0/24 — ap-south-1b |
| Internet Gateway | Attached to VPC |
| Route Table | Public routes via IGW |
| Security Group | Ports 22, 80, 443, 2020 open |
| EC2 Instance | t3.small, Ubuntu 22.04 LTS |
| ECR Repository | Private container registry |
| S3 Bucket | Versioning + SSE-S3 encryption |
| IAM Role | EC2 instance profile for ECR access |

---

## Outputs

After `terraform apply`, you will see:

```
app_url              = "http://<EC2_PUBLIC_IP>:2020"
ec2_public_ip        = "<EC2_PUBLIC_IP>"
ec2_instance_id      = "i-xxxxxxxxxxxxxxxxx"
ecr_repository_url   = "<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/shubham-singh-twenty-crm"
docker_login_command = "aws ecr get-login-password --region ap-south-1 | docker login ..."
docker_tag_command   = "docker tag shubham-singh-twenty-crm:latest <ECR_URL>:latest"
docker_push_command  = "docker push <ECR_URL>:latest"
ssh_command          = "ssh -i ~/.ssh/instance1-key.pem ubuntu@<EC2_PUBLIC_IP>"
vpc_id               = "vpc-xxxxxxxxxxxxxxxxx"
public_subnet_1_id   = "subnet-xxxxxxxxxxxxxxxxx"
public_subnet_2_id   = "subnet-xxxxxxxxxxxxxxxxx"
```

---

## Docker Workflow

### Login to ECR

```bash
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com
```

### Build, Tag and Push

```bash
# Build
docker build -t shubham-singh-twenty-crm:latest .

# Tag
docker tag shubham-singh-twenty-crm:latest \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/shubham-singh-twenty-crm:latest

# Push
docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/shubham-singh-twenty-crm:latest
```

### SSH to EC2

```bash
ssh -i ~/.ssh/instance1-key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## Application Deployment

After infrastructure is up, SSH into EC2 and run:

```bash
# Copy files to EC2
scp -i ~/.ssh/instance1-key.pem \
  docker-compose.yml .env \
  ubuntu@<EC2_PUBLIC_IP>:~/

# SSH in
ssh -i ~/.ssh/instance1-key.pem ubuntu@<EC2_PUBLIC_IP>

# Start the full stack
cd ~
docker compose up db redis server worker -d

# Check status
docker compose ps
docker compose logs -f server
```

Access the app at: `http://<EC2_PUBLIC_IP>:2020`

Default login credentials:
- **Email:** `tim@apple.dev`
- **Password:** `tim@apple.dev`

---

## Environment Variables

Copy `.secrets.example` to `.secrets` and fill in values:

```bash
cp .secrets.example .secrets
```

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `TF_VAR_key_pair_name` | EC2 key pair name (without .pem) |

---

## Common Issues

### Key pair error
```
InvalidKeyPair.NotFound: The key pair 'instance1-key.pem' does not exist
```
**Fix:** Remove `.pem` from `key_pair_name` in `terraform.tfvars`

### SSH permission denied
```
Warning: Identity file instance1-key.pem not accessible
```
**Fix:** Always use full path: `ssh -i ~/.ssh/instance1-key.pem ubuntu@<IP>`

### Port 2020 not accessible
**Fix:** Verify security group allows inbound traffic on port 2020

---

## Author

**Shubham Singh** — DevOps Internship Task  
Project: Twenty CRM Infrastructure on AWS
