# Task 12 — Terraform + AWS Infrastructure for Twenty CRM

## 1. Overview

This task provisions the AWS infrastructure required to host **Twenty CRM** using Terraform and deploys the Dockerized application automatically on an EC2 instance.

### AWS resources

| Resource       | Purpose                                          |
| -------------- | ------------------------------------------------ |
| Amazon ECR     | Private registry for the Twenty CRM Docker image |
| Security Group | Allows SSH and application traffic               |
| EC2 Instance   | Hosts Docker, PostgreSQL, Redis, and Twenty CRM  |

The deployment uses the **existing default VPC** and an available subnet. No new VPC or network infrastructure is created.

---

## 2. Architecture

```text
                         Internet
                            |
                     Ports 22 / 2020
                            |
                    ┌───────▼────────┐
                    │ Security Group │
                    └───────┬────────┘
                            |
                    ┌───────▼──────────────┐
                    │ EC2 - t3.small       │
                    │ Ubuntu 26.04         │
                    │ 20 GiB gp3           │
                    │                      │
                    │ Docker Network       │
                    │    twenty-net        │
                    │                      │
                    │ ┌──────────────────┐ │
                    │ │ twenty-crm       │ │
                    │ │ 2020 → 3000      │ │
                    │ └──────────────────┘ │
                    │                      │
                    │ ┌──────────────────┐ │
                    │ │ PostgreSQL 16    │ │
                    │ └──────────────────┘ │
                    │                      │
                    │ ┌──────────────────┐ │
                    │ │ Redis 7          │ │
                    │ └──────────────────┘ │
                    └──────────┬───────────┘
                               |
                               | docker pull
                               |
                    ┌──────────▼───────────┐
                    │ Amazon ECR            │
                    │ twenty-crm:latest    │
                    └──────────────────────┘
```

---

## 3. Project Structure

```text
terraform/
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── vpc.tf
├── ecr.tf
├── ec2.tf
├── user_data.sh.tpl
├── outputs.tf
└── README.md
```

### File descriptions

| File               | Purpose                                            |
| ------------------ | -------------------------------------------------- |
| `provider.tf`      | Terraform and AWS provider configuration           |
| `variables.tf`     | Terraform input variables                          |
| `terraform.tfvars` | Environment-specific variable values               |
| `vpc.tf`           | Uses the existing default VPC and selects a subnet |
| `ecr.tf`           | Creates the ECR repository                         |
| `ec2.tf`           | Creates the Security Group and EC2 instance        |
| `user_data.sh.tpl` | Automatically bootstraps Docker and Twenty CRM     |
| `outputs.tf`       | Displays useful infrastructure outputs             |
| `README.md`        | Documentation                                      |

---

# 4. Prerequisites

The following are required:

* Terraform >= 1.5.0
* AWS CLI
* Docker
* An existing EC2 key pair
* An existing IAM instance profile with ECR pull permissions
* AWS credentials with the required EC2, ECR and IAM permissions

### Existing resources used

```text
AWS Region: us-east-1
IAM Instance Profile: EC2ECRPullRole
EC2 Key Pair: sakhisurakhya-task7-key
```

---

# 5. Terraform Configuration

## Provider

The project uses the AWS provider in `us-east-1`.

```hcl
provider "aws" {
  region = var.aws_region
}
```

## Default VPC

Terraform uses the existing AWS default VPC instead of creating a new VPC.

```hcl
data "aws_vpc" "default" {
  default = true
}
```

The first available subnet in the default VPC is selected for the EC2 instance.

---

# 6. Terraform Variables

The main variables are:

| Variable               | Value             | Description            |
| ---------------------- | ----------------- | ---------------------- |
| `aws_region`           | `us-east-1`       | AWS region             |
| `project_name`         | `twenty-crm`      | Project name           |
| `environment`          | `dev`             | Environment            |
| `instance_type`        | `t3.small`        | EC2 instance type      |
| `root_volume_size`     | `20`              | Root EBS volume in GiB |
| `key_pair_name`        | Existing key pair | SSH access             |
| `allowed_ssh_cidr`     | Operator IP `/32` | SSH source             |
| `app_port`             | `2020`            | Twenty CRM host port   |
| `ecr_repository_name`  | `twenty-crm`      | ECR repository         |
| `iam_instance_profile` | `EC2ECRPullRole`  | EC2 IAM profile        |

Example:

```hcl
aws_region           = "us-east-1"
project_name         = "twenty-crm"
environment          = "dev"
instance_type        = "t3.small"
root_volume_size     = 20
key_pair_name        = "sakhisurakhya-task7-key"
allowed_ssh_cidr     = "157.41.243.122/32"
app_port             = 2020
ecr_repository_name  = "twenty-crm"
iam_instance_profile = "EC2ECRPullRole"
```

> **Security note:** The SSH CIDR should normally be restricted to the operator's current public IP. The public IP can be checked using `curl https://checkip.amazonaws.com`.

---

# 7. Terraform Commands

Run these commands from the `terraform` directory.

### Initialize

```bash
terraform init
```

### Format

```bash
terraform fmt
```

### Validate

```bash
terraform validate
```

### Create execution plan

```bash
terraform plan -input=false
```

### Apply infrastructure

```bash
terraform apply -input=false
```

### Display outputs

```bash
terraform output
```

---

# 8. Amazon ECR

The ECR repository stores the Docker image used by the EC2 instance.

Repository:

```text
twenty-crm
```

The official Twenty production image is used:

```text
twentycrm/twenty:latest
```

The development image was intentionally not used.

## Pull the official image

```bash
docker pull twentycrm/twenty:latest
```

## Tag the image

```bash
docker tag twentycrm/twenty:latest \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest
```

## Login to ECR

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
579138738751.dkr.ecr.us-east-1.amazonaws.com
```

## Push the image

```bash
docker push \
579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest
```

## Verify the image

```bash
docker inspect \
579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest \
--format '{{json .Config.Entrypoint}}'
```

Expected entrypoint:

```text
["/app/entrypoint.sh"]
```

---

# 9. EC2 User Data

The EC2 instance uses `user_data.sh.tpl` for automatic first-boot configuration.

The script performs the following steps:

1. Starts SSH service.
2. Disables UFW.
3. Creates a 2 GB swap file.
4. Installs Docker, AWS CLI, OpenSSL and curl.
5. Starts Docker.
6. Creates the `twenty-net` Docker network.
7. Starts PostgreSQL 16.
8. Starts Redis 7.
9. Waits for PostgreSQL to become ready.
10. Authenticates to Amazon ECR using the EC2 IAM role.
11. Pulls the Twenty CRM image from ECR.
12. Generates a random application secret.
13. Retrieves the EC2 public IP using IMDSv2.
14. Starts the Twenty CRM container.
15. Waits for the application to respond.
16. Displays the running Docker containers.

### Docker architecture

```text
twenty-net
│
├── twenty-crm
│     └── Host port 2020 → Container port 3000
│
├── twenty-db
│     └── PostgreSQL 16
│
└── twenty-redis
      └── Redis 7
```

The PostgreSQL and Redis containers use Docker volumes:

```text
twenty-db-data
twenty-redis-data
```

---

# 10. Important User Data Configuration

The script uses Terraform template variables:

```text
${aws_region}
${ecr_repository_url}
${app_port}
```

Bash variables are escaped so Terraform does not interpret them:

```text
$${TOKEN}
$${PUBLIC_IP}
$${APP_SECRET}
```

The template **must not contain Markdown code fences**.

The first line must be:

```bash
#!/bin/bash
```

This is important because cloud-init expects the user-data script to begin with the shebang.

---

# 11. Verification

After Terraform apply, check the outputs:

```bash
terraform output
```

Example:

```text
app_url              = "http://<EC2_PUBLIC_IP>:2020"
ecr_repository_url   = "579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm"
instance_id          = "i-xxxxxxxxxxxxxxxxx"
instance_public_ip   = "<EC2_PUBLIC_IP>"
security_group_id    = "sg-xxxxxxxxxxxxxxxxx"
subnet_id            = "subnet-xxxxxxxxxxxxxxxxx"
vpc_id               = "vpc-xxxxxxxxxxxxxxxxx"
```

---

# 12. SSH Verification

Connect to the EC2 instance:

```bash
ssh -i <key>.pem ubuntu@<instance_public_ip>
```

Check Docker:

```bash
sudo docker ps -a
```

Expected containers:

```text
twenty-crm
twenty-db
twenty-redis
```

The Twenty CRM container should expose:

```text
0.0.0.0:2020 -> 3000/tcp
```

---

# 13. User Data Log Verification

The bootstrap script writes its output to:

```text
/var/log/twenty-crm-userdata.log
```

Check it with:

```bash
sudo tail -n 100 /var/log/twenty-crm-userdata.log
```

Expected important messages include:

```text
=== Twenty CRM bootstrap starting ===
PostgreSQL is ready
ECR login OK
EC2 public IP: <PUBLIC_IP>
Waiting for Twenty CRM...
Twenty CRM is healthy
=== Twenty CRM bootstrap completed ===
```

---

# 14. Application Verification

From the EC2 instance:

```bash
curl -s http://localhost:2020 | head -3
```

Expected response begins with:

```html
<!doctype html>
<html lang="en" translate="no" class="light">
```

The application can also be opened from a browser:

```text
http://<EC2_PUBLIC_IP>:2020
```

The Twenty CRM welcome page should be displayed.

---

# 15. Issues Encountered and Resolutions

## Issue 1 — Security Group creation denied

### Problem

Terraform initially returned:

```text
UnauthorizedOperation: ec2:CreateSecurityGroup
```

### Cause

The AWS IAM user had a policy restriction preventing Security Group creation.

### Resolution

The Terraform configuration was adjusted to work with the permissions available in the provided AWS account and to manage the required Security Group configuration.

---

## Issue 2 — Incorrect AMI

### Problem

The initial AMI selection did not match the instructor-provided AMI.

### Resolution

The EC2 configuration was changed to the instructor-specified Ubuntu AMI:

```text
ami-0b6d9d3d33ba97d99
```

Region:

```text
us-east-1
```

---

## Issue 3 — SSH connection refused

### Problem

SSH was unavailable immediately after EC2 startup.

### Cause

The initial user-data configuration could terminate early before SSH was explicitly started.

### Resolution

The script now starts SSH at the beginning:

```bash
systemctl enable ssh
systemctl start ssh
```

The script also uses:

```bash
set -uo pipefail
```

instead of `set -euo pipefail`, preventing one transient command failure from terminating the entire bootstrap process.

---

## Issue 4 — User Data was not executed

### Problem

Cloud-init skipped the user-data script.

### Cause

The template contained Markdown code fences:

````text
```bash
````

Cloud-init therefore did not recognize the file as a shell script.

### Resolution

The Markdown fences were removed.

The first line of `user_data.sh.tpl` is now:

```bash
#!/bin/bash
```

---

## Issue 5 — SSH IP changed

### Problem

SSH access failed even though the Security Group was configured with the current public IP.

### Cause

The ISP uses Carrier-Grade NAT, so the public IP can change.

### Resolution

The SSH CIDR was temporarily widened for troubleshooting and then restricted again.

For normal use, SSH should remain restricted to the current operator IP whenever possible.

---

## Issue 6 — Wrong Twenty CRM Docker image

### Problem

The application initially used:

```text
twentycrm/twenty-app-dev:latest
```

This is the development image and did not provide the expected production server behavior.

### Resolution

The production image was used:

```text
twentycrm/twenty:latest
```

The production image uses:

```text
/app/entrypoint.sh
```

and listens on container port:

```text
3000
```

---

## Issue 7 — Twenty CRM could not connect to PostgreSQL

### Problem

The application initially attempted to connect to PostgreSQL before the database was ready.

### Resolution

The deployment was changed to:

* Create a shared Docker network.
* Use `twenty-db` as the PostgreSQL hostname.
* Wait for PostgreSQL using `pg_isready`.

Database connection:

```text
postgres://postgres:postgres@twenty-db:5432/default
```

---

## Issue 8 — HEAD request returned connection reset

### Problem

A test using:

```bash
curl -I http://localhost:2020
```

returned a connection reset.

### Cause

The request used the HTTP `HEAD` method.

### Resolution

A normal GET request was used instead:

```bash
curl -s http://localhost:2020
```

The application returned the expected HTML response.

---

# 16. Final Infrastructure

The final configuration uses:

| Component         | Configuration                      |
| ----------------- | ---------------------------------- |
| Region            | `us-east-1`                        |
| VPC               | Existing default VPC               |
| Subnet            | First available default VPC subnet |
| AMI               | `ami-0b6d9d3d33ba97d99`            |
| OS                | Ubuntu 26.04                       |
| Instance          | `t3.small`                         |
| Storage           | 20 GiB gp3                         |
| Application Port  | `2020`                             |
| Container Port    | `3000`                             |
| Database          | PostgreSQL 16                      |
| Cache             | Redis 7                            |
| Container Network | `twenty-net`                       |
| Registry          | Amazon ECR                         |
| Repository        | `twenty-crm`                       |

---

# 17. Security Considerations

* SSH access should be restricted to a trusted IP/CIDR.
* Application port `2020` is publicly accessible for demonstration.
* ECR access is performed using the EC2 IAM instance profile.
* The application secret is generated dynamically during boot.
* PostgreSQL is not directly exposed to the internet.
* Redis is not directly exposed to the internet.
* Database credentials used in this task are demonstration credentials and should not be used for production.
* For production deployments, use AWS Secrets Manager or another secure secret-management solution.

---

# 18. Cleanup

Task 12 requires the infrastructure to be destroyed after verification.

Run:

```bash
terraform destroy
```

Confirm the destruction when prompted.

### Verify EC2 cleanup

```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Project,Values=twenty-crm" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table
```

### Verify ECR cleanup

```bash
aws ecr describe-repositories \
  --region us-east-1 \
  --query "repositories[?repositoryName=='twenty-crm'].repositoryName"
```

The resources should no longer exist after successful cleanup.

---

# 19. Key Learnings

This task provided hands-on experience with:

* Terraform infrastructure provisioning
* AWS EC2
* Amazon ECR
* Default VPC and subnet selection
* EC2 Security Groups
* IAM instance profiles
* Docker on EC2
* Docker networking
* PostgreSQL and Redis containers
* EC2 User Data and cloud-init
* IMDSv2
* ECR authentication
* Terraform variables and outputs
* Infrastructure validation and cleanup
* Troubleshooting AWS permissions and networking issues

---

