# Task 14 — Terraform Modules: EC2, ECR, S3

Refactors the Twenty CRM infrastructure into reusable, production-grade
Terraform modules. All resources are defined as modules with their own
`variables.tf` and `outputs.tf`. The root module calls them and wires
everything together via `terraform.tfvars`.

---

## Project Structure

```plaintext
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

```plaintext
┌─────────────────────────────────────────────────────────┐
│                    AWS (ap-south-1)                     │
│                                                         │
│  ┌──────────────── VPC 10.0.0.0/16 ──────────────────┐ │
│  │                                                    │ │
│  │  ┌─────────────────────────────────────────────┐  │ │
│  │  │       Public Subnet 1 — 10.0.1.0/24 (AZ-a)  │  │ │
│  │  │                                             │  │ │
│  │  │   ┌─────────────────────────────────────┐  │  │ │
│  │  │   │        EC2 Instance (t3.small)       │  │  │ │
│  │  │   │        Ubuntu 22.04 LTS              │  │  │ │
│  │  │   │        Twenty CRM — port 2020        │  │  │ │
│  │  │   └─────────────────────────────────────┘  │  │ │
│  │  └─────────────────────────────────────────────┘  │ │
│  │                                                    │ │
│  │  ┌─────────────────────────────────────────────┐  │ │
│  │  │       Public Subnet 2 — 10.0.2.0/24 (AZ-b)  │  │ │
│  │  └─────────────────────────────────────────────┘  │ │
│  │                          │                         │ │
│  └──────────────────────────┼─────────────────────────┘ │
│                             │ IGW                       │
│  ┌──────────────────────────┴─────────────────────────┐ │
│  │  ECR — private container registry                  │ │
│  │  S3  — file storage + backups                      │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Modules

### `modules/ec2`

Creates a security group and an EC2 instance.

| Feature | Detail |
|---|---|
| AMI | Dynamic lookup — always latest Ubuntu 22.04 LTS (Canonical) |
| Security group | Dynamic `ingress_rules` variable — fully configurable |
| IMDSv2 | Enforced (`http_tokens = "required"`) |
| EBS | Encrypted gp3, configurable size |
| IAM | Accepts existing instance profile — does not create one |
| Idempotency | `lifecycle { ignore_changes = [ami] }` prevents replacement on AMI update |

**Key variables**

| Variable | Type | Description |
|---|---|---|
| `project_name` | string | Used in all resource names |
| `vpc_id` | string | VPC to launch into |
| `subnet_id` | string | Subnet for the instance |
| `instance_type` | string | e.g. `t3.small` |
| `key_pair_name` | string | Existing EC2 key pair |
| `iam_instance_profile` | string | Existing IAM profile name |
| `ingress_rules` | list(object) | Ports/CIDRs for security group |
| `user_data` | string | Bootstrap script content |
| `volume_size` | number | EBS size in GB |

**Outputs:** `instance_id`, `public_ip`, `public_dns`, `private_ip`, `security_group_id`, `ami_id_used`

---

### `modules/ecr`

Creates a private ECR repository with image scanning and lifecycle management.

| Feature | Detail |
|---|---|
| Encryption | AES256 at rest |
| Scan on push | Enabled — vulnerability scanning on every image push |
| Lifecycle policy | Keeps last N images — old images auto-expired |
| Region | Fetched dynamically via `data.aws_region.current` — no hardcoding |

**Key variables**

| Variable | Type | Description |
|---|---|---|
| `repository_name` | string | ECR repo name |
| `image_tag_mutability` | string | `MUTABLE` or `IMMUTABLE` |
| `scan_on_push` | bool | Enable vulnerability scanning |
| `max_image_count` | number | Images to retain (default: 10) |

**Outputs:** `repository_url`, `repository_arn`, `repository_name`, `registry_id`, `docker_login_command`

---

### `modules/s3`

Creates a private S3 bucket with versioning, encryption, and lifecycle rules.

| Feature | Detail |
|---|---|
| Unique name | `random_id` suffix appended — idempotent across deploys |
| Versioning | Enabled — protects against accidental deletion |
| Encryption | AES256 SSE with bucket key enabled |
| Public access | Fully blocked — all 4 public access block settings enabled |
| Lifecycle | Abort incomplete multipart uploads after 7 days |
| Lifecycle | Expire noncurrent versions after 30 days |

**Key variables**

| Variable | Type | Description |
|---|---|---|
| `bucket_name` | string | Base name (random suffix appended) |
| `force_destroy` | bool | Allow destroy even with objects |
| `versioning_enabled` | bool | Enable S3 versioning |
| `sse_algorithm` | string | `AES256` or `aws:kms` |
| `enable_lifecycle` | bool | Enable lifecycle rules |
| `noncurrent_version_expiry_days` | number | Days before old versions expire |

**Outputs:** `bucket_name`, `bucket_arn`, `bucket_id`, `bucket_regional_domain_name`

---

## `user_data.sh.tpl` — EC2 Bootstrap

The `user_data.sh.tpl` is a Terraform `templatefile` that runs on first EC2 boot. It:

1. Installs Docker
2. Fetches the public IP via IMDSv2 (token-based — secure)
3. Creates a Docker network
4. Starts PostgreSQL 16 and Redis 7 containers
5. Starts the Twenty CRM server container on port `2020`
6. Starts the Twenty CRM worker container
7. Logs everything to `/var/log/user-data.log`

**Template variables passed from `main.tf`**

| Variable | Source |
|---|---|
| `aws_region` | `var.aws_region` |
| `app_port` | `var.app_port` |
| `app_name` | `var.project_name` |
| `s3_bucket_name` | `module.s3.bucket_name` |
| `twenty_image` | `var.twenty_image` |
| `encryption_key` | `var.encryption_key` (sensitive) |
| `app_secret` | `var.app_secret` (sensitive) |
| `pg_password` | `var.pg_password` (sensitive) |

---

## Prerequisites

- Terraform `>= 1.5.0`
- AWS CLI configured with credentials for `ap-south-1`
- Existing EC2 key pair: `shubhamsingh-task07`

---

## Usage

### Step 1 — Clone and navigate

```bash
git clone https://github.com/<org>/devops-crm-project.git
cd devops-crm-project/terraform
```

### Step 2 — Export sensitive variables

```bash
export TF_VAR_pg_password="your-strong-db-password"
export TF_VAR_encryption_key="your-32-character-encryption-key"
export TF_VAR_app_secret="your-application-secret-key"
```

### Step 3 — Initialise

```bash
terraform init
```

### Step 4 — Format and validate

```bash
terraform fmt -recursive
terraform validate
```

Expected output:

Success! The configuration is valid.


### Step 5 — Plan

```bash
terraform plan -out=tfplan
```

### Step 6 — Apply (when ready)

```bash
# Task 14 requires: do NOT run apply
# When ready in a future task:
terraform apply "tfplan"
```

### Step 7 — Access the application

```bash
terraform output app_url
terraform output ssh_command
terraform output ecr_docker_login_command
```

---

## Inputs (`terraform.tfvars`)

| Variable | Value | Description |
|---|---|---|
| `aws_region` | `ap-south-1` | AWS region |
| `project_name` | `shubham-singh-twenty-crm` | Used in all resource names |
| `environment` | `dev` | Environment tag |
| `owner` | `shubham-singh` | Owner tag |
| `instance_type` | `t3.small` | EC2 instance type |
| `key_pair_name` | `shubhamsingh-task07` | EC2 key pair |
| `app_port` | `2020` | Twenty CRM port |
| `volume_size` | `20` | EBS size in GB |
| `twenty_image` | `twentycrm/twenty:v2.35.0` | Docker image |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR |
| `public_subnet_1_cidr` | `10.0.1.0/24` | Subnet 1 CIDR (AZ-a) |
| `public_subnet_2_cidr` | `10.0.2.0/24` | Subnet 2 CIDR (AZ-b) |

> Sensitive variables (`pg_password`, `encryption_key`, `app_secret`) are
> never stored in tfvars — always passed via `TF_VAR_*` environment variables.

---

## Outputs

| Output | Description |
|---|---|
| `ec2_instance_id` | EC2 instance ID |
| `ec2_public_ip` | EC2 public IP address |
| `ec2_public_dns` | EC2 public DNS hostname |
| `app_url` | Full URL to Twenty CRM application |
| `ssh_command` | Ready-to-use SSH command |
| `ecr_repository_url` | ECR URL for `docker push` |
| `ecr_docker_login_command` | Full ECR login command |
| `s3_bucket_name` | S3 bucket name with random suffix |
| `s3_bucket_arn` | S3 bucket ARN |
| `vpc_id` | VPC ID |
| `public_subnet_1_id` | Public subnet 1 ID |
| `public_subnet_2_id` | Public subnet 2 ID |
| `iam_instance_profile` | IAM instance profile in use |

---

## Production-Grade Practices

| Practice | Implementation |
|---|---|
| No hardcoded secrets | `sensitive = true` + `TF_VAR_*` env vars |
| No hardcoded AMI | `data "aws_ami"` dynamic lookup (Canonical) |
| No hardcoded region in ECR | `data "aws_region"` in ECR module |
| IMDSv2 enforced | `http_tokens = "required"` on EC2 |
| Encrypted storage | EBS `encrypted = true` + S3 AES256 SSE |
| S3 fully private | All 4 public access block settings enabled |
| Idempotent S3 names | `random_id` suffix — safe to re-plan |
| AMI drift protection | `lifecycle { ignore_changes = [ami] }` |
| SG replace safety | `lifecycle { create_before_destroy = true }` |
| ECR cost control | Lifecycle policy — expire images beyond last 10 |
| Dependency ordering | `depends_on` ensures IGW, S3, ECR ready before EC2 |
| Common tags | `merge(local.common_tags, {...})` on every resource |

---

## Destroy

```bash
terraform destroy
```

> S3 bucket will be fully deleted because `force_destroy = true`.
> Set `force_destroy = false` in `terraform.tfvars` to protect bucket contents.

---

## Author

**Shubham Singh** — MCA 2026 · Garden City University, Bangalore
Task 14 · DevOps CRM Project · Branch: `shubham-task-14`
