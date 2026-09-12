# Task 14 — Terraform Modules (EC2, ECR, S3)

## 1. Project Structure

```text
terraform/
├── main.tf              # Root — calls the 3 modules
├── provider.tf          # AWS + random providers
├── variables.tf         # Root-level input variables
├── outputs.tf           # Root-level outputs (aggregated from modules)
├── terraform.tfvars     # Values for root variables
├── user_data.sh.tpl     # Bootstrap script passed to the EC2 module
├── README.md
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

---

## 2. Modules

### `modules/ec2`

Creates a Security Group and an EC2 instance.

**Inputs**

| Variable               | Type        | Default | Description                                                        |
| ---------------------- | ----------- | ------- | ------------------------------------------------------------------ |
| `ami_id`               | string      | —       | AMI ID                                                             |
| `instance_type`        | string      | —       | EC2 instance type                                                  |
| `subnet_id`            | string      | —       | Subnet for the instance                                            |
| `vpc_id`               | string      | —       | VPC for the security group                                         |
| `key_name`             | string      | —       | EC2 key pair                                                       |
| `iam_instance_profile` | string      | —       | IAM instance profile                                               |
| `root_volume_size`     | number      | `20`    | Root EBS volume GiB                                                |
| `allowed_ssh_cidr`     | string      | —       | SSH allowed CIDR                                                   |
| `app_port`             | number      | `2020`  | App port                                                           |
| `user_data`            | string      | `""`    | Bootstrap script                                                   |
| `project_name`         | string      | —       | Project tag                                                        |
| `environment`          | string      | —       | Environment tag                                                    |
| `security_group_name`  | string      | `null`  | Override SG name (defaults to `${project_name}-${environment}-sg`) |
| `tags`                 | map(string) | `{}`    | Resource tags                                                      |

**Outputs**

| Output              | Description       |
| ------------------- | ----------------- |
| `instance_id`       | EC2 instance ID   |
| `public_ip`         | Public IP         |
| `public_dns`        | Public DNS        |
| `security_group_id` | Security group ID |

### `modules/ecr`

Creates an ECR repository with scan-on-push.

**Inputs**

| Variable               | Type        | Default   | Description                |
| ---------------------- | ----------- | --------- | -------------------------- |
| `repository_name`      | string      | —         | ECR repo name              |
| `image_tag_mutability` | string      | `MUTABLE` | Tag mutability             |
| `scan_on_push`         | bool        | `true`    | Enable scan on push        |
| `force_delete`         | bool        | `true`    | Allow deletion with images |
| `tags`                 | map(string) | `{}`      | Resource tags              |

**Outputs**

| Output            | Description   |
| ----------------- | ------------- |
| `repository_url`  | ECR repo URL  |
| `repository_arn`  | ECR repo ARN  |
| `repository_name` | ECR repo name |

### `modules/s3`

Creates an S3 bucket with Block Public Access, Versioning, and SSE encryption.

**Inputs**

| Variable             | Type        | Default  | Description                                     |
| -------------------- | ----------- | -------- | ----------------------------------------------- |
| `bucket_name_prefix` | string      | —        | Prefix for bucket name (random suffix appended) |
| `force_destroy`      | bool        | `true`   | Allow deletion with objects                     |
| `sse_algorithm`      | string      | `AES256` | Encryption algorithm (`AES256` or `aws:kms`)    |
| `tags`               | map(string) | `{}`     | Resource tags                                   |

**Outputs**

| Output          | Description      |
| --------------- | ---------------- |
| `bucket_name`   | S3 bucket name   |
| `bucket_arn`    | S3 bucket ARN    |
| `bucket_region` | S3 bucket region |

---

## 3. Module Composition

The root `main.tf` calls all three modules. The EC2 module's `user_data` uses the outputs of the ECR and S3 modules — demonstrating module composition.

```hcl
module "ecr" {
  source               = "./modules/ecr"
  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  tags                 = local.common_tags
}

module "s3" {
  source             = "./modules/s3"
  bucket_name_prefix = "${var.project_name}-${var.environment}-storage"
  force_destroy      = true
  tags               = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = data.aws_subnet.selected.id
  vpc_id               = data.aws_vpc.default.id
  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile
  root_volume_size     = var.root_volume_size
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  app_port             = var.app_port
  project_name         = var.project_name
  environment          = var.environment

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region         = var.aws_region
    app_port           = var.app_port
    ecr_repository_url = module.ecr.repository_url
    s3_bucket_name     = module.s3.bucket_name
  })

  tags = local.common_tags
}
```

---

## 4. Reusability

The modules are designed to be reused across projects and environments.

### How to reuse in another project

```hcl
module "ec2" {
  source = "git::https://github.com/your-org/terraform-modules.git//ec2?ref=v1.0.0"

  ami_id               = "ami-xxxxxxxxxxxxxx"
  instance_type        = "t3.medium"
  subnet_id            = module.vpc.public_subnet_id
  vpc_id               = module.vpc.id
  key_name             = var.key_pair_name
  iam_instance_profile = "AppRole"
  project_name         = "my-new-app"
  environment          = "prod"
  allowed_ssh_cidr     = "10.0.0.0/8"
  app_port             = 8080
  user_data            = file("${path.module}/bootstrap.sh")

  tags = { Team = "backend", CostCenter = "1234" }
}
```

### Design decisions that support reuse

* **No hardcoded AWS region or account ID** — region comes from the provider, ARNs come from module outputs
* **Inputs via variables only** — no `data` sources inside modules that reach out to a specific VPC; the caller passes `vpc_id` and `subnet_id`
* **Outputs are minimal and stable** — only the resource IDs/ARNs/URLs a caller needs
* **Sensible defaults** — `instance_type`, `root_volume_size`, `app_port`, `scan_on_push`, `force_delete`, `sse_algorithm` all have defaults
* **Name override** — the EC2 module accepts an optional `security_group_name` parameter, defaulting to `${project_name}-${environment}-sg`, so the same module can be instantiated multiple times without collisions
* **Configurable encryption** — the S3 module accepts an `sse_algorithm` variable, allowing `AES256` (default) or `aws:kms`
* **Local `common_tags` in root** — modules accept a `tags` map, so each caller chooses their own tagging strategy

---

## 5. Commands Run

```bash
terraform init              # initializes root + 3 modules
terraform fmt -recursive    # formats all .tf files including modules
terraform validate          # configuration is valid
terraform plan              # 8 resources to add
```

`terraform apply` is **not** run for Task 14, per task requirements.

### `terraform init` Output

```text
Initializing modules...
- s3 in modules\s3
- ecr in modules\ecr
- ec2 in modules\ec2

Terraform has been successfully initialized!
```

### `terraform fmt -recursive` Output

```text
modules\ec2\main.tf
modules\ecr\main.tf
```

### `terraform validate` Output

```text
Success! The configuration is valid.
```

### `terraform plan` Output

```text
Plan: 8 to add, 0 to change, 0 to destroy.

Resources:
  module.ec2.aws_instance.this
  module.ec2.aws_security_group.this
  module.ecr.aws_ecr_repository.this
  module.s3.aws_s3_bucket.this
  module.s3.aws_s3_bucket_public_access_block.this
  module.s3.aws_s3_bucket_server_side_encryption_configuration.this
  module.s3.aws_s3_bucket_versioning.this
  module.s3.random_id.suffix
```

---

## 6. Root Variables

| Variable                   | Type   | Default                 | Description          |
| -------------------------- | ------ | ----------------------- | -------------------- |
| `aws_region`               | string | `us-east-1`             | AWS region           |
| `project_name`             | string | `twenty-crm`            | Project name         |
| `environment`              | string | `dev`                   | Environment          |
| `ami_id`                   | string | `ami-0b6d9d3d33ba97d99` | EC2 AMI              |
| `instance_type`            | string | `t3.small`              | EC2 instance type    |
| `key_pair_name`            | string | —                       | EC2 Key Pair         |
| `iam_instance_profile`     | string | —                       | IAM instance profile |
| `root_volume_size`         | number | `20`                    | Root volume GiB      |
| `allowed_ssh_cidr`         | string | `0.0.0.0/0`             | SSH allowed CIDR     |
| `app_port`                 | number | `2020`                  | Twenty CRM port      |
| `ecr_repository_name`      | string | `twenty-crm`            | ECR repo name        |
| `ecr_image_tag_mutability` | string | `MUTABLE`               | ECR tag mutability   |
| `ecr_scan_on_push`         | bool   | `true`                  | ECR scan on push     |

### Example `terraform.tfvars`

```hcl
aws_region           = "us-east-1"
project_name         = "twenty-crm"
environment          = "dev"
instance_type        = "t3.small"
root_volume_size     = 20
key_pair_name        = "sakhisurakhya-task7-key"
allowed_ssh_cidr     = "157.41.243.122/32"
app_port             = 2020
iam_instance_profile = "EC2ECRPullRole"
ecr_repository_name  = "twenty-crm"
```

---

## 7. Root Outputs

| Output                | Source                                      |
| --------------------- | ------------------------------------------- |
| `vpc_id`              | data source                                 |
| `subnet_id`           | data source                                 |
| `instance_id`         | `module.ec2`                                |
| `instance_public_ip`  | `module.ec2`                                |
| `instance_public_dns` | `module.ec2`                                |
| `security_group_id`   | `module.ec2`                                |
| `ecr_repository_url`  | `module.ecr`                                |
| `ecr_repository_arn`  | `module.ecr`                                |
| `s3_bucket_name`      | `module.s3`                                 |
| `s3_bucket_arn`       | `module.s3`                                 |
| `app_url`             | composed from `module.ec2` + `var.app_port` |

---


---

## 8. Files Changed

| Change        | Files                                                              |
| ------------- | ------------------------------------------------------------------ |
| **Added**     | `main.tf`, `modules/ec2/*`, `modules/ecr/*`, `modules/s3/*`        |
| **Removed**   | `ec2.tf`, `s3.tf`, `vpc.tf` (logic moved into modules + `main.tf`) |
| **Rewritten** | `variables.tf` (root inputs), `outputs.tf` (module outputs)        |
| **Updated**   | `user_data.sh.tpl` (pulls from ECR via module output)              |
| **Unchanged** | `provider.tf`, `terraform.tfvars`                                  |

---


