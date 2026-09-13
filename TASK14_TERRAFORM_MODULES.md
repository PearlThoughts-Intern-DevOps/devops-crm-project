# Task 14: Terraform Modules

## Objective

Refactor the existing Terraform configuration (from Tasks 12 and 13)
into reusable modules for EC2, ECR, and S3, without running
`terraform apply`.

## Module Structure

```
terraform/
├── main.tf                 # Root config: calls all three modules
├── variables.tf             # Root-level input variables
├── outputs.tf                # Root-level outputs
├── provider.tf
├── versions.tf
├── data.tf                   # Default VPC/subnet/SG + existing IAM instance profile
├── terraform.tfvars          # Actual values (gitignored)
├── terraform.tfvars.example
├── templates/
│   └── user_data.sh.tpl      # EC2 bootstrap script
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

Each module is self-contained: it declares its own inputs
(`variables.tf`), its own resources (`main.tf`), and its own outputs
(`outputs.tf`), with no hardcoded values — everything configurable is
passed in from the root module.

## How the Root Config Wires Everything Together

```hcl
module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  owner           = var.owner
  environment     = var.environment
}

resource "aws_eip" "twenty" {
  domain = "vpc"
  tags   = { ... }
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  subnet_id                 = data.aws_subnets.default_vpc.ids[0]
  security_group_id         = data.aws_security_group.default.id
  key_name                  = var.key_name
  iam_instance_profile_name = data.aws_iam_instance_profile.s3_access.name
  eip_allocation_id         = aws_eip.twenty.id
  project_name              = var.project_name
  owner                     = var.owner
  environment               = var.environment

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region  = var.aws_region
    bucket_name = module.s3.bucket_name
    server_url  = "http://${aws_eip.twenty.public_ip}:3000"
  })
}
```

Notice `module.s3.bucket_name` feeding directly into the EC2 module's
`user_data` rendering — this is the whole point of modularizing:
outputs from one module become inputs to another, instead of
duplicating values or hardcoding across separate flat configs like
Tasks 12/13 originally had.

## Preserving State with `moved` Blocks

Since this refactor changes resource *addresses* (e.g.
`aws_instance.twenty` becomes `module.ec2.aws_instance.this`),
`moved` blocks were added so Terraform treats these as the *same*
underlying infrastructure rather than destroying and recreating it:

```hcl
moved {
  from = aws_instance.twenty
  to   = module.ec2.aws_instance.this
}
```

**Note**: in this task's `terraform plan`, these show up as fresh
`+ create` actions rather than reconciling silently, because the local
state file being used doesn't contain the original flat addresses to
map from. Since this task explicitly does not run `apply`, this has no
real consequence here — but the `moved` blocks are the correct pattern
for this kind of refactor against a state file that does have the old
addresses, and are included for that reason.

## Issue Faced: `count` Depending on an Unknown Value

### The bug

Initially, the Elastic IP association inside the `ec2` module was
written as optional, using `count`:

```hcl
resource "aws_eip_association" "this" {
  count = var.eip_allocation_id != null ? 1 : 0
  ...
}
```

Running `terraform plan` failed with:

```
Error: Invalid count argument
The "count" value depends on resource attributes that cannot be
determined until apply.
```

### Root cause

`count` (and `for_each`) must be fully computable at plan time.
`var.eip_allocation_id` was set to `aws_eip.twenty.id` — and on a
first-time plan, that ID doesn't exist yet (it's only known after the
EIP is actually created during `apply`). Terraform can't evaluate
whether an as-yet-unknown value is `null` or not, so it can't
determine how many instances of the resource to plan.

### Resolution

Since the root config always supplies an EIP allocation in practice,
the "optional" design wasn't adding real value — it was only adding a
Terraform limitation. Removed the `count` entirely and made
`eip_allocation_id` a required variable:

```hcl
variable "eip_allocation_id" {
  description = "Allocation ID of the Elastic IP to associate with this instance"
  type        = string
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = var.eip_allocation_id
}
```

This resolved the error immediately — `terraform plan` completed
cleanly afterward with `Plan: 8 to add, 0 to change, 0 to destroy` and
no errors.

## Why the Elastic IP Exists at All

Task 13's original deployment hardcoded `SERVER_URL: http://localhost:3000`
in Twenty's Docker Compose config, which caused every external
visitor's browser to be redirected to their own machine's `localhost`
instead of the actual server (worked around at the time with a manual
`sed` patch on the running instance). This refactor fixes it properly:
an Elastic IP is allocated in the root module *before* the EC2 instance
(so its address is known in advance), and that fixed address is baked
into `user_data`'s rendered `SERVER_URL` — no manual post-deployment
patching required.

## Commands Run

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

`terraform apply` was intentionally **not** run, per the task's
explicit instruction — this task is a structural refactor, verified
via `plan` only.

## Final `terraform plan` Result

```
Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_iam_instance_profile = "EC2S3AccessRole"
  + ec2_instance_id          = (known after apply)
  + ec2_private_ip           = (known after apply)
  + ec2_public_ip            = (known after apply)
  + ecr_repository_arn       = (known after apply)
  + ecr_repository_name      = "netaji-twenty-crm"
  + ecr_repository_url       = (known after apply)
  + s3_bucket_arn            = (known after apply)
  + s3_bucket_name           = "netaji-twenty-crm-storage-2026"
  + subnet_id                = "subnet-078d52bfe579c74f2"
  + vpc_id                   = "vpc-0c241509159132524"
```

No errors, no warnings — clean plan.

## What I Learned

- How to decompose a flat Terraform configuration into independent,
  reusable modules with clearly defined inputs and outputs.
- How module outputs chain into other modules' inputs, avoiding
  duplicated or hardcoded values across a configuration.
- What `moved` blocks are for, and that they only take effect against
  a state file that actually contains the addresses being moved from.
- A concrete, common Terraform limitation: `count`/`for_each` cannot
  depend on a value that's only known after `apply` — and that the
  right fix is often to reconsider whether the conditional is actually
  needed, rather than working around the limitation.
- Why allocating a resource like an Elastic IP as its own independent
  resource (rather than inside the module that needs its value) avoids
  circular dependency problems when that value is needed to configure
  something else (like `user_data`) before the dependent resource
  exists.
