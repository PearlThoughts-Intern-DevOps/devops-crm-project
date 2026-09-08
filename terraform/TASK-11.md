# Task 11 – Terraform Preparation

## 1. Objective

The objective of this task is to prepare Terraform configuration for the AWS infrastructure required for the Twenty CRM application.

The Terraform configuration prepares the following infrastructure:

- Existing/default AWS VPC
- EC2 instance for Twenty CRM
- Security Group
- Amazon ECR repository

The main goal is to create a clean, reusable, and maintainable Terraform project structure using variables and outputs.

This task is focused on infrastructure preparation and validation only. No infrastructure deployment is performed using `terraform apply`.

---

# 2. Terraform Project Structure

A separate `terraform` directory was created in the project repository.

```text
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── .terraform.lock.hcl

File Responsibilities
File	Description
versions.tf	Defines Terraform version requirements and AWS provider configuration
variables.tf	Defines configurable infrastructure variables
main.tf	Defines AWS data sources and infrastructure resources
outputs.tf	Defines important infrastructure outputs
.terraform.lock.hcl	Locks the selected Terraform provider version

This structure keeps the Terraform configuration organized and easy to maintain.

3. Terraform and AWS Provider Configuration

The Terraform configuration uses the HashiCorp AWS provider.

The AWS region used for this task is:

us-east-1

The provider configuration is defined in versions.tf.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

The Terraform version constraint ensures that a compatible Terraform version is used.

The AWS provider version is also constrained to the 5.x release family.

4. Variables

Configurable values are defined in variables.tf instead of directly hard-coding them inside infrastructure resources.

The variables include:

AWS region
Project name
EC2 instance type
Amazon Linux 2023 AMI ID
VPC CIDR
Subnet CIDR
Availability Zone

Example:

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "twenty-crm"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-0c101f26f147fa7fd"
}

Using variables makes the Terraform configuration easier to modify and reuse for different environments.

5. Existing Default VPC

The task requires using the existing/default AWS VPC where applicable.

Instead of creating a new VPC, Terraform retrieves the existing default VPC using a data source.

data "aws_vpc" "default" {
  default = true
}

This allows Terraform to reference the existing VPC without creating a new networking environment.

6. Existing VPC Subnets

The available subnets inside the default VPC are retrieved using the aws_subnets data source.

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

The EC2 instance uses the first available subnet returned from the default VPC.

This avoids hard-coding a subnet ID.

7. Security Group

A Security Group is created for the Twenty CRM EC2 instance.

The Security Group controls inbound and outbound network traffic.

The configuration allows:

SSH traffic on port 22
Twenty CRM application traffic on port 2020
Outbound traffic
resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
For a production environment, SSH access should be restricted to a trusted IP range instead of allowing access from 0.0.0.0/0.


8. EC2 Instance


Terraform is configured to prepare an EC2 instance for the Twenty CRM application.

The EC2 instance uses:


Amazon Linux 2023 AMI
Configurable instance type

Existing default VPC subnet
Twenty CRM Security Group
Public IP address

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]

  associate_public_ip_address = true

  tags = {

    Name = "${var.project_name}-ec2"
  }
}

The EC2 instance is tagged with the project name so that it can be easily identified in the AWS console.


9. Amazon ECR Repository

Amazon Elastic Container Registry (ECR) is configured to store Docker container images for the Twenty CRM application.

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"


  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

Image scanning is enabled using:

scan_on_push = true


This allows container images to be scanned when they are pushed to the repository.


No Docker image build or image push is performed as part of this Terraform preparation task.

10. Terraform Outputs

Important infrastructure information is defined in outputs.tf.

The outputs include:


VPC ID
EC2 instance ID
EC2 public IP
ECR repository URL

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}


output "ec2_instance_id" {
  description = "Twenty CRM EC2 instance ID"
  value       = aws_instance.twenty_crm.id

}

output "ec2_public_ip" {
  description = "Public IP of the Twenty CRM EC2 instance"

  value       = aws_instance.twenty_crm.public_ip
}


output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

These outputs make important resource information available after Terraform operations.

11. Terraform Initialization

The Terraform project was initialized using:

terraform init

Terraform initialization performs the following tasks:

Initializes the Terraform working directory
Downloads the required AWS provider
Prepares Terraform for validation and planning
Creates the provider lock file

The initialization completed successfully.

The generated provider lock file is:

.terraform.lock.hcl
12. Terraform Validation

The Terraform configuration is validated using:

terraform validate

This command checks whether the Terraform configuration is syntactically and structurally valid.

A successful validation returns:

Success! The configuration is valid.

This confirms that the Terraform configuration can be parsed and validated successfully.

13. Terraform Plan

The Terraform plan is used to preview the infrastructure changes that Terraform would make without actually creating the resources.

The command used is:

terraform plan

The expected plan contains the following Terraform-managed resources:

1. Security Group
2. EC2 Instance
3. Amazon ECR Repository

The existing default VPC and its subnets are retrieved using Terraform data sources and are not created by Terraform.

The plan operation does not deploy infrastructure.

14. Terraform Apply

terraform apply is intentionally not executed for this task.

The task requires Terraform preparation and validation only.

Therefore:

terraform apply

was not used to deploy the infrastructure.

This prevents accidental creation of AWS resources during the preparation task.

15. AWS Infrastructure Design

The Terraform configuration follows this basic infrastructure flow:

                    AWS
                     │
                     ▼
              Existing Default VPC
                     │
             ┌───────┴────────┐
             │                │
             ▼                ▼
        Existing Subnet    Security Group
             │                │
             └───────┬────────┘
                     │
                     ▼
                 EC2 Instance
                Twenty CRM
                     
                     │
                     │
                     ▼
              Amazon ECR
           Docker Image Storage

The existing default VPC is reused instead of creating a new VPC.

The EC2 instance is associated with the Security Group and an existing subnet.

The ECR repository is prepared for storing Twenty CRM Docker images.

16. Terraform Best Practices Used

The configuration follows basic Terraform best practices:

Separate Terraform Files

Provider configuration, variables, resources, and outputs are separated into different files.

Variables

Configurable values are represented using Terraform variables.

Data Sources

Existing AWS infrastructure such as the default VPC and its subnets is retrieved using Terraform data sources.

Resource Naming


Resources use the project name variable for consistent naming.


Outputs

Important resource information is exposed using Terraform outputs.


Provider Locking


.terraform.lock.hcl is maintained to lock the selected provider version.


No Credentials in Code


AWS credentials and secrets are not stored in Terraform configuration files.

No Terraform State in Git


Terraform local state and working directories should not be committed to the repository.


17. Validation Commands


The main Terraform commands used for this task are:


terraform init
terraform validate
terraform plan


The following command was intentionally not executed:


terraform apply
18. Git Branch


The Terraform work is maintained in the dedicated Task 11 branch:

karthikeyan-task11


This follows the required branch naming convention for the internship task.

19. Git Commit


The Terraform configuration is committed to the Task 11 branch.

Example commit message:


Add Terraform configuration for Twenty CRM AWS infrastructure
20. Pull Request


After committing the Terraform files, the Task 11 branch is pushed to GitHub and a Pull Request is created for review.


The Pull Request contains:


Terraform configuration
Variables
Outputs

Provider configuration
Terraform validation changes
Task documentation


The Pull Request is submitted for review and is not merged without approval.


21. Screenshots / Evidence

The following screenshots should be included as evidence for the task:

Terraform project structure
versions.tf

variables.tf
main.tf
outputs.tf
terraform init successful output
terraform validate successful output
terraform plan output
Git branch showing karthikeyan-task11
GitHub Pull Request

Screenshots provide evidence that the Terraform configuration was prepared and validated successfully.

22. Loom Video

A Loom video is recorded to demonstrate the Task 11 implementation.

The video covers:

Task objective
Terraform project structure
Provider configuration
Variables
Existing default VPC
Subnet data source
Security Group
EC2 configuration
ECR repository
Outputs
terraform init
terraform validate
terraform plan
Confirmation that terraform apply was not executed
Git branch and Pull Request

Loom Link:

https://www.loom.com/share/79984590f531412e92c8aca44286a2e6

23. Conclusion

Task 11 prepares the Terraform infrastructure configuration required for the Twenty CRM application on AWS.

The Terraform project contains:

AWS provider configuration
Existing/default VPC lookup
Existing subnet lookup
EC2 instance configuration
Security Group configuration
Amazon ECR repository configuration
Terraform variables
Terraform outputs
Provider version locking

The configuration is structured to be reusable and maintainable.

Terraform initialization and validation are performed as part of the preparation process, and the Terraform plan is used to preview the infrastructure changes.

No terraform apply operation is performed because the task is limited to Terraform preparation and validation.

The completed Terraform configuration is committed to the karthikeyan-task11 branch and submitted through a Pull Request for review.
