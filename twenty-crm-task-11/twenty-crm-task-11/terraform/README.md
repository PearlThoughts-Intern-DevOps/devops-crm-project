# Twenty CRM – AWS Terraform Configuration (Task 11)

Terraform configuration to provision the AWS infrastructure for the Twenty CRM
application: the default VPC/networking, an EC2 application server, and an
ECR repository for the container image.

## Project structure

```
terraform-crm/
├── main.tf                    # Terraform + AWS provider configuration
├── variables.tf                # All configurable input variables
├── vpc.tf                      # Data sources for the existing default VPC/subnets
├── ec2.tf                      # Security group + EC2 instance for the app
├── ecr.tf                      # ECR repository + lifecycle policy
├── outputs.tf                  # Outputs (VPC id, instance IP, ECR URL, etc.)
├── terraform.tfvars.example    # Example variable values (copy to terraform.tfvars)
├── .gitignore
└── README.md
```

## What it creates

- **VPC** – no new VPC is created. `vpc.tf` uses `data` sources to look up the
  AWS account's existing default VPC and its subnets in `us-east-1`, per the
  task requirement to reuse the existing/default setup.
- **EC2** – one application server (`aws_instance.app_server`) running the
  latest Amazon Linux 2023 AMI (looked up dynamically, not hardcoded), plus a
  security group that allows SSH (restricted by `ssh_allowed_cidr`) and the
  app port (`app_port`, default `3000`).
- **ECR** – one repository (`aws_ecr_repository.app_repo`) with image
  scanning on push and a lifecycle policy that expires old untagged images.

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured locally (`aws configure` or environment
  variables) with permissions for VPC (read), EC2, and ECR.

## Usage

```bash
cd terraform-crm

# 1. Copy the example vars and fill in your own values
cp terraform.tfvars.example terraform.tfvars

# 2. Initialize the working directory (downloads the AWS provider)
terraform init

# 3. Validate the configuration syntax
terraform validate
```

> Do **not** run `terraform plan` or `terraform apply` for this task — it is
> init/validate-only, per the task instructions.

## Notes

- All configurable values (region, instance type, key pair, ports, ECR name,
  tags, etc.) are exposed as variables in `variables.tf` — nothing is
  hardcoded in the resource files.
- `terraform.tfvars` is gitignored so real/sensitive values are never
  committed; only `terraform.tfvars.example` is tracked.
- A remote S3 backend block is stubbed out (commented) in `main.tf` if you
  want to move off local state later.
