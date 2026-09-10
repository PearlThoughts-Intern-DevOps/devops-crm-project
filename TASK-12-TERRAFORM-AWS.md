# Task 12 – Terraform + AWS Infrastructure

## Overview
Terraform was used to provision AWS infrastructure for the Twenty CRM project.

- AWS Region: us-east-1
- Existing/default VPC and subnet used
- EC2 instance provisioned
- Amazon ECR repository used
- Security group configured for SSH and port 3000

## Terraform Structure
The terraform directory contains:
- data.tf
- ecr.tf
- iam.tf
- main.tf
- outputs.tf
- provider.tf
- terraform.tfvars.example
- user_data.sh
- variables.tf
- versions.tf

## Terraform Commands
terraform init
terraform fmt
terraform validate
terraform plan -var-file=terraform.tfvars.example
terraform apply -var-file=terraform.tfvars.example

Terraform validation succeeded and the infrastructure was successfully applied.

## EC2
Instance ID: i-03b24646f4f601b3c
Instance type: t3.small
OS: Amazon Linux 2023
Root volume: 20 GiB GP3
Current public IP: 18.207.184.46

The existing/default VPC and subnet were used.

## ECR
Repository: twenty-crm

Image:
579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

The ECR repository already existed and was imported into Terraform state.

## IAM
The existing EC2ECRPullRole instance profile was referenced using a Terraform data source. IAM role creation was not performed because the AWS account did not have permission to create IAM roles.

## Docker Build and Push
The application image was built locally and pushed successfully to Amazon ECR.

Commands used:

docker build -t twenty-crm:latest .

docker tag twenty-crm:latest 579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 579138738751.dkr.ecr.us-east-1.amazonaws.com

docker push 579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

## EC2 User Data
The User Data script installs Docker and AWS CLI, starts Docker, authenticates with ECR, pulls the application image, retries the pull when unavailable, and starts the container after a successful pull.

## Verification
Terraform apply completed successfully.

The EC2 instance was verified as running.

The ECR image was successfully pushed.

Port 3000 verification was attempted using:
curl -I --connect-timeout 10 http://18.207.184.46:3000

The connection timed out.

## Known Limitation
The custom application image requires the Twenty backend service and TWENTY_API_KEY.

The existing EC2 instance could not be modified after creation because the AWS identity used for this task does not have ec2:ModifyInstanceAttribute permission.

The instance was also created without an SSH key pair, and available AWS permissions did not allow SSM or EC2 console-output access.

Therefore, the Terraform infrastructure and ECR image deployment were completed, but application-level CRM verification on port 3000 could not be completed.

## Cleanup
The ECR repository existed before this task and should not be deleted during Terraform cleanup.

Remove the pre-existing ECR repository from Terraform state:

terraform state rm aws_ecr_repository.twenty_crm

Then destroy the resources created by this task:

terraform destroy -var-file=terraform.tfvars.example

Verify that the EC2 instance and security group have been removed while the pre-existing ECR repository remains.
