# Task 15: AWS Application Load Balancer for Twenty CRM

This Terraform configuration deploys Twenty CRM on an EC2 instance behind an
internet-facing AWS Application Load Balancer.

All repository changes were made manually and verified step by step.

## Architecture

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
   |
   | HTTP :3000
   v
ALB Target Group
   |
   v
EC2 Instance
   |
   v
Twenty CRM Docker container :3000
```

## AWS Requirements

- Region: `us-east-1`
- Instance type: `t3.small`
- AMI: `ami-081b0a6eac00b4f53`
- Existing default VPC
- Default-VPC subnets across multiple Availability Zones
- Internet-facing Application Load Balancer
- HTTP listener on port `80`
- HTTP target group on port `3000`
- Target type: `instance`
- Health-check path: `/healthz`

## Directory Structure

```text
terraform/
├── key-pair.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── security-group.tf
├── terraform.tfvars.example
├── user-data.sh.tftpl
├── docker-compose.yml.tftpl
├── variables.tf
├── versions.tf
├── vpc.tf
└── modules/
    ├── alb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecr/
    └── s3/
```

The ECR and S3 modules are retained as reusable Task 14 code but are not
called by the Task 15 root configuration.

## ALB Module

The reusable ALB module manages:

- `aws_lb`
- `aws_lb_listener`
- `aws_lb_target_group`
- `aws_lb_target_group_attachment`

The ALB dynamically uses the available default subnets returned by
`data.aws_subnets.default`. Six default subnets across six Availability Zones
were discovered during deployment.

The target group forwards HTTP traffic to Twenty CRM on EC2 port `3000`.
Its health check uses:

```text
Path: /healthz
Protocol: HTTP
Port: traffic-port
Matcher: 200-399
```

## Security Groups

The security-group flow is:

```text
Internet :80
    |
    v
ALB security group
    |
    | TCP :3000
    v
EC2 security group
```

Rules:

- The ALB accepts public HTTP traffic on port `80`.
- The ALB can send traffic to the EC2 security group on port `3000`.
- EC2 port `3000` accepts traffic only from the ALB security group.
- Port `3000` is not exposed directly to the internet.
- SSH port `22` is restricted to the administrator’s configured `/32` CIDR.
- EC2 permits outbound HTTPS for packages and container images.

## Terraform-Managed Key Pair

The RSA private/public key material was generated locally:

```bash
mkdir -p ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/chirag-crm-server
chmod 400 ~/.ssh/chirag-crm-server
```

Terraform imports only the public key:

```hcl
resource "aws_key_pair" "task15" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}
```

The private key remains outside the repository and is never stored in
Terraform state.

## Twenty CRM Storage

S3 was intentionally removed from the active Task 15 configuration because it
is not required for the ALB objective.

Twenty uses its existing `server-local-data` Docker volume for uploaded files.
This persists across container restarts but is removed when the EC2 instance
and its root storage are destroyed.

The reusable S3 module remains in `modules/s3`, but the root configuration does
not instantiate it.

ECR was also removed from the active configuration because Docker Compose pulls
the pinned `twentycrm/twenty` image directly from Docker Hub. The reusable ECR
module remains in `modules/ecr`.

## Useful Outputs

Terraform exposes:

- Default VPC ID
- EC2 subnet ID
- EC2 instance ID
- EC2 public and private IP addresses
- EC2 public DNS name
- EC2 security-group ID
- Terraform-managed key-pair name
- ALB ARN
- ALB DNS name
- ALB URL
- ALB security-group ID
- ALB subnet IDs
- Target-group ARN

Display them with:

```bash
terraform output
```

Open Twenty CRM on macOS with:

```bash
open "$(terraform output -raw twenty_url)"
```

## Terraform Workflow

The following commands were run from `terraform/`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=task15-alb-only.tfplan
terraform apply "task15-alb-only.tfplan"
```

After recovering from the key-pair permission issue, the successful recovery
plan was:

```bash
terraform plan -out=task15-key-no-tags.tfplan
terraform apply "task15-key-no-tags.tfplan"
```

Final validation returned:

```text
Success! The configuration is valid.
```

The completed infrastructure contained 13 Terraform-managed resources.

## Verification

### EC2 and ALB

Verification confirmed:

- EC2 state: `running`
- ALB state: `active`
- ALB scheme: `internet-facing`
- ALB listener: HTTP port `80`
- Target port: `3000`
- Target type: `instance`

### Target Health

Target health was checked with:

```bash
aws elbv2 describe-target-health \
  --region us-east-1 \
  --target-group-arn "$(terraform output -raw alb_target_group_arn)" \
  --query 'TargetHealthDescriptions[].{Instance:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason}' \
  --output table
```

Final result:

```text
Port: 3000
State: healthy
Reason: None
```

Twenty CRM was successfully opened through the ALB DNS name in a browser.

## Problems Encountered and Resolutions

### 1. Duplicate User Data block

`terraform fmt main.tf` initially returned `Missing key/value separator`.

An incomplete duplicate `user_data` block had been pasted outside the EC2
module. The duplicate block was removed, and `server_url` was added to the
existing User Data argument map.

### 2. S3 and ECR were unnecessary

The inherited Task 14 root configuration initially planned S3 and ECR
resources.

S3 environment variables and the root S3 module call were removed. The root
ECR module call was also removed because the deployment uses Docker Hub. Both
reusable module directories were retained.

### 3. Missing EC2 key pair

The first EC2 creation failed with:

```text
InvalidKeyPair.NotFound
```

The configured `chirag-crm-server` key pair did not exist in `us-east-1`.
A local RSA key was generated, and an `aws_key_pair` resource was added so
Terraform could import its public key.

### 4. Key-pair tagging permission denied

The first Terraform-managed key-pair attempt failed because the IAM user did
not have `ec2:CreateTags` permission for key-pair resources.

Tags were removed from `aws_key_pair.task15`. Terraform then imported the
public key successfully without requiring additional IAM permissions.

### 5. Missing newline in `variables.tf`

Terraform reported:

```text
Missing newline after block definition
```

The new `ssh_public_key_path` variable had been placed directly after another
closing brace. A newline was inserted between the two blocks.

### 6. Unclosed key-pair resource

After removing the unsupported tags, Terraform reported:

```text
Unclosed configuration block
```

The closing brace for `aws_key_pair.task15` was restored, after which
`terraform validate` succeeded.

### 7. Target initially unhealthy

The target initially reported `Target.FailedHealthChecks` while Docker images,
PostgreSQL, Redis, and Twenty CRM were starting.

No infrastructure change was required. After startup completed, the target
reported `healthy`, and Twenty CRM loaded successfully through the ALB.

## Destruction and Cleanup

After verification, the infrastructure was removed with:

```bash
terraform destroy
```

Terraform reported:

```text
Plan: 0 to add, 0 to change, 13 to destroy.
Destroy complete! Resources: 13 destroyed.
```

Cleanup was confirmed with:

```bash
terraform state list
```

The command returned no resources. The EC2 instance state was independently
verified as:

```text
terminated
```

The local private and public SSH key files remain under `~/.ssh`; Terraform
destroyed only the AWS key-pair resource.

## Git Hygiene

The following local artifacts must not be committed:

- `.terraform/`
- `terraform.tfvars`
- `*.tfstate`
- `*.tfstate.*`
- `*.tfplan`
- Private SSH keys

Task 15 was completed on branch:

```text
chirag-task-15
```