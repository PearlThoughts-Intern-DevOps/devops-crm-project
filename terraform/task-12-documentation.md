
# Task 12: Terraform + AWS Infrastructure

## Objective

Provision the basic AWS infrastructure required for Twenty CRM using Terraform and deploy the Twenty CRM Docker image through Amazon ECR.

## Infrastructure

The following resources were provisioned:

- Existing/default AWS VPC
- Existing/default subnet
- EC2 instance
- Security Group
- Amazon ECR repository
- IAM instance profile for ECR access

A new VPC was not created because the task required using the existing/default VPC.

## Terraform Project Structure

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── .terraform.lock.hcl

Terraform state must be protected and should not be committed to Git.
AWS credentials and application secrets must never be committed to the repositoryEC2 User Data can automate application deployment.
Retry logic is useful when infrastructure and image publishing happen at different times.
Amazon ECR provides a private Docker image registry.
Terraform can provision and manage AWS infrastructure as code.
Existing AWS resources can be imported into Terraform state.
Data sources can be used to discover existing infrastructure.

Learnings

The default VPC is intentionally retained because it is an existing AWS resource and was not created by this task.

aws ecr describe-repositories \
  --repository-names twenty-crm-task12 \
  --region us-east-1
Verify the ECR repository no longer exists:
  --region us-east-1

Verify the EC2 instance no longer exists:

aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID> \
terraform destroy -auto-approve

Cleanup

After verification, Terraform resources are destroyed using:

The EC2 User Data is designed to retry ECR authentication and image pulling because the EC2 instance can start before the Docker image is pushed to ECR.

After the change, Terraform planned an in-place update instead of destroying and recreating the security group.

ECR Availability

The existing security group was imported into Terraform state:

terraform import aws_security_group.twenty_crm <security-group-id>

The Terraform configuration was then updated to match the existing security group description.


The security group already existed in the default VPC.

Terraform initially attempted to recreate it because the configured description differed from the existing security group's description.
Issues Encountered
Existing Security Group

System: ok
Terraform state and the .terraform/ directory are excluded from Git.

AWS Configuration

Region:

us-east-1

Terraform provider:

hashicorp/aws
Variables

Instance: ok

The Terraform configuration uses variables for:

AWS region
Project name
EC2 instance type
AMI ID
Application port
SSH CIDR

Default application port:

2020
Existing VPC

http://100.48.206.34:2020

EC2 status checks:
Terraform discovers and reuses the default VPC using:

data "aws_vpc" "default" {
The security group allows:

Outbound traffic: All

Repository URL:

The local Twenty CRM image is tagged and pushed to this repository.

Terraform Commands

Initialize Terraform:
Create execution plan:

terraform plan


Twenty CRM URL:


Pull the Twenty CRM image locally:

docker pull twentycrm/twenty:latest
Tag the image:

docker tag twentycrm/twenty:latest 579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12:latest


aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 579138738751.dkr.ecr.us-east-1.amazonaws.com

Push the image:
docker push 579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12:latest

twenty-crm-task12

Verify the image:

aws ecr describe-images \
  --repository-name twenty-crm-task12 \
  --region us-east-1 \
  --output table
EC2 User Data

EC2 User Data performs the following actions automatically:

Updates the operating system packages.
Installs Docker and AWS CLI.

ECR repository:
Starts the Docker service.
Authenticates with Amazon ECR.
Retries ECR authentication if required.
Pulls the Twenty CRM image from ECR.
Retries image pulling until the image becomes available.
Creates the required Docker network.
Starts PostgreSQL.
Starts Redis.
Starts the Twenty CRM container on port 2020.

This allows the EC2 instance to automatically deploy Twenty CRM after the Docker image becomes available in ECR.

Verification

Terraform apply completed successfully.

EC2 instance:

i-00aaea2da0db57cae

EC2 public IP:

100.48.206.34

Authenticate with ECR:

terraform apply -auto-approve
Docker Image Deployment

Apply infrastructure:

terraform validate

Validate configuration:


Format configuration:

terraform fmt

terraform init
579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12

Terraform creates/manages the ECR repository:

twenty-crm-task12
Amazon ECR

SSH: TCP 22
Twenty CRM: TCP 2020
  default = true
Security Group

Automatic image pull retry
Twenty CRM container startup
}
AWS CLI installation
ECR authentication

Docker installation through User Data
The default subnet associated with the VPC is also discovered dynamically.
Public IP enabled
Root volume: 20 GB gp3
Encrypted root volume

Instance type: t3.small

The Twenty CRM EC2 instance uses:

