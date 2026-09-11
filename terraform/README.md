# Task 14: Reusable Terraform Modules

This Terraform configuration refactors the existing Twenty CRM AWS
infrastructure into reusable EC2, ECR, and S3 modules.

The configuration uses the account's existing default VPC, a default subnet,
an existing EC2 key pair, and an existing IAM instance profile. Terraform does
not create or manage the VPC, subnet, key pair, IAM role, or IAM instance
profile.

Terraform Apply was intentionally not run for Task 14.

## Directory Structure

```text
terraform/
├── main.tf
├── provider.tf
├── versions.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── vpc.tf
├── security-group.tf
├── terraform.tfvars
├── terraform.tfvars.example
├── user-data.sh.tftpl
├── docker-compose.yml.tftpl
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecr/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Responsibilities

### EC2 module

The EC2 module manages the Twenty CRM instance. It accepts the AMI, instance
type, subnet, security groups, public IP setting, key pair, IAM instance
profile, root volume size, rendered User Data, and tags.

The module preserves the existing encrypted gp3 root volume, IMDSv2
requirement, User Data behavior, and replacement when User Data changes.

It exposes the instance ID, public IP, private IP, and public DNS name.

### ECR module

The ECR module restores and modularizes the repository configuration used in
Task 12. It uses immutable image tags, scan-on-push, AES-256 encryption, and
protection against deleting a repository that still contains images.

It exposes the repository URL, name, and ARN.

### S3 module

The S3 module manages the bucket used by Twenty CRM. It preserves Block Public
Access, versioning, AES-256 server-side encryption, configurable
`force_destroy`, and tags.

It exposes the bucket ID, name, and ARN.

## Root Configuration

The root `main.tf` calls the three modules using local source paths:

```hcl
module "ec2" {
  source = "./modules/ec2"
}

module "ecr" {
  source = "./modules/ecr"
}

module "s3" {
  source = "./modules/s3"
}
```

For example, `source = "./modules/ec2"` tells Terraform to load the EC2
module from the local `modules/ec2` directory.

Root variables receive environment-specific values from `terraform.tfvars`
and pass them into the modules. Root outputs access module results with
references such as:

```hcl
module.ec2.instance_id
module.ecr.repository_url
module.s3.bucket_name
```

The existing VPC and subnet lookups remain in the root configuration because
they are shared inputs. The security group also remains in the root and its ID
is passed to the EC2 module.

## Configurable Values

Local environment values are stored in `terraform.tfvars`. This file is
ignored by Git and must not contain AWS access keys or application secrets.

`terraform.tfvars.example` is the safe, committed template for the required
inputs. Task 14 added configurable values for public IP association, ECR
settings, S3 versioning, S3 encryption, and S3 destruction behavior.

## Preserved Functionality

- The application continues to use the existing default VPC and selected
  default subnet.
- EC2 continues to use the existing key pair and IAM instance profile.
- The Twenty CRM Docker Compose and User Data templates remain unchanged.
- The EC2 instance still depends on the S3 module so bucket configuration is
  completed first.
- S3 remains private, versioned, and encrypted.
- ECR uses the security settings from the earlier Task 12 configuration.
- Common resource tags now identify Task 14.

## Issues Encountered and Resolutions

### 1. VS Code save conflict in `variables.tf`

**Issue:** VS Code reported that the file on disk was newer than the unsaved
editor copy. Overwriting the file would also have removed several existing
Task 13 validation blocks.

**Resolution:** The validated on-disk version was preserved, the new Task 14
variables were appended to it, and VS Code was reloaded using `File: Revert
File`. This retained all previous validations while adding the module inputs.

### 2. Module files did not appear in the first directory listing

**Issue:** `find` was initially run with `-maxdepth 2`. Module files such as
`modules/ec2/main.tf` are three levels below the Terraform directory, so they
were not displayed.

**Resolution:** The directory check was repeated with:

```bash
find . -maxdepth 3 -type f -not -path './.terraform/*' | sort
```

This displayed all nine module files.

### 3. Duplicate resource risk during the refactor

**Issue:** After adding the module calls, the original root `ec2.tf` and
`s3.tf` resources would have represented duplicate EC2 and S3 resources if
they had remained in the configuration.

**Resolution:** Root outputs were changed to use module outputs, and the old
root `ec2.tf` and `s3.tf` files were removed. The resource implementations now
exist only inside their respective modules.

### 4. Empty local Terraform state

**Issue:** The local state contained no managed resources, so Terraform could
not report existing root resources as state moves into the modules.

**Resolution:** No state migration was required. The plan was reviewed as a
fresh creation plan and confirmed that it contained no changes or destroys.
No apply was performed.

### 5. Terraform plan note about the `-out` option

**Issue:** Terraform noted that the plan was not saved with `-out`.

**Resolution:** This was expected because Task 14 specifically required the
plain `terraform plan` command. It is informational and not an error or
warning.

## Terraform Workflow

The following commands were run from the `terraform/` directory:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

`terraform apply` must not be run for Task 14.

## Validation Results

Task 14 was validated on September 11, 2026.

- `terraform init` discovered all three local modules and successfully reused
  the locked AWS provider version `v6.63.0`.
- `terraform fmt -recursive` formatted `main.tf` and the ignored local
  `terraform.tfvars` file.
- `terraform validate` returned `Success! The configuration is valid.`
- `terraform plan` returned `Plan: 10 to add, 0 to change, 0 to destroy.`

The plan included one EC2 instance, one ECR repository, one S3 bucket with
three S3 configuration resources, one security group, and three security-group
rules. All planned infrastructure actions were creates; there were no destroy
or replacement actions.

## Safety and Git Hygiene

The following local artifacts are ignored and must not be committed:

- `terraform.tfvars`
- `.terraform/`
- `*.tfstate`
- `*.tfstate.*`
- `*.tfplan`

The work was completed on branch `chirag-task-14`. No AWS infrastructure was
created or changed because `terraform apply` was not run.
