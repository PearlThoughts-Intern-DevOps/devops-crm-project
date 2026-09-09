# Twenty CRM — Terraform + AWS Infrastructure (Task 12)

Provisions AWS infrastructure (ECR + EC2, using the account's default VPC)
via Terraform, and deploys the Twenty CRM Docker image to it through Amazon ECR.

## Repository Structure

```
.
├── terraform-twenty-crm/         # All Terraform configuration
│   ├── provider.tf               # Terraform + AWS provider config (us-east-1)
│   ├── variables.tf              # All configurable input variables
│   ├── main.tf                   # Core resources: VPC/subnet data sources,
│   │                              #   ECR repo, security group, EC2 instance
│   ├── outputs.tf                 # Exported values: ECR URL, EC2 IP/DNS,
│   │                              #   app URL, VPC/subnet IDs
│   ├── terraform.tfvars           # Actual values used for this deployment (gitignored)
│   └── templates/
│       └── user_data.sh.tpl       # EC2 boot script: installs Docker, authenticates
│                                  #   to ECR, retries image pull, runs the container
├── screenshots/                    # Verification screenshots (plan/apply output,
│                                  #   ECR push, docker ps, running app, destroy)
├── TASK_DOCUMENTATION.pdf          # Full write-up of the process: file-by-file
│                                  #   explanation, step-by-step run, issues
│                                  #   encountered, verification, cleanup
└── README.md                       # This file
```

## What Gets Created

| Resource | Purpose |
|---|---|
| `aws_ecr_repository.twenty_crm` | Private ECR repo holding the Twenty CRM image |
| `aws_security_group.twenty_crm_sg` | Allows SSH (22) from a fixed CIDR + app traffic (2020) from anywhere |
| `aws_instance.twenty_crm` | EC2 instance that pulls the image from ECR and runs it |

No VPC is created — `data.aws_vpcs`/`data.aws_subnets` in `main.tf` look up
the account's existing default VPC and one of its subnets.

## How to Run

```bash
cd terraform-twenty-crm
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Then tag and push the image:

```bash
docker tag twentycrm/twenty-app-dev:latest <ecr_repository_url>:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr_registry>
docker push <ecr_repository_url>:latest
```

The EC2 instance's boot script (`templates/user_data.sh.tpl`) pulls and
runs the image automatically once it's available in ECR, retrying every
30 seconds until it succeeds.

## Outputs

| Output | Description |
|---|---|
| `ecr_repository_url` | Where to push the Twenty CRM image |
| `ec2_public_ip` / `ec2_public_dns` | How to reach the instance |
| `app_url` | `http://<public_ip>:2020` — the running app |
| `vpc_id` / `subnet_id` | Which existing VPC/subnet were used |

## Verified Deployment

- ECR: `579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm`
- App: `http://100.53.60.131:2020` — confirmed running in browser
- Screenshots of each stage: see `screenshots/`
- Full process write-up: see `TASK_DOCUMENTATION.pdf`

## Cleanup

```bash
cd terraform-twenty-crm
terraform destroy
```
`force_delete = true` is set on the ECR repo so destroy succeeds even with
an image pushed to it. Confirmed via `aws ec2 describe-instances` and
`aws ecr describe-repositories` returning "not found" post-destroy — all
resources created for this task have been cleaned up.
