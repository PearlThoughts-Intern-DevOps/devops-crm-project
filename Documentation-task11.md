# Task 11 — Terraform Preparation Documentation

**Project:** Twenty CRM (devops-crm-project)
**Branch:** `vikash-yadav-task11`
**Author:** Vikash Yadav
**Scope:** Prepare and validate Terraform configuration for VPC (default), EC2, and ECR — no `terraform apply`

---

## 1. Objective

Prepare a clean, reusable Terraform project that describes the AWS
infrastructure needed to run Twenty CRM:

- Reuse the account's **existing/default VPC** (no new VPC created)
- An **EC2** instance to host the application
- An **ECR** repository to store the application's container image

The task is scoped to preparation and validation only: `terraform init`,
`terraform validate`, and `terraform plan` must succeed, but
`terraform apply` is intentionally never run.

---

## 2. Environment used

| Item | Value |
|---|---|
| OS | Ubuntu 22.04 (fresh EC2 instance) |
| Terraform version | v1.16.1 |
| AWS CLI | v2 (official installer) |
| AWS region | us-east-1 |
| AWS account | 961913816082 |
| IAM user | kk_labs_user_466059 |

---

## 3. Setup steps performed

1. Installed AWS CLI v2 on the fresh EC2 instance.
2. Created an IAM access key (Console → IAM → Users → Security credentials → Create access key → CLI use case).
3. Ran `aws configure` with the access key, secret key, region `us-east-1`, output format `json`.
4. Verified authentication with `aws sts get-caller-identity`.
5. Installed Terraform v1.16.1 via HashiCorp's official apt repository.
6. Cloned `devops-crm-project` and created branch `vikash-yadav-task11`.
7. Created the `terraform/twenty-crm-infra/` directory and added all configuration files.
8. Filled in `terraform.tfvars` with real values (key pair name, allowed SSH CIDR, instance type, AMI ID).
9. Ran `terraform init`, `terraform validate`, `terraform fmt -check -recursive`, and `terraform plan`.

---

## 4. Issue encountered and fix

**Issue:** The `data "aws_ami" "ubuntu"` data source (filtering AMIs by
Canonical's owner ID `099720074101`) returned "Your query returned no
results" during `terraform plan`, even though the rest of the plan
(VPC/subnet lookups, ECR, security group) succeeded.

**Diagnosis:** This sandbox/training AWS account restricts or behaves
differently on certain cross-account AMI describe calls made through the
Terraform AWS provider's data source, even though the same account can
describe images directly via the AWS CLI.

**Fix:** Resolved a current Ubuntu 22.04 AMI ID directly using the AWS CLI:

```bash
aws ec2 describe-images \
  --owners 099720074101 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table \
  --region us-east-1
```

This returned `ami-0fc339630ba87993b` (Ubuntu 22.04, built 2026-09-04),
which was set explicitly as `ami_id` in `terraform.tfvars`. The
`ec2.tf` configuration was already written to support this override via:

```hcl
count = var.ami_id == "" ? 1 : 0
```

so passing a real `ami_id` skips the failing data source lookup entirely
and the plan resolved cleanly.

---

## 5. Final `terraform plan` result

```
Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_id    = (known after apply)
  + ec2_public_dns     = (known after apply)
  + ec2_public_ip      = (known after apply)
  + ecr_repository_arn = (known after apply)
  + ecr_repository_url = (known after apply)
  + security_group_id  = (known after apply)
  + subnet_id          = "subnet-093ffb3acb1e377d4"
  + vpc_id             = "vpc-067ed4a858da66a3a"
```

Resources planned for creation:
- `aws_ecr_repository.twenty_crm`
- `aws_ecr_lifecycle_policy.twenty_crm`
- `aws_security_group.twenty_crm_sg`
- `aws_instance.twenty_crm`

`terraform apply` was **not** run, per task instructions.

---

## 6. Project README (`terraform/twenty-crm-infra/README.md`)

> The section below is the exact content of the project's own README file,
> included here for a single point of reference.

### Task 11 — Terraform Preparation (Twenty CRM Infrastructure)

Terraform configuration that prepares the AWS infrastructure for the Twenty
CRM application: the existing default VPC, an EC2 instance, and an ECR
repository. This task only **prepares and validates** the configuration —
`terraform apply` is intentionally not run.

#### Project structure

```
twenty-crm-infra/
├── provider.tf                  # Terraform + AWS provider config (us-east-1)
├── variables.tf                 # All configurable inputs
├── vpc.tf                       # Data sources for the existing default VPC/subnet
├── security_group.tf            # Security group for the EC2 instance
├── ec2.tf                       # EC2 instance + AMI lookup
├── ecr.tf                       # ECR repository + lifecycle policy
├── outputs.tf                   # Useful values exposed after apply
├── terraform.tfvars.example     # Sample variable values (copy to terraform.tfvars)
└── .gitignore                   # Keeps state/secrets out of git
```

#### Design decisions

- **VPC**: No new VPC is created. `data "aws_vpc" "default"` and
  `data "aws_subnets" "default"` pull in the account's existing default
  VPC/subnets, per the task's scope of only touching VPC "where
  applicable".
- **EC2**: A single `aws_instance` is launched into a default subnet, with
  a dedicated security group (SSH, HTTP, and the Twenty CRM app port). The
  AMI is auto-resolved to the latest Ubuntu 22.04 LTS image unless you pass
  `ami_id` explicitly.
- **ECR**: A single `aws_ecr_repository` is defined to hold the Twenty CRM
  container image, with vulnerability scan-on-push enabled and a lifecycle
  policy that expires untagged images after 14 days.
- **Variables over hardcoding**: region, instance type, AMI, key pair,
  ports, volume size, ECR settings, and tags are all variables with
  sensible defaults (see `variables.tf` / `terraform.tfvars.example`).
- **Outputs**: VPC/subnet/security-group IDs, EC2 instance ID/public
  IP/DNS, and the ECR repository URL/ARN are all exposed as outputs for
  use in later tasks (e.g. pushing images, SSH-ing in).

#### Prerequisites

- Terraform >= 1.5.0
- AWS credentials configured locally (`aws configure`, or environment
  variables `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
- An existing EC2 key pair in `us-east-1` (pass its name as `key_pair_name`)

#### Usage

```bash
cd twenty-crm-infra

# 1. Copy and edit the example variables file
cp terraform.tfvars.example terraform.tfvars
# then edit terraform.tfvars: set key_pair_name and allowed_ssh_cidr at minimum

# 2. Initialize Terraform (downloads the AWS provider)
terraform init

# 3. Validate the configuration syntax/internal consistency
terraform validate

# 4. Format check (optional but good practice)
terraform fmt -check -recursive

# 5. Generate an execution plan (no resources are created)
terraform plan
```

`terraform apply` is deliberately **not** run as part of this task.

#### Notes / issues encountered

See Section 4 above — the `data "aws_ami" "ubuntu"` lookup returned no
results in this sandbox account; worked around by resolving and passing a
real AMI ID explicitly via `ami_id`.

---

## 7. Submission checklist

- [x] Terraform project structure created
- [x] AWS provider configured for `us-east-1`
- [x] VPC (default/existing), EC2, and ECR resources defined
- [x] Variables used for all configurable values
- [x] Outputs defined for key resource information
- [x] `terraform init` succeeded
- [x] `terraform validate` succeeded
- [x] `terraform plan` generated successfully (4 to add, 0 errors)
- [x] `terraform apply` **not** run
- [ ] Branch `vikash-yadav-task11` pushed to `devops-crm-project`
- [ ] PR raised in `devops-crm-project`.