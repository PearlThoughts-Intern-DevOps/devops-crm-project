# Task 15 — Twenty CRM behind an AWS Application Load Balancer

Deploys Twenty CRM on an EC2 instance, placed behind an AWS Application
Load Balancer (ALB), with all infrastructure provisioned via Terraform.

## Stack

- **Region:** us-east-1
- **Compute:** 1x EC2, `t3.small`, approved AMI (Amazon Linux 2023)
- **Load Balancing:** 1x Application Load Balancer, 1x Target Group,
  1x HTTP Listener, with a health check on the app port
- **Network:** default VPC, multi-AZ default subnets (no new VPC)
- **App:** Twenty CRM, deployed via the repository's own
  `setup_crm.py` automation script, served on port 2020

## Repo layout

```
terraform/
  versions.tf              # Terraform + AWS provider version pins
  variables.tf              # inputs, with validation matching task constraints
  data.tf                    # default VPC + multi-AZ subnet lookups
  ec2.tf                      # EC2 instance + its security group
  alb.tf                       # ALB, target group, listener, health check, ALB security group
  user_data.sh.tpl              # bootstrap script: Docker, Node/Yarn via nvm+corepack, runs setup_crm.py
  outputs.tf                     # ALB DNS name, app URL, target group ARN, instance info
  terraform.tfvars                # deployment-specific values
screenshots/
  # ALB creation, target health, and the running app UI
task15.docx
  # full write-up of the deployment
```

## How it was deployed

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # then fill in AMI, branch, key pair
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions the ALB, target group, listener, and security
groups, then launches the EC2 instance. On first boot, `user_data`
installs Docker, Node.js (via `nvm`, matching the app's pinned
`.nvmrc` version), enables Yarn 4 via Corepack, clones the application
repository, and runs its `setup_crm.py` script — which installs
dependencies, starts Twenty CRM's backend via Docker, and starts the
application server on port 2020.

## Verification performed

- `terraform output alb_dns_name` / `app_url` — the public ALB endpoint
- `aws elbv2 describe-target-health --target-group-arn <arn>` — confirmed
  the EC2 instance reached a `healthy` target state
- Browser access to the ALB's DNS name — confirmed Twenty CRM loads
  successfully end-to-end through the load balancer
- SSH verification of the running application and its logs on the
  instance itself

## Security design

The EC2 instance's security group only accepts traffic on the app port
from the ALB's own security group — not from the open internet — so
the ALB is the sole public entry point. SSH is separately restricted
to a configurable CIDR for verification access.

## Teardown

```bash
terraform destroy
```

Confirmed via the AWS CLI (`aws elbv2 describe-load-balancers`,
`aws ec2 describe-instances`) that all resources — ALB, listener,
target group, EC2 instance, and both security groups — were fully
removed after destroy.
