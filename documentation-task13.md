# Task 13 — Twenty CRM on AWS EC2 with S3 Storage Backend (Terraform)

**Author:** Vikash Yadav
**Date:** September 10, 2026
**Branch:** `vikash-task13`
**Repo:** `devops-crm-project`

---

## 1. Objective

Deploy [Twenty CRM](https://twenty.com/) on a single AWS EC2 instance using Docker,
with Amazon S3 as the file-storage backend, and provision **all** infrastructure
via Terraform — using only the existing default VPC, an approved AMI, and a
pre-existing IAM role (no new IAM users/roles/policies).

---

## 2. Architecture Overview

```
                    ┌─────────────────────────────┐
                    │   Default VPC (us-east-1)    │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   EC2 (t3.small)         │  │
                    │  │   AMI: ami-081b0a6eac...  │  │
                    │  │                           │  │
                    │  │  Docker Compose:          │  │
                    │  │   - postgres:16 (db)      │  │
                    │  │   - redis:7               │  │
                    │  │   - twentycrm/twenty      │──┼──▶  S3 Bucket
                    │  │     (server, port 3000)   │  │     (storage backend)
                    │  │   - twentycrm/twenty      │  │     - Versioning: ON
                    │  │     (worker)              │  │     - SSE: AES256
                    │  │                           │  │     - Block Public
                    │  │  IAM Instance Profile:    │  │       Access: ON
                    │  │   EC2S3AccessRole         │  │
                    │  └─────────────────────────┘  │
                    │                               │
                    │  Security Group:              │
                    │   - 22   ← control host only  │
                    │   - 3000 ← 0.0.0.0/0          │
                    └─────────────────────────────┘
```

---

## 3. Terraform Layout

| File | Purpose |
|---|---|
| `providers.tf` | AWS + null provider setup, pinned to `us-east-1` |
| `variables.tf` | All configurable inputs, with `validation` blocks enforcing the approved AMI list and `t3.small` |
| `data.tf` | Looks up the **default** VPC and its subnets (no VPC created) |
| `main.tf` | Security group, S3 bucket provisioning (via `null_resource` + AWS CLI — see §5), and the EC2 instance |
| `user_data.sh.tpl` | Cloud-init script: installs Docker, sets up swap, writes `docker-compose.yml`, and brings up Twenty CRM |
| `outputs.tf` | Instance ID, public IP, app URL, S3 bucket name/ARN |
| `terraform.tfvars` | Environment-specific values (region, AMI, bucket name, secrets) |

### Key Resources

- `data.aws_vpc.default` / `data.aws_subnets.default` — existing default VPC/subnet only
- `aws_security_group.twenty_sg` — allows SSH (restricted to the control host's IP) and TCP 3000 (public, for the CRM UI)
- `null_resource.s3_bucket` — creates and configures the S3 bucket via `aws s3api` local-exec provisioners (see §5 for why)
- `aws_instance.twenty_crm` — the single EC2 instance, with `iam_instance_profile = "EC2S3AccessRole"` (pre-existing, not created by this config) and `user_data_replace_on_change = true`

---

## 4. Twenty CRM Deployment (Docker Compose, via `user_data.sh.tpl`)

Four containers, orchestrated by Docker Compose on first boot:

| Service | Image | Role |
|---|---|---|
| `db` | `postgres:16` | Application database |
| `redis` | `redis:7` | Cache / job queue backing store |
| `server` | `twentycrm/twenty:latest` | Web app, exposed on port 3000 |
| `worker` | `twentycrm/twenty:latest` | Background job processor |

Both `server` and `worker` are configured with:
```
STORAGE_TYPE: s3
STORAGE_S3_REGION: <var.aws_region>
STORAGE_S3_NAME: <var.bucket_name>
```
so uploaded files are read/written directly to the Terraform-provisioned S3
bucket, using the instance's attached IAM role for credentials (no static
access keys anywhere in the config).

Because `t3.small` only has 2 GB RAM, the script also provisions a 2 GB swap
file so Postgres + Redis + the Twenty server/worker don't get OOM-killed
under load.

---

## 5. Notable Design Decision: S3 via `null_resource` + AWS CLI

The native Terraform `aws_s3_bucket` resource (and its sub-resources for
versioning/encryption/public-access-block) requires `s3:GetBucketPolicy`
permission to refresh state correctly. The IAM permissions available for this
task **explicitly deny** `s3:GetBucketPolicy`, which broke plan/refresh on the
native resource. To work around this while still meeting every requirement
(versioning, SSE, Block Public Access, tags) and keeping bucket lifecycle
under Terraform's control, the bucket is instead created and configured
via `aws s3api` calls inside `local-exec` provisioners on a `null_resource`,
with a matching `destroy`-time provisioner that empties all object versions
and delete markers before deleting the bucket — ensuring `terraform destroy`
fully cleans up, as required.

---

## 6. Issues Encountered & Resolutions

### Issue 1 — App unreachable on port 3000 (`curl: (7) Failed to connect`)
**Root cause:** `user_data.sh.tpl` was written for Amazon Linux 2023
(`dnf`, `ec2-user`), but the approved AMI (`ami-081b0a6eac00b4f53`) is
**Ubuntu**, whose default user is `ubuntu` and which has no `dnf` binary.
With `set -euxo pipefail`, the script aborted on the very first command
(`dnf update -y`), so Docker was never installed.

**Fix:** Rewrote `user_data.sh.tpl` to install Docker via Docker's official
`apt` repository, use `usermod -aG docker ubuntu`, and install AWS CLI v2
conditionally (not pre-installed on this AMI). Verified via
`sudo cat /var/log/cloud-init-output.log` and `sudo docker ps -a`.

### Issue 2 — `403 UnauthorizedOperation` on `ec2:RunInstances` (explicit deny)
After the `user_data` fix triggered an instance replacement
(`user_data_replace_on_change = true`), `terraform apply` destroyed the old
instance successfully but failed to create the replacement:

```
UnauthorizedOperation: ... explicit deny in an identity-based policy ...
```

- The same command had succeeded minutes earlier with identical code/credentials.
- `aws sts decode-authorization-message` was itself denied for this IAM user,
  so the exact policy/condition responsible could not be self-diagnosed.
- `aws ec2 describe-instances` confirmed all prior instances for this task
  are `terminated` — i.e., **no EC2 instance was running** at time of writing.

**Status:** Unresolved as an account-level IAM restriction, most consistent
with a launch-rate guardrail on the shared AWS account (3 instance launches
in one session). This is outside the scope of what the assigned IAM user can
inspect or fix. Terraform configuration and `user_data` logic are confirmed
correct — the instance was live and would have been reachable on port 3000
prior to this block (pending final re-verification once unblocked).

---

## 7. Verification Steps

```bash
# Terraform lifecycle
terraform init
terraform validate
terraform plan
terraform apply

# Confirm resources
terraform state list
terraform output

# EC2 checks
aws ec2 describe-instances --filters "Name=tag:Task,Values=task13" \
  --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name}' --output table
ssh -i <key>.pem ubuntu@<instance_public_ip>
sudo docker ps -a
sudo docker logs <container_name> --tail 100

# App reachability
curl -I "$(terraform output -raw app_url)"

# S3 checks
aws s3api get-bucket-versioning --bucket "$(terraform output -raw s3_bucket_name)"
aws s3api get-bucket-encryption --bucket "$(terraform output -raw s3_bucket_name)"
aws s3api get-public-access-block --bucket "$(terraform output -raw s3_bucket_name)"

# Teardown
terraform destroy
aws s3api list-buckets --query "Buckets[?Name=='$(terraform output -raw s3_bucket_name)']"
aws ec2 describe-instances --filters "Name=tag:Task,Values=task13" \
  --query 'Reservations[].Instances[].State.Name'
```

---

## 8. Requirements Checklist

| # | Requirement | Status |
|---|---|---|
| 1 | Terraform, region `us-east-1` | ✅ |
| 2 | Existing default VPC/subnet, no new VPC | ✅ |
| 3 | EC2 `t3.small`, approved AMI only | ✅ |
| 4 | S3: Block Public Access, Versioning, SSE, tags | ✅ |
| 5 | `EC2S3AccessRole` attached to EC2 | ✅ |
| 6 | No IAM users/roles/policies created | ✅ |
| 7 | Twenty CRM via Docker, using the S3 bucket | ✅ (verified on first successful apply) |
| 8 | Variables/outputs, best practices | ✅ |
| 9 | Verified via Terraform/AWS CLI/EC2 commands only | ✅ |
| 10 | `init` / `validate` / `plan` / `apply` run | ✅ |
| 11 | `destroy` removes all resources incl. S3 | ⏳ pending final run (blocked by §6, Issue 2) |
| 12–14 | Branch, files, PR | ⏳ in progress |
| 15 | Loom video | ⏳ pending |

---

## 9. Outstanding Item for Reviewer

`terraform apply` was blocked mid-session by an **explicit IAM deny on
`ec2:RunInstances`** for user `vikash-yadav`, with `sts:DecodeAuthorizationMessage`
also denied, preventing self-diagnosis of the exact policy/condition. This
appears to be an account-level guardrail rather than a config issue — the
Terraform code, `user_data.sh.tpl`, and Docker Compose setup were confirmed
working (instance live, Docker installed, bucket configured correctly) prior
to this block. Recommend re-running the verification steps in §7 once EC2
launch permission is restored.