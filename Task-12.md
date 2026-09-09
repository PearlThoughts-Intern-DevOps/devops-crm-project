# Task 12: Terraform + AWS Infrastructure

## Objective

The objective of this task was to provision the basic AWS infrastructure required for the Twenty CRM application using Terraform and deploy the Docker image through Amazon ECR.

The infrastructure included:

* Existing/default VPC and subnet
* Amazon EC2
* Amazon ECR
* Docker-based Twenty CRM deployment

---

## 1. Terraform Project Structure

The Terraform configuration was organized separately inside the `terraform` directory.

```text
devops-crm-project/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── user_data.sh
├── Dockerfile
├── docker-compose.yml
└── Task-12.md
```

---

## 2. AWS Provider

Terraform was configured to use the AWS provider in the `us-east-1` region.

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS region was defined as a variable.

---

## 3. Existing VPC and Subnet

A new VPC was not created.

Terraform used the existing/default AWS VPC and subnet using AWS data sources.

This satisfied the requirement to use the existing/default VPC infrastructure.

---

## 4. Variables

Configurable values were defined using Terraform variables.

Examples include:

* AWS region
* EC2 instance type
* AMI ID
* Key pair name
* ECR repository name
* Application port

This made the Terraform configuration reusable and easier to maintain.

---

## 5. Amazon ECR

An Amazon ECR repository was created using Terraform.

Repository:

```text
mujtaba-task-12-twenty-crm
```

ECR repository URL:

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/mujtaba-task-12-twenty-crm
```

The ECR repository was used to store the Docker image for the application.

---

## 6. Amazon EC2

Terraform provisioned an EC2 instance using the configured AMI, instance type, key pair, security group and IAM instance profile.

The EC2 instance was configured to allow the application to be accessed through port `2020`.

The Terraform-created instance was successfully verified.

---

## 7. EC2 User Data

EC2 User Data was configured in Terraform to automate the initial server setup.

The User Data process was designed to:

1. Update the system.
2. Install Docker and required dependencies.
3. Start and enable Docker.
4. Authenticate with Amazon ECR.
5. Attempt to pull the application image from ECR.
6. Retry the image pull if the image was not yet available.
7. Start the application after the image became available.

This was required because the EC2 instance could be created before the Docker image was pushed to ECR.

---

## 8. Terraform Commands

The following Terraform commands were executed successfully.

### Terraform Initialization

```bash
terraform init
```

This initialized the Terraform working directory and downloaded the required providers.

### Terraform Validation

```bash
terraform validate
```

The Terraform configuration was validated successfully.

### Terraform Plan

```bash
terraform plan
```

The execution plan was reviewed before creating the infrastructure.

### Terraform Apply

```bash
terraform apply
```

Terraform successfully created the required AWS resources.

Result:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## 9. Docker Image Build

The Twenty CRM Docker image was built locally.

```bash
docker build -t mujtaba-task-12-twenty-crm .
```

The Docker build completed successfully.

The image was built using the project's Dockerfile and the application build completed successfully.

---

## 10. ECR Authentication

AWS account identity was verified using:

```bash
aws sts get-caller-identity --query Account --output text
```

The ECR registry was then authenticated:

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
579138738751.dkr.ecr.us-east-1.amazonaws.com
```

The authentication was successful.

---

## 11. Docker Image Tagging

The locally built image was tagged using the ECR repository URL created by Terraform.

```bash
docker tag mujtaba-task-12-twenty-crm:latest \
579138738751.dkr.ecr.us-east-1.amazonaws.com/mujtaba-task-12-twenty-crm:latest
```

---

## 12. Push Docker Image to ECR

The Docker image was pushed to Amazon ECR.

```bash
docker push \
579138738751.dkr.ecr.us-east-1.amazonaws.com/mujtaba-task-12-twenty-crm:latest
```

The image was successfully uploaded to ECR.

Image digest:

```text
sha256:9689f8b6debf844d28d6a2a6c60d18feb8d40be9935fff4fef9dc65f3bc3b625
```

---

## 13. EC2 Deployment

After the Docker image was available in ECR, the EC2 instance was connected through SSH.

The EC2 instance was authenticated with Amazon ECR using:

```bash
aws ecr get-login-password --region us-east-1 | \
sudo docker login --username AWS --password-stdin \
579138738751.dkr.ecr.us-east-1.amazonaws.com
```

The Docker Compose configuration was updated to use the ECR image for the application service.

The stack was started using:

```bash
sudo docker compose up -d
```

---

## 14. Docker Compose Configuration

The deployment used the following services:

```text
twenty-app
twenty-crm
twenty-postgres
twenty-redis
```

The application service used the ECR image:

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/mujtaba-task-12-twenty-crm:latest
```

The Twenty CRM server was exposed through:

```text
EC2 Port 2020 → Container Port 3000
```

PostgreSQL and Redis were connected internally through the Docker network.

---

## 15. Deployment Verification

The running containers were verified using:

```bash
sudo docker compose ps
```

The following services were running:

```text
twenty-app        Up
twenty-crm        Up
twenty-postgres   Up (healthy)
twenty-redis      Up (healthy)
```

The Twenty CRM container was exposed through:

```text
0.0.0.0:2020->3000/tcp
```

---

## 16. Application Health Check

The application was tested from inside the EC2 instance using:

```bash
curl -I http://localhost:2020
```

The application returned:

```text
HTTP/1.1 200 OK
```

This confirmed that the Twenty CRM application was running successfully.

The application was also accessible through the EC2 public IP:

```text
http://98.86.172.227:2020
```

---

## 17. Issues Encountered and Fixes

### Issue 1: EC2 started before the ECR image was available

Initially, the EC2 instance was created before the Docker image was pushed to ECR.

The container was therefore not running successfully.

**Resolution:** The Docker image was built locally and pushed to the Terraform-created ECR repository. The EC2 instance was then able to pull the image.

### Issue 2: Standalone ECR container could not start Twenty CLI

The initial container logs showed:

```text
Cannot reach Twenty server.
```

The custom Docker image was running:

```text
yarn twenty dev
```

which expected a Twenty server to already be running.

**Resolution:** The complete Docker Compose stack was deployed with the official Twenty CRM server, PostgreSQL, Redis and the ECR-based application container.

### Issue 3: Docker Compose was unavailable on EC2

Initially, the EC2 instance did not have the Docker Compose plugin configured correctly.

The Docker Compose plugin was installed manually and verified using:

```bash
docker compose version
```

After that, the Docker Compose stack was started successfully.

---

## 18. Resources Created

The Terraform deployment created the required AWS infrastructure for the task:

* Amazon ECR repository
* Amazon EC2 instance
* Supporting IAM/security configuration required for the EC2 deployment

The existing/default VPC and subnet were reused instead of creating a new VPC.

---

## 19. Cleanup

After verification, Terraform cleanup will be performed using:

```bash
terraform destroy
```

The AWS console and Terraform state will then be checked to verify that the resources created for this task have been removed successfully.

---

## 20. Git Branch and Pull Request

A dedicated branch will be created for Task 12:

```bash
git checkout -b Mujtaba-Task-12
```

The Terraform files and task documentation will be committed and pushed to the branch.

A Pull Request will then be raised against the `devops-crm-project` repository.

---

## 21. Loom Video

A Loom video will be recorded explaining:

1. Task objective
2. Terraform project structure
3. AWS provider configuration
4. Variables
5. Existing VPC and subnet
6. ECR configuration
7. EC2 configuration
8. User Data
9. Terraform commands
10. Docker image build
11. ECR tagging and push
12. EC2 deployment
13. Verification
14. Cleanup

The face will remain visible throughout the Loom video as required.

---

## Conclusion

Task 12 successfully demonstrated provisioning AWS infrastructure using Terraform, creating an Amazon ECR repository, building and pushing the Docker image to ECR, deploying the application on EC2, and verifying that Twenty CRM was successfully running on port `2020`.

