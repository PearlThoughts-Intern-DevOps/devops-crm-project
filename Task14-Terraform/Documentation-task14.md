# Task 14: Terraform Modules — EC2, ECR, S3

**Author:** Vikash Yadav
**Branch:** `vikash-yadav-14`
**Repository:** devops-crm-project

## Objective

Refactor the existing flat Terraform configuration into reusable, modular Terraform code. Separate modules were created for EC2, ECR, and S3, each following the standard `variables.tf` / `main.tf` / `outputs.tf` pattern, and called from a root configuration driven by `terraform.tfvars`.

## Why Modularize?

The previous task's Terraform config (Task 13) declared all resources — the EC2 instance, the ECR repository, and the S3 bucket — directly in a single `main.tf`. This works but doesn't scale:

- Hardcoded values make the config hard to reuse across environments (dev/staging/prod).
- No separation of concerns — everything lives in one file.
- Cannot easily reuse the same EC2/ECR/S3 logic in a different project without copy-pasting the whole file.

Modules solve this by packaging each resource type into a self-contained, parameterized unit that accepts inputs (`variables.tf`) and exposes outputs (`outputs.tf`), while the actual resource logic lives in the module's own `main.tf`.

## Folder Structure

```
Task14-Terraform/
├── main.tf                # Root config — calls all three modules
├── variables.tf            # Root-level input variables
├── outputs.tf               # Root-level outputs (aggregated from modules)
├── provider.tf               # AWS provider + Terraform version constraints
├── terraform.tfvars           # Actual values fed into the root variables
├── .gitignore
└── modules/
    ├── ec2/
    │   ├── main.tf          # aws_instance resource
    │   ├── variables.tf      # ec2 module inputs (ami_id, instance_type, key_name, etc.)
    │   └── outputs.tf         # instance_id, public_ip, private_ip
    ├── ecr/
    │   ├── main.tf          # aws_ecr_repository resource
    │   ├── variables.tf      # ecr module inputs (repository_name, scan_on_push, etc.)
    │   └── outputs.tf         # repository_url, repository_arn, repository_name
    └── s3/
        ├── main.tf          # aws_s3_bucket + aws_s3_bucket_versioning resources
        ├── variables.tf      # s3 module inputs (bucket_name, versioning_enabled, etc.)
        └── outputs.tf         # bucket_id, bucket_arn, bucket_domain_name
```

## Module Breakdown

### EC2 Module (`modules/ec2`)

Provisions a single `aws_instance` resource.

**Inputs:** `ami_id`, `instance_type` (default `t2.micro`), `key_name`, `subnet_id`, `vpc_security_group_ids`, `instance_name`, `tags`

**Outputs:** `instance_id`, `public_ip`, `private_ip`

### ECR Module (`modules/ecr`)

Provisions an `aws_ecr_repository` with image scanning enabled on push.

**Inputs:** `repository_name`, `image_tag_mutability` (default `MUTABLE`), `scan_on_push` (default `true`), `tags`

**Outputs:** `repository_url`, `repository_arn`, `repository_name`

### S3 Module (`modules/s3`)

Provisions an `aws_s3_bucket` with versioning configured via a separate `aws_s3_bucket_versioning` resource (the modern AWS provider pattern, replacing the deprecated inline `versioning` block).

**Inputs:** `bucket_name`, `versioning_enabled` (default `true`), `force_destroy` (default `false`), `tags`

**Outputs:** `bucket_id`, `bucket_arn`, `bucket_domain_name`

## Root Configuration

The root `main.tf` calls all three modules with `source = "./modules/<name>"` and passes values sourced from root variables, which in turn are populated by `terraform.tfvars`. This keeps every environment-specific value in one place (`terraform.tfvars`) instead of scattered across resource blocks.

```hcl
module "ec2" {
  source = "./modules/ec2"
  ami_id = var.ami_id
  ...
}

module "ecr" {
  source = "./modules/ecr"
  repository_name = var.ecr_repository_name
  ...
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.s3_bucket_name
  ...
}
```

Root `outputs.tf` re-exposes key module outputs (EC2 instance ID/public IP, ECR repository URL, S3 bucket name) so they're visible at the top level without digging into module state.

## terraform.tfvars

Actual deployment values used for this task (region: `us-east-1`, matching the AWS account's existing subnets):

| Variable | Value |
|---|---|
| `aws_region` | `us-east-1` |
| `ami_id` | Amazon Linux 2 AMI, looked up via `aws ec2 describe-images` |
| `instance_type` | `t2.micro` |
| `key_name` | `vikash-yadav` |
| `subnet_id` | Existing subnet from account (`us-east-1a`) |
| `vpc_security_group_ids` | Existing security group from account |
| `ecr_repository_name` | `vikash-yadav-devops-crm-ecr` |
| `s3_bucket_name` | `vikash-yadav-devops-crm-bucket-task14` |
| `environment` | `dev` |

No AWS credentials are stored in `terraform.tfvars` — authentication is handled entirely via AWS CLI credentials (`aws configure`), which the AWS provider picks up automatically from `~/.aws/credentials`.

## Commands Run

Executed inside `Task14-Terraform/`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

| Command | Result |
|---|---|
| `terraform init` | Initialized successfully; AWS provider and all three local modules loaded |
| `terraform fmt -recursive` | Formatting applied across root and module files |
| `terraform validate` | `Success! The configuration is valid.` |
| `terraform plan` | `Plan: 3 to add, 0 to change, 0 to destroy` (1 EC2 instance, 1 ECR repository, 1 S3 bucket) |

**`terraform apply` was intentionally NOT run**, per task instructions — this task covers planning and validation of the modular structure only, not actual provisioning.

## Environment Setup Notes

- Terraform CLI installed via Chocolatey (`choco install terraform -y`) on Windows — version `1.16.2`.
- AWS CLI credentials configured via `aws configure`, verified with `aws sts get-caller-identity`.
- AMI ID, subnet ID, and security group ID were looked up directly from the AWS account using:
  ```bash
  aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' --output text
  aws ec2 describe-subnets --query 'Subnets[*].{ID:SubnetId,AZ:AvailabilityZone}' --output table
  aws ec2 describe-security-groups --query 'SecurityGroups[*].{ID:GroupId,Name:GroupName}' --output table
  aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table
  ```

## Git Workflow

```bash
git checkout main
git pull origin main
git checkout -b vikash-yadav-14

# after creating/verifying all module and root files
git add main.tf variables.tf outputs.tf provider.tf terraform.tfvars modules/ .gitignore
git commit -m "Task 14: Refactor Terraform config into reusable EC2, ECR, S3 modules"
git push origin vikash-yadav-14
```

## Pull Request

- **Base branch:** `main`
- **Compare branch:** `vikash-yadav-14`
- **Title:** Task 14: Terraform Modules (EC2, ECR, S3)
- PR description includes a summary of the module structure, verification command outputs, and confirmation that `terraform apply` was not run.

## Key Learnings

- Terraform modules separate **interface** (variables/outputs) from **implementation** (resource logic), making the same module reusable across environments by simply changing `terraform.tfvars`.
- `terraform.tfvars` is unrelated to cloud authentication — AWS credentials live in `~/.aws/credentials` via the AWS CLI, while `.tfvars` only supplies resource configuration values.
- The AWS provider's `aws_s3_bucket_versioning` resource is the current recommended approach over the deprecated inline `versioning` block on `aws_s3_bucket`.
- Real infrastructure values (AMI IDs, subnet IDs, security group IDs) should be looked up directly against the target AWS account rather than assumed, since these are account- and region-specific.