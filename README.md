# Task 14 — Terraform Modules (EC2, ECR, S3)

Refactors the Task 12/13 Terraform configuration into three reusable
modules — `ec2`, `ecr`, and `s3` — called from a single root
configuration, instead of one flat set of `.tf` files.

## Stack

- **Region:** us-east-1
- **Compute:** 1x EC2, `t3.small`, approved AMI (via `ec2` module)
- **Registry:** 1x ECR repository for the Twenty CRM image (via `ecr` module)
- **Storage:** 1x S3 bucket — versioning, AES-256 encryption, Block
  Public Access all enabled (via `s3` module)
- **IAM:** existing `EC2S3AccessRole` attached to the instance (no new
  IAM users/roles/policies created)
- **Network:** default VPC / default subnet (no new VPC)

## Repo layout

```
modules/
  ec2/
    variables.tf   # instance inputs (AMI, type, subnet, SG rules, etc.)
    main.tf        # security group + aws_instance resources
    outputs.tf     # instance_id, public_ip, public_dns, sg_id
  ecr/
    variables.tf   # repository name, scan/mutability settings
    main.tf        # aws_ecr_repository resource
    outputs.tf     # repository_url, repository_arn, repository_name
  s3/
    variables.tf   # bucket name, versioning/encryption/public-access flags
    main.tf        # bucket + versioning + encryption + public-access-block
    outputs.tf     # bucket_name, bucket_arn, bucket_id
versions.tf         # Terraform + AWS provider version constraints
variables.tf         # root-level inputs, shared across all modules
data.tf               # default VPC/subnet lookups
main.tf                 # calls module "ecr", module "s3", module "ec2"
outputs.tf               # surfaces each module's outputs
user_data.sh.tpl           # EC2 bootstrap script (Docker + app + S3/ECR env)
terraform.tfvars.example    # template for deployment-specific values
screenshots/                 # init/fmt/validate/plan proof
TASK14-DOCUMENTATION.md       # full write-up of the task
```

## Why modules

Each module is self-contained — its own `variables.tf` (inputs) and
`outputs.tf` (return values) — and knows nothing about the other
modules. The root `main.tf` is the only place that wires them
together: it calls each module with `source = "./modules/<name>"`,
passes in the required variables, and threads outputs between them
where needed (the EC2 module's `user_data` script is rendered using
`module.s3.bucket_name` and `module.ecr.repository_url`). Any of the
three modules could be reused as-is in a different root configuration
without modification.

## How to run

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in your own bucket name, branch, key pair
terraform init
terraform fmt
terraform validate
terraform plan
```

**`terraform apply` is intentionally not run for this task.**

## Verification performed

- `terraform init` — all three modules and the AWS provider initialized successfully
- `terraform fmt` — configuration reformatted to canonical style
- `terraform validate` — `Success! The configuration is valid.`
- `terraform plan` — `Plan: 7 to add, 0 to change, 0 to destroy`, with
  the S3 module correctly proposing versioning enabled and all four
  Block Public Access settings `true`

See `TASK14-DOCUMENTATION.md` for the full write-up and
`screenshots/` for proof of each command's output.
