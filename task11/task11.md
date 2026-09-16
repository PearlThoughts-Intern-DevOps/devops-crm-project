Task 11: Terraform Preparation

Name: Barani Krishnan G  
Domain: DevOps  
Project: Twenty CRM (devops-crm-project)  
Branch: bkkrish007-task11  
AWS Region: us-east-1  
Date: 8 September 2026  

1. Task Information

| Attribute | Details |
| :--- | :--- |
| Engineer Name | Barani Krishnan G |
| Domain | DevOps |
| Task Number | 11 |
| Task Title | Terraform Preparation |
| Project | Twenty CRM (devops-crm-project) |
| Git Branch | bkkrish007-task11 |
| AWS Region | us-east-1 |
| Date | 8 September 2026 |

2. Objective

The primary objective of this task was to prepare a modular, robust, and production-ready Infrastructure as Code (IaC) configuration using HashiCorp Terraform for the Twenty CRM application on Amazon Web Services (AWS).

The preparation covered the following core areas:
- Designing declarative infrastructure components for AWS Default VPC, Subnets, EC2 Compute Instance, Security Group, and Amazon Elastic Container Registry (ECR).
- Organizing the codebase into standard Terraform modular files (main.tf, variables.tf, outputs.tf, versions.tf, terraform.tfvars.example).
- Parameterizing all environment configurations using typed variables and standard default values.
- Defining structured outputs for critical compute and network identifiers.
- Initializing the AWS provider (v5.100.0) and generating the dependency lock file (.terraform.lock.hcl).
- Executing code formatting (terraform fmt) and static syntax validation (terraform validate).
- Following task guidelines by preparing the IaC architecture without executing terraform apply during this phase.

3. Project Structure

The Terraform codebase was established inside the task11/terraform/ directory with clear separation of responsibilities:

| File Name | Purpose / Responsibility |
| :--- | :--- |
| versions.tf | Declares required Terraform version constraints and AWS provider requirements |
| variables.tf | Defines all configurable input variables with descriptions, types, and defaults |
| main.tf | Contains AWS data sources and primary resource definitions (EC2, SG, ECR) |
| outputs.tf | Defines exported output values available after resource provisioning |
| terraform.tfvars.example | Example template providing custom variable overrides for different environments |
| README.md | Project documentation detailing prerequisites, variables, and usage steps |
| .gitignore | Excludes local state files, cache directories, and sensitive credentials from Git |
| .terraform.lock.hcl | Locks exact provider plugin versions and dependency checksums |

Directory Layout:

```text
task11/terraform/
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
├── outputs.tf
├── README.md
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

4. AWS Provider & Version Constraints

The required Terraform engine version and provider requirements are configured in versions.tf:

| Configuration | Value / Constraint | Details |
| :--- | :--- | :--- |
| Terraform Core | >= 1.5.0 | Ensures compatibility with modern Terraform features |
| Provider Name | aws | Official HashiCorp AWS Provider |
| Provider Source | hashicorp/aws | Fetched from the official Terraform Registry |
| Provider Version | ~> 5.0 | Automatically resolved to version 5.100.0 during init |
| AWS Region | var.aws_region | Configurable variable dynamically defaulting to us-east-1 |

Configuration Block:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

5. VPC and Subnet Configuration (Data Sources)

To optimize cost and avoid unnecessary duplicate networking infrastructure, existing default AWS VPC resources are retrieved using Terraform Data Sources:

| Data Source | Type | Lookup Criteria | Selected Attribute |
| :--- | :--- | :--- | :--- |
| data.aws_vpc.default | Default VPC | default = true | Retrieves the default VPC ID |
| data.aws_subnets.default | Subnet List | filter: vpc-id = data.aws_vpc.default.id | Lists all subnet IDs inside the default VPC |
| data.aws_subnet.selected | Single Subnet | id = data.aws_subnets.default.ids[0] | Selects the first available default subnet |

Configuration Block:

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
  id = data.aws_subnets.default.ids[0]
}
```

6. Amazon EC2 Instance Configuration

An Amazon EC2 instance is configured in main.tf to host the Twenty CRM application stack:

| Parameter | Configuration / Value | Description |
| :--- | :--- | :--- |
| Resource Name | aws_instance.twenty_crm | Terraform resource identifier |
| AMI ID | var.ami_id (ami-0c7217cdde317cfec) | Ubuntu 24.04 / 22.04 LTS for us-east-1 |
| Instance Type | var.instance_type (t3.small) | 2 vCPU, 2 GiB Memory for container workloads |
| Subnet Placement | data.aws_subnet.selected.id | First available subnet in the default VPC |
| Key Pair | var.key_name (bkkrish007-task10) | Existing SSH key pair for secure remote access |
| Public IP | associate_public_ip_address = true | Assigns an automatic public IPv4 address |
| Security Group | aws_security_group.twenty_crm.id | Custom firewall attached to the network interface |
| Storage Type | gp3 | Next-Generation General Purpose SSD |
| Volume Size | var.root_volume_size (20 GiB) | Storage allocated for OS, Docker, and logs |
| Termination Policy | delete_on_termination = true | Automatic cleanup of EBS volume on instance termination |

Configuration Block:

```hcl
resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Project     = var.project_name
    Environment = var.environment
  }
}
```

7. Security Group Configuration

A dedicated AWS Security Group is defined in main.tf to control inbound and outbound traffic:

| Rule Type | Port / Range | Protocol | Source / Destination | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| Ingress | 22 | TCP | var.allowed_ssh_cidr (0.0.0.0/0) | Secure SSH remote administration |
| Ingress | var.application_port (2020) | TCP | 0.0.0.0/0 | Twenty CRM web application access |
| Egress | All Ports (0) | All (-1) | 0.0.0.0/0 | Unrestricted outbound internet connectivity |

Configuration Block:

```hcl
resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM application access"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}
```

8. Amazon Elastic Container Registry (ECR)

An Amazon ECR private repository is defined in main.tf to store custom Twenty CRM Docker images:

| Feature / Setting | Configuration | Details |
| :--- | :--- | :--- |
| Repository Name | var.ecr_repository_name (twenty-crm) | Target ECR registry repository name |
| Tag Mutability | MUTABLE | Allows updating tags like latest during CI/CD builds |
| Vulnerability Scanning | scan_on_push = true | Automated vulnerability scanning on image upload |
| Encryption | encryption_type = AES256 | Server-side data protection at rest |
| Tags | Project, Environment, Name | Standardized asset classification |

Configuration Block:

```hcl
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_repository_name
    Project     = var.project_name
    Environment = var.environment
  }
}
```

9. Input Variables

Input variables declared in variables.tf allow customization across environments:

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| aws_region | string | us-east-1 | AWS region where resources will be created |
| project_name | string | twenty-crm | Name of the project |
| environment | string | dev | Deployment environment identifier |
| instance_type | string | t3.small | EC2 compute instance type |
| ami_id | string | ami-0c7217cdde317cfec | Ubuntu AMI ID for us-east-1 |
| key_name | string | bkkrish007-task10 | Existing EC2 key pair name |
| allowed_ssh_cidr | string | 0.0.0.0/0 | CIDR block allowed to access SSH |
| application_port | number | 2020 | Twenty CRM application port |
| root_volume_size | number | 20 | EC2 root volume size in GiB |
| ecr_repository_name | string | twenty-crm | Amazon ECR repository name |

10. Output Values

Outputs defined in outputs.tf display critical values after Terraform execution:

| Output Name | Source Expression | Description |
| :--- | :--- | :--- |
| vpc_id | data.aws_vpc.default.id | ID of the default AWS VPC |
| subnet_id | data.aws_subnet.selected.id | Selected subnet ID used for EC2 instance |
| ec2_instance_id | aws_instance.twenty_crm.id | EC2 instance ID |
| ec2_public_ip | aws_instance.twenty_crm.public_ip | Public IP address of the EC2 instance |
| ec2_public_dns | aws_instance.twenty_crm.public_dns | Public DNS hostname of the EC2 instance |
| security_group_id | aws_security_group.twenty_crm.id | Security group ID |
| ecr_repository_url | aws_ecr_repository.twenty_crm.repository_url | Amazon ECR repository URL |

11. Terraform Commands and Verification

The following Terraform commands were executed to initialize, format, and validate the code:

| Command Executed | Purpose | Result / Status |
| :--- | :--- | :--- |
| terraform init | Initializes workspace, downloads AWS provider, creates lock file | Success (AWS provider v5.100.0 installed) |
| terraform fmt | Canonical formatting across all HCL files | Success (All .tf files formatted) |
| terraform validate | Static code analysis and syntax verification | Success (Configuration is valid) |
| terraform plan | Dry-run deployment plan | Skipped as per task guidelines |
| terraform apply | Resource provisioning | Skipped as per task guidelines |

Command Output:

Initialization:
```bash
terraform init
```
Output: Terraform has been successfully initialized.

Formatting:
```bash
terraform fmt
```
Output: All configuration files formatted to standard conventions.

Validation:
```bash
terraform validate
```
Output:
```text
Success! The configuration is valid.
```

12. Git Branch & Version Control

| Parameter | Value / Detail |
| :--- | :--- |
| Active Branch | bkkrish007-task11 |
| Naming Convention | username-tasknumber standard |
| .gitignore File | Configured to ignore .terraform/, *.tfstate, and *.tfvars |
| Status | Branch up-to-date and ready for Pull Request creation |

13. Conclusion

The Terraform configuration for Task 11 was successfully prepared and verified:
- AWS provider requirements and constraints were correctly established for the us-east-1 region.
- Default VPC and Subnet data sources were configured to dynamically reference existing networking.
- Declarative resource definitions were authored for the EC2 instance, Security Group, and Amazon ECR repository.
- Parameterization and output mappings were created with clean data typing.
- Terraform initialization and static syntax validation completed with 100% success.
- The repository structure is clean, fully documented, and ready for team review and pull request.
