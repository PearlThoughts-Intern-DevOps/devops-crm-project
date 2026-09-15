# Task 15 — Twenty CRM on EC2 behind an AWS Application Load Balancer (Terraform)

**Author:** Vikash Yadav
**Branch:** `vikash-yadav-15`
**Repo:** `PearlThoughts-Intern-DevOps/devops-crm-project`
**Region:** `us-east-1`

## 1. Objective

Deploy Twenty CRM on an EC2 instance behind an AWS Application Load Balancer using Terraform, verify the ALB target becomes **Healthy**, confirm the app is reachable through the ALB, then tear down all resources.

## 2. Architecture

```
Internet
   │
   ▼
┌─────────────────────────┐
│  ALB (port 80)          │  security group: alb_sg
│  twenty-crm-task15-alb  │  ingress 80 from 0.0.0.0/0
└───────────┬─────────────┘
            │ forwards to target group (port 3000)
            ▼
┌─────────────────────────┐
│  EC2 instance (t3.small)│  security group: ec2_sg
│  Twenty CRM via Docker  │  ingress 3000 from alb_sg only
│  Compose (4 containers) │  ingress 22 from my_ip_cidr only
└─────────────────────────┘
   default VPC / default subnets
```

Containers run via Docker Compose: `server` (API + frontend), `worker` (background jobs), `db` (Postgres 16), `redis`.

## 3. Terraform layout

```
task-15/terraform/
  versions.tf          Terraform + AWS provider (~>5.0)
  variables.tf          aws_region, instance_type, ami_id, key_name, my_ip_cidr, twenty_app_port, project_name
  network.tf             default VPC/subnet data sources
  security_groups.tf   alb_sg (80 from internet), ec2_sg (3000 from ALB only, 22 from my_ip_cidr)
  ec2.tf                  aws_instance with user_data
  alb.tf                    aws_lb, target group, listener, target group attachment
  user_data.sh.tpl     cloud-init script that installs Docker and Twenty CRM
  outputs.tf             alb_dns_name, instance_id, instance_public_ip, target_group_arn
  terraform.tfvars      my_ip_cidr, key_name, ami_id
```

## 4. Key design decisions

- **`user_data_replace_on_change = true`** on the EC2 instance. The IAM policy on this shared training account denies `ec2:ModifyInstanceAttribute`, so Terraform cannot update `user_data` in place — this setting forces a full instance replace instead whenever the script changes.
- **Manual Twenty install instead of the official `install.sh` one-liner.** Twenty's official one-line installer (`bash <(curl ... install.sh)`) prompts interactively (`read -p "Enter directory name..."`). Under `user_data` there is no TTY/stdin, so the script fails immediately on the first prompt. The fix was to replicate the script's non-interactive manual steps directly: download `docker-compose.yml` and `.env.example`, set `SERVER_URL`, `ENCRYPTION_KEY`, and `PG_DATABASE_PASSWORD` via `sed`/`echo`, then `docker compose up -d`.
- **`SERVER_URL` is set to the ALB's DNS name** (`http://${aws_lb.twenty_alb.dns_name}`), passed into `user_data.sh.tpl` via `templatefile()`. Twenty's server uses this value to build absolute redirect URLs during onboarding; leaving the default (`http://localhost:3000`) caused the app to redirect the browser to `localhost` instead of the ALB address.
- **No custom EBS configuration.** The account's IAM policy carries an explicit deny on `ec2:ModifyVolume`, on `ec2:RunInstances` with custom EBS parameters, and on `ec2:CreateVolume` — so the root volume stays at the AMI's fixed 8GB default. Disk headroom was recovered instead by skipping `docker-buildx-plugin` (not needed for `compose up`), using `--no-install-recommends`, and running `apt-get clean` / clearing `/var/lib/apt/lists/*` right after the Docker install.
- **No swap file.** Was tried as a memory precaution, but on an 8GB disk that's already tight for four container images, a 2GB swap file made the actual problem (disk space) worse for no benefit — the real failure was `ENOSPC` during image extraction, not OOM.

## 5. IAM constraints observed on this shared training account

Confirmed **blocked**: `ec2:GetConsoleOutput`, `ec2:DescribeRouteTables`, `ec2:DescribeNetworkAcls`, `ec2:ModifyInstanceAttribute`, `ec2:ModifyVolume`, `ec2:CreateVolume`, `RunInstances` with custom EBS block device parameters, `iam:CreateRole`/`AttachRolePolicy`/`CreateInstanceProfile` (rules out SSM Session Manager). No AWS Console access — CLI keys only.

Confirmed **working**: `ec2:RunInstances`/terminate (own instances), security group CRUD, `elbv2:*`, `ec2:CreateKeyPair`, describe-family read calls.

Because SSH and SSM were both unavailable for live debugging, a temporary port-8080 Python `http.server` (serving `/var/log`) was added to `user_data.sh.tpl` early in the script, with a temporary ALB listener/target group on port 8080, to read `/var/log/user-data.log` remotely without shell access. **This was removed before the final apply** (see Section 7).

## 6. Debugging summary (root causes found, in order)

| Symptom | Root cause | Fix |
|---|---|---|
| Target group never healthy, ~20-40 min wait | Official `install.sh` is interactive; `read -p` hangs/fails with no TTY under `user_data` | Replaced with manual, non-interactive install steps |
| Direct `curl`/SSH to instance public IP always timed out | Security groups correctly scope port 3000 to ALB-only and port 22 to `my_ip_cidr` — this was by design, not a network fault | Verified via SG rules; used the ALB itself (or SSH once IP matched) instead of hitting the instance IP directly |
| `terraform apply` failed with `ModifyVolume`/`RunInstances`(EBS)/`CreateVolume` AccessDenied | Account-level explicit deny on all EBS resize/creation actions | Reverted to default AMI volume size; freed space via package trimming and `apt-get clean` |
| `no space left on device` during image pull | AMI's fixed 8GB root volume too small for Docker + 4 Twenty images | Dropped `docker-buildx-plugin`, used `--no-install-recommends`, cleaned apt cache, removed swapfile |
| App loaded but redirected to `localhost/welcome`, unreachable | `SERVER_URL` defaulted to `http://localhost:3000` in `.env.example`; Twenty uses it for generated/redirect URLs | Set `SERVER_URL` to the ALB DNS name via `sed`, passed in from Terraform |

## 7. How to reproduce

```powershell
cd task-15/terraform
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

Wait 2-4 minutes for the instance to install Docker and start Twenty CRM, then verify:

```powershell
aws elbv2 describe-target-health --target-group-arn <target_group_arn>
curl.exe "http://<alb_dns_name>/healthz"
```

Expect `{"status":"ok",...}` and `TargetHealth.State: healthy`. Open `http://<alb_dns_name>` in a browser to confirm the Twenty CRM onboarding page loads.

## 8. Cleanup

```powershell
terraform destroy
```

Confirm no leftover resources remain that belong to this user (`twenty-crm-task15*`), and never touch resources tagged for other interns sharing this account.
