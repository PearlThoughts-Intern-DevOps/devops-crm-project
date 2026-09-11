# Task 14 — Terraform Modules

## Objective

Refactor the existing Terraform configuration into reusable and properly structured Terraform modules.

The infrastructure was divided into three reusable modules:

* EC2
* ECR
* S3

The modules are called from the root Terraform configuration and values are managed using `terraform.tfvars`.

---

## Branch

Created a dedicated Git branch for Task 14:

```text
tannu-task-14
```

---

## Project Structure

The Terraform configuration was reorganized into the following structure:

```text
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── .terraform.lock.hcl
│
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecr/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# 1. EC2 Module

A reusable EC2 module was created under:

```text
modules/ec2/
```

### `variables.tf`

The module accepts the following configurable values:

* AMI ID
* Instance type
* Key pair
* Subnet ID
* Security Group ID
* IAM Instance Profile
* Project name
* AWS region
* S3 bucket name

### `main.tf`

The EC2 module:

* Uses the configured Amazon Linux AMI.
* Creates a `t3.small` EC2 instance.
* Uses the existing subnet.
* Uses the existing security group.
* Uses the existing IAM instance profile.
* Configures a 20 GB `gp3` root volume.
* Installs Docker, AWS CLI and required packages.
* Configures swap memory.
* Runs Twenty CRM using Docker.
* Runs PostgreSQL and Redis containers.
* Configures Twenty CRM to use S3 storage.
* Starts the Twenty CRM worker container.

The S3 bucket name and AWS region are passed into the module through variables.

### `outputs.tf`

The EC2 module exposes:

* EC2 instance ID
* Public IP
* Public DNS

---

# 2. ECR Module

A reusable ECR module was created under:

```text
modules/ecr/
```

### `variables.tf`

The module accepts:

* ECR repository name
* Project name

### `main.tf`

The ECR module creates an ECR repository with:

* Mutable image tags
* Image scanning enabled on push
* Project-based tags

### `outputs.tf`

The module exposes:

* Repository URL
* Repository ARN
* Repository name

---

# 3. S3 Module

A reusable S3 module was created under:

```text
modules/s3/
```

### `variables.tf`

The module accepts:

* S3 bucket name
* Project name

### `main.tf`

The S3 module creates a bucket with:

* Public access blocked
* Versioning enabled
* AES256 server-side encryption enabled

The following public access settings are enabled:

```hcl
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

### `outputs.tf`

The module exposes:

* S3 bucket name
* S3 bucket ARN

---

# 4. Root Terraform Configuration

The root `main.tf` was refactored to call the reusable modules.

The root configuration now uses:

```hcl
module "s3"
module "ecr"
module "ec2"
```

The S3 module output is passed to the EC2 module:

```hcl
s3_bucket_name = module.s3.bucket_name
```

This allows the EC2 module to use the S3 bucket created by the S3 module.

The ECR module is also called independently from the root configuration.

---

# 5. Terraform Variables

The root `variables.tf` was updated to define the values required by the modules.

These include:

* AWS region
* Project name
* EC2 instance type
* VPC ID
* Subnet ID
* S3 bucket name
* AMI ID
* Key pair name
* Security group ID
* IAM instance profile
* ECR repository name

---

# 6. Terraform tfvars

Infrastructure-specific values were moved into:

```text
terraform.tfvars
```

This includes values such as:

```hcl
aws_region
project_name
instance_type
subnet_id
s3_bucket_name
ami_id
key_name
security_group_id
iam_instance_profile
ecr_repository_name
```

This keeps the Terraform modules reusable instead of hardcoding environment-specific values inside the modules.

---

# 7. Removed Old S3 Configuration

The previous root-level:

```text
s3.tf
```

file was removed because S3 resources are now managed by:

```text
modules/s3/main.tf
```

This prevents duplicate S3 resource definitions.

---

# 8. Terraform Initialization

Terraform was initialized after creating the modules.

Command:

```bash
terraform init
```

Result:

```text
Terraform has been successfully initialized!
```

Terraform successfully detected and initialized:

```text
module.s3
module.ec2
module.ecr
```

---

# 9. Terraform Formatting

Terraform files were formatted recursively using:

```bash
terraform fmt -recursive
```

The command completed successfully.

---

# 10. Terraform Validation

The Terraform configuration was validated using:

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

---

# 11. Terraform Plan

A Terraform plan was generated using:

```bash
terraform plan
```

The plan completed successfully.

Terraform planned:

```text
Plan: 6 to add, 0 to change, 0 to destroy.
```

The planned resources were:

### EC2

```text
module.ec2.aws_instance.twenty_crm
```

### ECR

```text
module.ecr.aws_ecr_repository.this
```

### S3

```text
module.s3.aws_s3_bucket.this
module.s3.aws_s3_bucket_public_access_block.this
module.s3.aws_s3_bucket_server_side_encryption_configuration.this
module.s3.aws_s3_bucket_versioning.this
```

The plan also confirmed that the module outputs are correctly connected to the root outputs.

---

# 12. Verification Summary

The following Terraform workflow was completed:

```text
terraform init
        ↓
terraform fmt -recursive
        ↓
terraform validate
        ↓
terraform plan
```

Results:

```text
terraform init      → Successful
terraform fmt       → Successful
terraform validate  → Success
terraform plan      → 6 to add, 0 to change, 0 to destroy
```

No unexpected resource destruction was planned.

---

# Important Note

As required by Task 14:

```bash
terraform apply
```

was **NOT** executed.

Only Terraform initialization, formatting, validation and planning were performed.
