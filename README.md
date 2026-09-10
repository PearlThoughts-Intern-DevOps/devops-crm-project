# Task 13 — Twenty CRM on AWS EC2 with S3 Storage Backend (Terraform)

Deploys Twenty CRM on an EC2 instance via Docker, using an S3 bucket as
its storage backend, with all infrastructure provisioned by Terraform.

## Stack

- **Region:** us-east-1
- **Compute:** 1x EC2, `t3.small`, approved AMI
- **Storage:** 1x S3 bucket — versioning, AES-256 encryption, Block
  Public Access all enabled
- **IAM:** existing `EC2S3AccessRole` attached to the instance (no new
  IAM users/roles/policies created)
- **Network:** default VPC / default subnet (no new VPC)
- **App:** Twenty CRM via Docker Compose, port 2020

## Repo layout

```
terraform/
  versions.tf     # Terraform + AWS provider version pins
  variables.tf    # inputs, with validation matching task constraints
  data.tf         # lookups for default VPC/subnet
  s3.tf           # S3 bucket + versioning/encryption/public-access-block
  ec2.tf          # security group + EC2 instance
  user_data.sh.tpl# bootstrap script: installs Docker, clones repo, runs compose
  outputs.tf      # instance/bucket info surfaced after apply
  terraform.tfvars# deployment-specific values (bucket name, branch, key pair)
docker-compose.yml # Twenty CRM services (server, app) — S3 env vars added
screenshots/
  terraformapply.jpeg  # successful `terraform apply` output
  s3.jpeg               # S3 bucket configuration verification
  ui.jpeg               # Twenty CRM UI running on the deployed instance
AWS_S3.pdf         # supporting documentation/notes
```

## How it was deployed

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # then fill in bucket name, branch, key pair
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions the S3 bucket first, then the EC2 instance. On
first boot, the instance's `user_data` script installs Docker, clones
this repo at the target branch, and runs `docker compose up -d`,
configured to use the newly created bucket.

## Verification performed

- `terraform output` — instance ID, public IP, bucket name/ARN
- `aws s3api get-bucket-versioning` — `Status: Enabled`
- `aws s3api get-bucket-encryption` — `AES256`
- `aws s3api get-public-access-block` — all four block settings `true`
- `aws ec2 describe-security-groups` — ports 22 / 2020 / 3000 open
- Browser check at `http://<public_ip>:2020` — Twenty CRM UI loads
  (see `screenshots/ui.jpeg`)

## S3 integration

The `server` service's environment includes:

```yaml
environment:
  - STORAGE_TYPE=S_3
  - STORAGE_S3_REGION=${AWS_REGION}
  - STORAGE_S3_NAME=${S3_BUCKET_NAME}
```

No access keys are set anywhere — S3 access comes from the IAM role
(`EC2S3AccessRole`) attached to the EC2 instance via instance profile,
picked up automatically by the AWS SDK through instance metadata.

## Teardown

```bash
terraform destroy
```

Confirmed via `aws s3 ls` and `aws ec2 describe-instances` that the
bucket and instance are fully removed after destroy.
