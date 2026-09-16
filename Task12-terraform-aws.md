# Task 12: Terraform + AWS Infrastructure

## Overview

In this task, Terraform was used to provision the basic AWS infrastructure required for the **Twenty CRM** application and deploy the Docker container image through **Amazon Elastic Container Registry (ECR)** to an **Amazon EC2** instance.

The deployment automates the infrastructure lifecycle and instance bootstrap:
- **VPC**: Utilized the existing default VPC and subnet in AWS region `us-east-1` (no new VPC was created).
- **Amazon ECR**: Provisioned a dedicated private container registry (`mohit-twenty-crm`).
- **Amazon EC2**: Provisioned a `t3.small` instance attached to an existing IAM role (`EC2ECRPullRole`) and custom security group.
- **Docker Image**: Built the Twenty CRM application image locally, tagged it, and pushed it to Amazon ECR.
- **EC2 User Data**: Automated the instance bootstrap to configure swap space, install Docker and AWS CLI, authenticate to Amazon ECR, pull the Twenty CRM image with periodic retry logic, and run the container.
- **Verification**: Confirmed successful deployment, port reachability, and HTTP 200 OK status from the Twenty CRM application web server and `/healthz` health check endpoint.

---

## 1. Terraform Project Structure

The project was organized according to Terraform best practices in the `terraform/` directory:

```text
terraform/
├── main.tf                  # Data sources, security group, ECR repository, EC2 instance
├── provider.tf              # AWS provider configuration for us-east-1
├── terraform.tf             # Terraform minimum version and required providers
├── variables.tf             # Input variable definitions with types and defaults
├── outputs.tf               # Infrastructure outputs (IPs, URLs, IDs, endpoints)
├── terraform.tfvars         # Variable values for deployment
├── terraform.tfvars.example # Example variable file template
└── user-data.sh             # EC2 startup bootstrap script
```

### Key Configuration Details

#### 1. Provider & Versions (`terraform.tf`, `provider.tf`)
Configured the HashiCorp AWS provider (`~> 5.92`) restricted to region `us-east-1`.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = var.aws_region
}
```

#### 2. Variables (`variables.tf`, `terraform.tfvars`)
Configurable values were decoupled using variables:

| Variable Name | Description | Value Used |
|---|---|---|
| `aws_region` | AWS Region | `us-east-1` |
| `environment` | Environment name | `dev` |
| `project_name` | Project identifier | `twenty-crm-mohit` |
| `instance_type` | EC2 instance type | `t3.small` |
| `key_name` | Existing AWS Key Pair | `mohit-singh` |
| `ami_id` | Operating system AMI | `ami-0b6d9d3d33ba97d99` (Ubuntu 24.04 LTS) |
| `ecr_repository_name` | Amazon ECR repo name | `mohit-twenty-crm` |
| `docker_image_tag` | Target image tag | `latest` |
| `iam_instance_profile` | IAM instance profile | `EC2ECRPullRole` |
| `app_port` | Application host port | `2020` |
| `allowed_cidr_blocks` | Inbound network CIDR | `["0.0.0.0/0"]` |

#### 3. Main Infrastructure (`main.tf`)
- **Default VPC & Subnets**: Queried existing default VPC (`data "aws_vpc" "default"`) and default subnets (`data "aws_subnets" "default"`).
- **Security Group**: Allows inbound SSH (port 22) and Twenty CRM application (port 2020), with all outbound traffic allowed.
- **ECR Repository**: Created private repository `mohit-twenty-crm` with `image_scanning_configuration` enabled and mutable tags.
- **EC2 Instance**: Launched `t3.small` instance with:
  - 20 GB gp3 root storage volume.
  - IAM profile `EC2ECRPullRole` for credential-free ECR pulls.
  - Public IPv4 enabled.
  - `user_data` templated via `templatefile("${path.module}/user-data.sh", ...)`.

#### 4. EC2 User Data Bootstrap (`user-data.sh`)
The bootstrap script handles:
1. **Swap Allocation**: Adds 4 GB of swap space to prevent memory exhaustion on the `t3.small` instance during Docker and database operations.
2. **Package Installation**: Installs `docker.io`, `awscli`, and enables the Docker service.
3. **ECR Authentication**: Uses the instance profile credentials via `aws ecr get-login-password` to log in to Amazon ECR.
4. **Periodic Retry Pull Loop**: Retries pulling the Docker image every 10–15 seconds for up to 40 attempts, ensuring resilience if the EC2 instance finishes booting before the local Docker image push completes.
5. **Application Container Launch**: Runs the Twenty CRM container on host port `2020:2020` with restart policy `unless-stopped`.

---

## 2. Execution Steps & Commands

### Step 2.1: Terraform Initialization & Validation
Initialized the AWS provider and validated configuration syntax:

```bash
cd terraform
terraform init
terraform validate
```

**Output**:
```text
Terraform has been successfully initialized!
Success! The configuration is valid.
```

### Step 2.2: Terraform Plan
Generated the execution plan to verify intended resources:

```bash
terraform plan
```

**Plan summary**:
```text
Plan: 3 to add, 0 to change, 0 to destroy.

  + aws_ecr_repository.twenty_crm (mohit-twenty-crm)
  + aws_security_group.twenty_crm (twenty-crm-mohit-dev-sg)
  + aws_instance.twenty_crm (twenty-crm-mohit-dev)
```

### Step 2.3: Terraform Apply
Applied the plan to provision resources:

```bash
terraform apply -auto-approve
```

**Terraform Outputs Captured**:
```text
aws_region          = "us-east-1"
vpc_id              = "vpc-0c241509159132524"
subnet_id           = "subnet-078d52bfe579c74f2"
security_group_id   = "sg-0942adf3a0c3104c8"
ecr_repository_name = "mohit-twenty-crm"
ecr_repository_url  = "579138738751.dkr.ecr.us-east-1.amazonaws.com/mohit-twenty-crm"
ec2_instance_id     = "i-086ad4271f306a6ca"
ec2_public_ip       = "34.201.15.244"
ec2_public_dns      = "ec2-34-201-15-244.compute-1.amazonaws.com"
twenty_crm_url      = "http://34.201.15.244:2020"
```

---

### Step 2.4: Local Docker Build, Tag, and Push to Amazon ECR

#### 1. Build Twenty CRM Docker Image
Built the image locally:

```bash
docker build -t twenty-crm:latest -f Dockerfile.twenty .
```

#### 2. Tag for Amazon ECR
Tagged the image with the Terraform ECR output repository URI:

```bash
docker tag twenty-crm:latest 579138738751.dkr.ecr.us-east-1.amazonaws.com/mohit-twenty-crm:latest
```

#### 3. Authenticate with Amazon ECR
Authenticated the local Docker daemon using AWS CLI:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 579138738751.dkr.ecr.us-east-1.amazonaws.com
```

**Output**:
```text
Login Succeeded
```

#### 4. Push Image to Amazon ECR
Pushed the tagged image to the repository:

```bash
docker push 579138738751.dkr.ecr.us-east-1.amazonaws.com/mohit-twenty-crm:latest
```

**Output**:
```text
latest: digest: sha256:3234894dbf6248d6813454a84af2ffc19b70666a02142abb3168e1d5fec1acad size: 5731
```

---

## 3. Issues Encountered and Technical Solutions

### Issue 1: Missing Terraform Binary on Controller Machine
- **Symptom**: `terraform` was not found in `$PATH`. Package manager had an active dpkg lock from background unattended upgrades.
- **Solution**: Directly fetched official HashiCorp release binary `terraform_1.9.5_linux_amd64.zip`, unzipped, and installed to `/usr/local/bin/terraform`.

### Issue 2: IAM Permission Denied on SSM Parameter Store (`ssm:GetParameter`)
- **Symptom**: Querying `/aws/service/ami-amazon-linux-latest/...` via `data "aws_ssm_parameter"` resulted in `AccessDeniedException: ... not authorized to perform: ssm:GetParameter`.
- **Solution**: Replaced the SSM parameter query with configurable `ami_id` variable and `data "aws_ami"` filter fallback.

### Issue 3: IAM Policy Denied Custom Volume Size & Tags (`DevOpsInternEC2Access`)
- **Symptom**: Initial `ec2:RunInstances` failed with `403 UnauthorizedOperation: User ... not authorized to perform: ec2:RunInstances on resource: ...:volume/* with an explicit deny in an identity-based policy: DevOpsInternEC2Access`.
- **Root Cause**: The IAM policy restricted EBS volumes to a maximum size of 20 GB and denied custom volume tags.
- **Solution**: Set `volume_size = 20` and removed custom tags on `root_block_device`.

### Issue 4: Restricted AMI IDs in IAM Policy
- **Symptom**: `RunInstances` returned `403 UnauthorizedOperation` for non-whitelisted AMI IDs.
- **Solution**: Used the approved Ubuntu 24.04 LTS AMI (`ami-0b6d9d3d33ba97d99`), matching the successful deployment from Task 7.

### Issue 5: Asynchronous ECR Availability
- **Symptom**: When EC2 instances boot, they may run user data before the image push completes locally.
- **Solution**: Built an automated retry loop with exponential/periodic polling in `user-data.sh`. The instance logged into ECR and polled until the image was available, then pulled and started the container seamlessly.

---

## 4. Verification and Results

### 4.1 ECR Repository and Image Verification
Verified image in Amazon ECR via AWS CLI:

```bash
aws ecr describe-images --region us-east-1 --repository-name mohit-twenty-crm
```

**Result**:
- Repository: `mohit-twenty-crm`
- Digest: `sha256:3234894dbf6248d6813454a84af2ffc19b70666a02142abb3168e1d5fec1acad`
- Tag: `latest`
- Status: `ACTIVE`
- Last Recorded Pull Time: `2026-09-10T07:20:48.594000+00:00` (confirming successful pull by the EC2 instance).

### 4.2 EC2 Network Verification
Verified open ports on the instance (`34.201.15.244`):

```bash
nc -zv -w 5 34.201.15.244 22
nc -zv -w 5 34.201.15.244 2020
```

**Result**:
```text
Connection to 34.201.15.244 22 port [tcp/ssh] succeeded!
Connection to 34.201.15.244 2020 port [tcp] succeeded!
```

### 4.3 HTTP Web Endpoint Verification
Tested HTTP GET request against the Twenty CRM application endpoint:

```bash
curl -I http://34.201.15.244:2020
```

**Result**:
```http
HTTP/1.1 200 OK
X-Powered-By: Express
Vary: Origin
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Content-Type: text/html; charset=utf-8
Content-Length: 34746
Date: Thu, 10 Sep 2026 07:29:35 GMT
Connection: keep-alive
```

Checking HTML page title:
```bash
curl -s http://34.201.15.244:2020 | grep -i "<title>"
```
**Result**:
```html
    <title>Twenty</title>
```

### 4.4 Health Check Endpoint Verification
Tested `/healthz` health check endpoint:

```bash
curl -s http://34.201.15.244:2020/healthz
```

**Result**:
```json
{"status":"ok","info":{},"error":{},"details":{}}
```

---

## 5. Summary Table of Provisioned Resources

| Resource | AWS Identifier | Details |
|---|---|---|
| **VPC** | `vpc-0c241509159132524` | Default VPC in `us-east-1` (CIDR: 172.31.0.0/16) |
| **Subnet** | `subnet-078d52bfe579c74f2` | Default public subnet in `us-east-1a` |
| **Security Group** | `sg-0942adf3a0c3104c8` | `twenty-crm-mohit-dev-sg` (Inbound: 22, 2020) |
| **ECR Repository** | `mohit-twenty-crm` | `579138738751.dkr.ecr.us-east-1.amazonaws.com/mohit-twenty-crm` |
| **EC2 Instance** | `i-086ad4271f306a6ca` | `t3.small` (`34.201.15.244`), Ubuntu 24.04 LTS |
| **IAM Profile** | `EC2ECRPullRole` | Attached to EC2 for ECR image pull authentication |
| **App Access URL** | `http://34.201.15.244:2020` | Live Twenty CRM Web Application |
| **Health Check** | `http://34.201.15.244:2020/healthz` | HTTP 200 `{"status":"ok"}` |
