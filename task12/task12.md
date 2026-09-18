Task 12: Terraform + AWS Infrastructure

Name: Barani Krishnan G  
Branch: `bkkrish007-task12`  
AWS Region: `us-east-1`  
Date: 9 September 2026  

---

1. Task Information

| Attribute | Details |
| :--- | :--- |
| **Engineer Name** | Barani Krishnan G |
| **Domain** | DevOps |
| **Task Number** | Task 12 |
| **Task Title** | Terraform + AWS Infrastructure Deployment |
| **Project** | Twenty CRM (`devops-crm-project`) |
| **Git Branch** | `bkkrish007-task12` |
| **Target Branch** | `main` |
| **AWS Region** | `us-east-1` |
| **Infrastructure Tool** | HashiCorp Terraform |
| **Container Platform** | Docker & Docker Compose v2 |
| **Registry** | Amazon Elastic Container Registry (ECR) |

---

2. Objective

The primary objective of this task was to provision and automate the cloud infrastructure required for the Twenty CRM application on Amazon Web Services (AWS) using HashiCorp Terraform as Infrastructure as Code (IaC).

Key deliverables and architectural goals:
- Utilize existing/default AWS VPC and subnet without provisioning redundant networking infrastructure.
- Provision a dedicated AWS Security Group exposing ports `22` (SSH), `2020` (Twenty CRM Backend), and `3000` (Custom CRM App).
- Create an Amazon ECR (Elastic Container Registry) repository with AES-256 encryption and image scanning on push.
- Provision an AWS EC2 instance (`t3.small`) attached to an IAM instance profile (`EC2ECRPullRole`).
- Implement an automated, idempotent EC2 `user_data` bootstrap script to install Docker, configure Docker Compose, authenticate to ECR, pull container images with retry logic, and launch application containers.
- Build and push the custom Twenty CRM Docker image to Amazon ECR.
- Validate application accessibility, memory utilization, swap configuration, and lifecycle cleanup via `terraform destroy`.

---

3. Project Structure

The project is structured under the `task12/` directory with a dedicated `terraform/` module:

```text
task12/
├── task12.md
└── terraform/
    ├── .gitignore
    ├── .terraform.lock.hcl
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfvars
    ├── terraform.tfvars.example
    ├── variables.tf
    └── versions.tf
```

File Descriptions

| File | Purpose / Responsibility |
| :--- | :--- |
| `main.tf` | Declares AWS provider data sources, Security Group, ECR repository, EC2 instance, and bootstrap User Data script. |
| `variables.tf` | Declares all configurable Terraform variables with explicit data types, descriptions, and defaults. |
| `outputs.tf` | Exposes critical infrastructure outputs (Instance ID, Public IP, DNS, ECR URL, Security Group ID, Subnet ID, VPC ID). |
| `versions.tf` | Locks required Terraform core version (`>= 1.5.0`) and AWS provider version (`~> 5.0`). |
| `terraform.tfvars` | Local variable definitions containing active workspace configurations. |
| `terraform.tfvars.example` | Template demonstrating variable definitions for team collaboration. |
| `.gitignore` | Ensures state files (`*.tfstate`), credentials, and cache directories are excluded from version control. |
| `task12.md` | Comprehensive technical task documentation and deployment guide. |

---

4. AWS Provider Configuration

Terraform was configured to use the AWS provider in the `us-east-1` region. Authentication was established locally using the AWS Command Line Interface (CLI):

```bash
aws configure
```

> **Note:** AWS credentials (access keys, secret keys, session tokens) are managed securely through local AWS CLI configuration profiles and environment variables, ensuring zero secrets are committed to the repository.

---

5. Infrastructure Resources Specification

5.1 VPC & Subnet (Data Sources)

The configuration queries existing AWS infrastructure to minimize cost and prevent duplicate resource creation:

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = tolist(data.aws_subnets.default.ids)[0]
}
```

5.2 Security Group

A custom security group (`twenty-crm-dev-sg`) controls ingress and egress traffic:

| Direction | Protocol | Port Range | Source / Destination | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Ingress** | TCP | `22` | `0.0.0.0/0` | Secure Shell (SSH) remote administrative access |
| **Ingress** | TCP | `2020` | `0.0.0.0/0` | Twenty CRM core backend service |
| **Ingress** | TCP | `3000` | `0.0.0.0/0` | Custom CRM application frontend |
| **Egress** | ALL | ALL | `0.0.0.0/0` | Outbound internet access for package updates and image pulling |

5.3 Amazon Elastic Container Registry (ECR)

An ECR repository was created for storing container images:
- **Repository Name:** `twenty-crm`
- **Tag Mutability:** `MUTABLE`
- **Encryption:** Server-Side Encryption with `AES256`
- **Image Scanning:** `scan_on_push = true`

5.4 Compute Instance (Amazon EC2)

- **Instance Type:** `t3.small` (2 vCPU, 2 GiB RAM)
- **AMI:** Ubuntu 22.04 LTS (`ami-0b6d9d3d33ba97d99`)
- **IAM Instance Profile:** `EC2ECRPullRole` (grants permission to authenticate and pull from ECR)
- **Storage:** 20 GiB `gp3` root volume (Encrypted, `delete_on_termination = true`)
- **Lifecycle:** `user_data_replace_on_change = true`

---

6. Terraform Lifecycle & Execution Commands

6.1 Initialize Working Directory

Initializes provider plugins and configures backend:

```bash
terraform init
```

6.2 Code Formatting

Ensures canonical HCL styling across all `.tf` files:

```bash
terraform fmt
```

6.3 Syntax & Schema Validation

Validates configuration syntax and resource parameters:

```bash
terraform validate
```

*Expected output:*
```text
Success! The configuration is valid.
```

6.4 Execution Planning

Generates an execution plan to preview resource additions and modifications:

```bash
terraform plan
```

6.5 Infrastructure Provisioning

Applies the execution plan against AWS:

```bash
terraform apply -auto-approve
```

6.6 Inspect Outputs

Retrieves provisioned resource metadata:

```bash
terraform output
```

*Sample output:*
```text
ec2_instance_id    = "i-02c7b9cc544176550"
ec2_public_dns     = "ec2-3-231-157-63.compute-1.amazonaws.com"
ec2_public_ip      = "3.231.157.63"
ecr_repository_url = "579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm"
security_group_id  = "sg-0923f6e5a1e6d8ae1"
subnet_id          = "subnet-078d52bfe579c74f2"
vpc_id             = "vpc-0c241509159132524"
```

6.7 State Verification

Lists all resources currently tracked in the state file:

```bash
terraform state list
```

---

7. Docker Image Build & ECR Push Workflow

The Twenty CRM container image was built locally and pushed to the provisioned Amazon ECR repository:

Step 1: Build Image Locally

```bash
docker build -t twenty-crm:latest .
```

Step 2: Retrieve ECR URL and Authenticate

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION="us-east-1"

aws ecr get-login-password --region "${AWS_REGION}" | \
  docker login --username AWS --password-stdin "${ECR_URL}"
```

Step 3: Tag and Push Image to ECR

```bash
docker tag twenty-crm:latest "${ECR_URL}:latest"
docker push "${ECR_URL}:latest"
```

Step 4: Verify Image in ECR

```bash
aws ecr describe-images \
  --repository-name twenty-crm \
  --region us-east-1 \
  --output table
```

---

8. EC2 User Data Automation

The EC2 instance is configured with an automated bash User Data script that executes upon first boot:

```bash
#!/bin/bash
set -eux
exec >> /var/log/twenty-crm-user-data.log 2>&1

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  awscli \
  docker.io \
  docker-compose-v2

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

AWS_REGION="us-east-1"
ECR_REGISTRY="<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/twenty-crm"
CUSTOM_IMAGE="${ECR_REGISTRY}:latest"

# Write Docker Compose configuration
cat > /opt/twenty-crm/docker-compose.yml <<COMPOSE
services:
  twenty-server:
    image: twentycrm/twenty-app-dev:latest
    container_name: twenty-server
    ports:
      - "2020:2020"
    environment:
      PORT: "2020"
      SERVER_URL: "http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):2020"
      NODE_ENV: "development"
      STORAGE_TYPE: "local"
      APPLICATION_LOG_DRIVER: "CONSOLE"
    volumes:
      - twenty-dev-data:/data/postgres
      - twenty-dev-storage:/app/packages/twenty-server/.local-storage
    restart: unless-stopped

  crm-app:
    image: "${CUSTOM_IMAGE}"
    container_name: crm-app
    depends_on:
      - twenty-server
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: "production"
      PORT: "3000"
      TWENTY_API_URL: "http://twenty-server:2020"
      TWENTY_API_KEY: "secret-key"
    restart: unless-stopped

volumes:
  twenty-dev-data:
  twenty-dev-storage:
COMPOSE

# ECR Authentication with Retry
until aws ecr get-login-password \
  --region "${AWS_REGION}" | docker login \
  --username AWS \
  --password-stdin "${ECR_REGISTRY%/*}"
do
  sleep 10
done

# Image Pull with Retry
until docker pull "${CUSTOM_IMAGE}"
do
  sleep 15
done

# Start Application Containers
docker compose -f /opt/twenty-crm/docker-compose.yml up -d
```

---

9. Verification & Validation Testing

9.1 Remote SSH Connection

```bash
ssh -i /path/to/key.pem ubuntu@3.231.157.63
```

9.2 Inspect Cloud-Init & User Data Logs

```bash
tail -f /var/log/twenty-crm-user-data.log
```

9.3 Container Health Verification

```bash
sudo docker ps
```

*Expected output:* Both `twenty-server` and `crm-app` containers running with health status `Up`.

9.4 Listening Ports Check

```bash
sudo ss -lntp | grep -E ':2020|:3000'
```

9.5 HTTP Endpoint Verification

```bash
curl -I http://127.0.0.1:2020
```

*Response:*
```http
HTTP/1.1 200 OK
```

The Twenty CRM web dashboard is publicly accessible via:
```text
http://3.231.157.63:2020
```

---

10. Memory & Swap Configuration

Because the `t3.small` instance provides 2 GiB of physical memory, running the full Twenty CRM stack along with PostgreSQL requires proactive memory management:

10.1 Memory Inspection

```bash
free -h
```

10.2 Swap Verification

```bash
swapon --show
```

10.3 Live Container Resource Utilization

```bash
sudo docker stats --no-stream
```

> **Finding:** A 2 GiB swap space prevents potential Out-Of-Memory (OOM) kills during heavy compilation and startup cycles of the Twenty CRM backend.

---

11. Issues Encountered & Resolution

| No. | Issue Identified | Root Cause | Resolution Applied |
| :-: | :--- | :--- | :--- |
| **1** | **User Data Syntax Error** | Bash arithmetic expression `$$(($$attempt + 1))` in Terraform heredoc caused cloud-init parser failure on `part-001`. | Replaced the counter while loop with standard POSIX-compliant `until aws ecr get-login-password ...` and `until docker pull ...` retry blocks. |
| **2** | **Invalid `SERVER_URL` Format** | `SERVER_URL` environment variable accidentally contained Markdown link markup (`[http://...](http://...)`). | Corrected to raw URL string: `http://$$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):2020`. |
| **3** | **Port 3000 Web Server Inactive** | Custom `crm-app` container executed build artifact generation command rather than continuous web server process. | Twenty CRM backend on port `2020` operated properly; documented the frontend container build behavior and requirements. |
| **4** | **Memory Constraint on `t3.small`** | Twenty CRM backend and dependencies consumed near 2 GiB RAM capacity. | Configured 2 GiB swap file on the host OS to stabilize memory utilization under load. |

---

12. Infrastructure Cleanup (Teardown)

To prevent ongoing AWS compute and storage charges, all provisioned resources were decommissioned using Terraform:

```bash
terraform destroy -auto-approve
```

Teardown State Verification

```bash
terraform state list
```

*Verification via AWS CLI:*
```bash
aws ec2 describe-instances \
  --instance-ids "i-02c7b9cc544176550" \
  --region us-east-1 \
  --query 'Reservations[].Instances[].State.Name' \
  --output text
```
*Expected State:* `terminated`

---

13. Git Workflow & Pull Request Details

13.1 Branch Management

The entire implementation was developed and committed on a dedicated feature branch:

```bash
git checkout -b bkkrish007-task12
```

13.2 Sensitive Files Check

Ensured `.gitignore` excludes credentials, secrets, and state files:
```text
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
*.pem
.env
```

13.3 Staging and Committing Changes

```bash
git add task12/task12.md \
        task12/terraform/main.tf \
        task12/terraform/variables.tf \
        task12/terraform/outputs.tf \
        task12/terraform/versions.tf \
        task12/terraform/terraform.tfvars.example \
        task12/terraform/.gitignore

git commit -m "Add Terraform AWS infrastructure and documentation for Task 12"
git push -u origin bkkrish007-task12
```

13.4 Pull Request Information

- **Title:** `Task 12: Terraform AWS Infrastructure for Twenty CRM`
- **Base Branch:** `main`
- **Compare Branch:** `bkkrish007-task12`
- **Repository:** `PearlThoughts-Intern-DevOps/devops-crm-project`

---

14. Deliverables & Screenshots Checklist

- [x] `terraform init` initialization screenshot
- [x] `terraform fmt` & `terraform validate` validation screenshot
- [x] `terraform plan` execution preview screenshot
- [x] `terraform apply` provisioning completion screenshot
- [x] `terraform output` resource values screenshot
- [x] `terraform state list` state verification screenshot
- [x] Docker image build screenshot
- [x] Amazon ECR login screenshot
- [x] Docker image push to Amazon ECR screenshot
- [x] EC2 User Data execution log (`/var/log/twenty-crm-user-data.log`)
- [x] Docker container status (`docker ps`) on EC2
- [x] Twenty CRM web application running on port `2020`
- [x] `terraform destroy` teardown completion screenshot
- [x] Post-teardown resource verification screenshot
- [x] Loom walkthrough video recording attached to PR description
