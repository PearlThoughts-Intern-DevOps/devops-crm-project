# Task 12: Terraform + AWS Infrastructure

## 1. Objective

The objective of this task was to use Terraform to provision the basic AWS infrastructure required for Twenty CRM and deploy the Twenty CRM Docker image using Amazon ECR.

The infrastructure provisioned using Terraform includes:

* Existing/default VPC and subnet
* EC2 instance
* Security Group
* Amazon ECR repository

No new VPC was created.

---

## 2. Terraform Project Structure

```text
terraform/
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── .terraform.lock.hcl
```

### Files

* `provider.tf` – Configures Terraform and the AWS provider.
* `main.tf` – Defines the AWS resources and EC2 User Data.
* `variables.tf` – Defines configurable Terraform variables.
* `terraform.tfvars` – Provides values for the variables.
* `outputs.tf` – Displays important resource information after deployment.
* `.terraform.lock.hcl` – Locks the selected provider version.

---

## 3. AWS Provider Configuration

The AWS provider was configured for:

```text
us-east-1
```

The region is defined using the `aws_region` variable.

---

## 4. Existing VPC and Subnet

The existing/default AWS VPC was used instead of creating a new VPC.

The following existing resources were used:

```text
VPC: vpc-04b47886866017101
Subnet: subnet-0a593f32ba819948d
```

The VPC ID and subnet ID were provided through Terraform variables.

---

## 5. EC2 Configuration

Terraform was used to create an EC2 instance for running Twenty CRM.

Configuration included:

* Instance type: `t3.small`
* Existing VPC subnet
* Existing IAM instance profile: `EC2ECRPullRole`
* 20 GB `gp3` root volume
* Security Group for SSH and application traffic

The EC2 instance was successfully created and started.

---

## 6. Security Group

A Terraform-managed Security Group was created for the EC2 instance.

The following inbound traffic was allowed:

* Port `22` – SSH
* Port `3000` – Twenty CRM application

Outbound traffic was allowed for all destinations so that the instance could download packages and communicate with AWS ECR.

---

## 7. Amazon ECR

Terraform created an Amazon ECR repository named:

```text
twenty-crm
```

Image scanning on push was enabled.

The ECR repository URL was:

```text
147997123166.dkr.ecr.us-east-1.amazonaws.com/twenty-crm
```

---

## 8. Terraform Variables

The following configurable values were defined:

* AWS region
* Project name
* EC2 instance type
* ECR repository name
* VPC ID
* Subnet ID

This keeps the Terraform configuration reusable instead of hardcoding these values throughout the configuration.

---

## 9. Terraform Outputs

The following outputs were configured:

* Existing VPC ID
* EC2 instance ID
* EC2 public IP
* ECR repository URL

These outputs make it easier to identify and use the created infrastructure.

---

## 10. Terraform Commands

The following commands were executed.

### Initialize Terraform

```bash
terraform init
```

This initialized the Terraform project and downloaded the required AWS provider.

### Validate Configuration

```bash
terraform validate
```

This verified that the Terraform configuration syntax and structure were valid.

### Create Execution Plan

```bash
terraform plan
```

This displayed the resources Terraform planned to create or modify.

### Apply Configuration

```bash
terraform apply
```

This provisioned the AWS infrastructure.

The Terraform apply completed successfully.

---

## 11. Docker Image Build

A separate Dockerfile was created for the AWS/ECR deployment:

```text
Dockerfile.aws
```

It uses the official Twenty CRM Docker image as the base image.

The image was built locally using:

```bash
docker build -f Dockerfile.aws -t twenty-crm:latest .
```

---

## 12. Amazon ECR Authentication

Authentication with Amazon ECR was performed using:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 147997123166.dkr.ecr.us-east-1.amazonaws.com/twenty-crm
```

The login completed successfully.

---

## 13. Docker Image Tagging

The local Twenty CRM image was tagged using the ECR repository URL:

```bash
docker tag twenty-crm:latest 147997123166.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest
```

---

## 14. Docker Image Push

The Docker image was pushed to Amazon ECR using:

```bash
docker push 147997123166.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest
```

The push completed successfully and the image was available in the ECR repository.

---

## 15. EC2 User Data

Terraform User Data was configured to automate the EC2 setup.

The User Data performs the following steps:

1. Updates the operating system packages.
2. Installs Docker.
3. Installs AWS CLI and required utilities.
4. Creates additional swap space for the application.
5. Starts and enables Docker.
6. Retrieves the EC2 public IP.
7. Creates the application directory.
8. Authenticates with Amazon ECR.
9. Attempts to pull the Twenty CRM image from ECR.
10. Retries the image pull periodically if the image is not available.
11. Creates a Docker network.
12. Starts PostgreSQL.
13. Starts Redis.
14. Waits for PostgreSQL and Redis to become ready.
15. Starts the Twenty CRM application.
16. Starts the Twenty CRM worker.

The ECR image pull uses a retry mechanism because the EC2 instance may start before the Docker image is pushed to ECR.

---

## 16. Twenty CRM Verification

After the EC2 instance was configured, the Twenty CRM containers were verified using Docker commands.

The application was accessed through:

```text
http://<EC2-PUBLIC-IP>:3000
```

Twenty CRM successfully opened in the browser and displayed the application setup/profile screen.

This confirmed that the application was running successfully on the EC2 instance.

---

## 17. Issues Encountered

### Issue 1: EC2 Disk Space

Initially, the EC2 root volume had insufficient disk space for the Docker images.

The root filesystem was almost full.

Cleanup commands were executed:

```bash
sudo apt-get clean
sudo journalctl --vacuum-size=50M
```

However, additional space was required.

The Terraform EC2 root volume was therefore increased to 20 GB.

After the Terraform update, the root partition was expanded using:

```bash
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
```

After resizing, sufficient disk space was available for Docker and Twenty CRM.

---

### Issue 2: Twenty CRM Database Initialization

After the initial container startup, Twenty CRM reported missing database tables.

The database initialization command was executed inside the Twenty CRM container:

```bash
sudo docker exec twenty-crm yarn database:init:prod
```

This initialized the required database structure and migrations.

After initialization, Twenty CRM started successfully and became accessible through the browser.

---

## 18. Verification Summary

The following components were successfully verified:

* Terraform configuration
* Existing/default VPC usage
* EC2 instance
* Security Group
* Amazon ECR repository
* Docker image build
* ECR authentication
* Docker image tagging
* Docker image push
* PostgreSQL container
* Redis container
* Twenty CRM application
* Twenty CRM browser access

---

## 19. Git Branch

The task was completed on the following branch:

```text
tannu-task-12
```

The Terraform files and related deployment files were added to this branch.

---

## 20. Pull Request

A Pull Request will be raised from:

```text
tannu-task-12
```

into the project's main branch.

The PR will contain the Terraform configuration, Dockerfile, and Task 12 documentation.

---

## 21. Loom Video

A Loom video will be recorded explaining:

* Terraform project structure
* AWS provider configuration
* Variables and outputs
* Existing VPC and subnet usage
* EC2 configuration
* ECR configuration
* EC2 User Data
* Terraform commands
* Docker image build and ECR push
* Twenty CRM verification
* Issues encountered and their resolution

The face will remain visible throughout the Loom video as required.

---

## 22. Cleanup

After completing all verification, Terraform cleanup will be performed using:

```bash
terraform destroy
```

Terraform-managed resources will then be verified in the AWS console to ensure that the resources created for this task have been removed.

AWS credentials are kept confidential and are not included in the repository.
