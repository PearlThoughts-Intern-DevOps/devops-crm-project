# Task 14: Terraform Modules

## 1. Objective

The objective of Task 14 is to refactor the existing Terraform configuration into reusable and properly structured Terraform modules.

The Terraform configuration is divided into three reusable modules:

- EC2
- ECR
- S3

The root Terraform configuration is responsible for calling these modules and passing the required values through variables.

As required by the task, the infrastructure was validated using Terraform commands, but `terraform apply` was not executed.

---

## 2. Task Requirements

The task requires:

1. Create reusable modules for EC2, ECR, and S3.
2. Use `variables.tf` and `outputs.tf`.
3. Call the modules from the root Terraform configuration.
4. Use `terraform.tfvars` for configuration values.
5. Keep the configuration reusable and properly structured.
6. Run:
   - `terraform init`
   - `terraform fmt`
   - `terraform validate`
   - `terraform plan`
7. Do not run `terraform apply`.
8. Create a branch using the required naming format.
9. Add the files to the branch.
10. Raise a pull request in `devops-crm-project`.
11. Include a Loom video explaining the Terraform configuration with the face visible throughout.

---

## 3. Project Structure

The Task 14 Terraform configuration follows this structure:

```text
task14/
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── terraform.tfvars
    ├── .gitignore
    ├── .terraform.lock.hcl
    │
    └── modules/
        ├── ec2/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        │
        ├── ecr/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        │
        └── s3/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
This structure separates infrastructure components into reusable modules and keeps the root Terraform configuration clean.


4. EC2 Module
The EC2 module is located at:
modules/ec2/
It contains:
main.tf
variables.tf
outputs.tf
EC2 Module Responsibilities
The EC2 module manages:
- EC2 instance
- Security Group
- Existing subnet selection
- EC2 instance configuration
- IAM instance profile attachment
- Root EBS volume
- IMDSv2 configuration
- Twenty CRM Docker deployment configuration

EC2 Instance
The module accepts the EC2 configuration through variables instead of hard-coding values.

Important inputs include:
- AWS region
- Project name
- Environment
- VPC ID
- Subnet ID
- AMI ID
- Instance type
- Key pair
- SSH CIDR
- Backend port
- Root volume size
- IAM instance profile
- S3 bucket name

The instance is configured using:
Instance type: t3.small
AMI: ami-0b6d9d3d33ba97d99
The existing/default VPC and subnet are used instead of creating a new VPC.

Security Group
The EC2 module creates a security group with:
- SSH access restricted to the configured SSH CIDR.
- Twenty CRM backend access on port 2020.
- Outbound traffic allowed.

IAM Instance Profile
The existing IAM instance profile:
EC2S3AccessRole
is passed into the EC2 module.
No IAM user, role, or policy is created by this Terraform configuration.

IMDSv2
The EC2 instance metadata configuration requires IMDSv2:
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}

Twenty CRM
The EC2 user data installs Docker and Docker Compose and creates a Docker Compose configuration for Twenty CRM.
The configuration includes:
- Twenty CRM server
- PostgreSQL
- Redis
The Twenty CRM server is configured to use the S3 bucket provided by the S3 module.
The S3 bucket name is passed from the root module:
s3_bucket_name = module.s3.bucket_name
This demonstrates module-to-module data flow through the root module.


5. ECR Module
The ECR module is located at:
modules/ecr/
It contains:
main.tf
variables.tf
outputs.tf
ECR Module Responsibilities
The module creates a reusable Amazon ECR repository configuration.
The repository uses:
Image tag mutability: MUTABLE
Image scanning: Enabled on push
Encryption: AES256
The repository name is provided through a variable:
repository_name = var.ecr_repository_name
ECR Outputs
The module exposes:
- Repository name
- Repository URL
- Repository ARN
These outputs can be consumed by the root Terraform configuration or other infrastructure components.


6. S3 Module
The S3 module is located at:
modules/s3/
It contains:
main.tf
variables.tf
outputs.tf
S3 Module Responsibilities
The S3 module manages the storage bucket used by the application.
The bucket name is generated using the project name and environment:
twenty-crm-dev-storage
S3 Versioning
Versioning is enabled using:
resource "aws_s3_bucket_versioning"
with:
status = "Enabled"
Server-Side Encryption
Server-side encryption is enabled using AES256:
sse_algorithm = "AES256"
Block Public Access
All four Block Public Access settings are enabled:
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
S3 Outputs
The S3 module exposes:
- Bucket name
- Bucket ARN
The bucket name is consumed by the EC2 module so that Twenty CRM can use the Terraform-created bucket as its storage backend.


7. Root Terraform Configuration
The root configuration is located in:
task14/terraform/
The root main.tf calls the three reusable modules:
module "s3" {
  source = "./modules/s3"
  ...
}

module "ecr" {
  source = "./modules/ecr"
  ...
}

module "ec2" {
  source = "./modules/ec2"
  ...
}
The root configuration also uses data sources to reference the existing/default AWS VPC and subnet.
data "aws_vpc" "default" {
  default = true
}
The subnet is selected from the default VPC rather than creating a new networking infrastructure.


8. Module Dependency Flow
The modules are connected through the root configuration.
The flow is:
                    Root Terraform
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
       S3 Module      ECR Module     EC2 Module
          |                             ^
          |                             |
          +---- bucket_name ------------+
The S3 module creates the bucket and exposes its name:
module.s3.bucket_name
The root configuration passes that value to the EC2 module:
s3_bucket_name = module.s3.bucket_name
This allows the EC2/Twenty CRM configuration to use the S3 bucket without directly referencing an S3 resource inside the EC2 module.
This keeps the modules independent and reusable.


9. Variables
The root variables.tf defines the configurable values required by the infrastructure.
Examples include:
aws_region
project_name
environment
instance_type
ami_id
key_name
allowed_ssh_cidr
backend_port
root_volume_size
iam_instance_profile
ecr_repository_name
The modules also have their own variables.tf files.
This allows the same modules to be reused with different project names, environments, AWS resources, and configuration values.


10. terraform.tfvars
The actual configuration values are stored in:
terraform.tfvars
The main values used for this task include:
AWS region: us-east-1
Project: twenty-crm
Environment: dev
EC2 type: t3.small
AMI: ami-0b6d9d3d33ba97d99
Backend port: 2020
IAM instance profile: EC2S3AccessRole
ECR repository: twenty-crm
The Terraform configuration reads these values through the root variables and passes them to the required modules.


11. Terraform Provider Configuration
The AWS provider is configured in:
versions.tf
The AWS region is supplied through the variable:
provider "aws" {
  region = var.aws_region
}
The configuration uses the HashiCorp AWS provider.


12. Terraform Outputs
The root outputs.tf exposes useful infrastructure information from the modules.
The outputs include:
- Default VPC ID
- Selected subnet ID
- EC2 instance ID
- EC2 public IP
- EC2 public DNS
- Security group ID
- ECR repository name
- ECR repository URL
- S3 bucket name
- S3 bucket ARN
The root outputs consume the module outputs using references such as:
module.ec2.instance_id
module.ecr.repository_url
module.s3.bucket_name
This demonstrates the use of Terraform module outputs.


13. Terraform Validation
The following Terraform commands were executed as required.
Terraform Init
terraform init
Terraform successfully initialized the configuration and detected all three modules:
- ec2 in modules/ec2
- ecr in modules/ecr
- s3 in modules/s3
The AWS provider was also initialized successfully.
Terraform Format
terraform fmt -recursive
The Terraform configuration and module files were formatted recursively.
Terraform Validate
terraform validate

Result:
Success! The configuration is valid.
Terraform Plan
terraform plan
Result:
Plan: 7 to add, 0 to change, 0 to destroy.
The plan also confirmed the expected existing VPC and subnet values.


14. Terraform Apply
As explicitly required by Task 14:
terraform apply was NOT executed.
Only the required Terraform initialization, formatting, validation, and planning commands were executed.
The purpose of the plan was to verify that the refactored modular configuration could be evaluated successfully without provisioning resources.


15. Git Branch
The required branch naming format was followed.
Branch:
bkkrish007-task14
All Task 14 Terraform files were added to this branch.


16. Pull Request
The Task 14 changes are intended to be submitted through a pull request to:
devops-crm-project
Base branch:
main
Feature branch:
bkkrish007-task14


17. Loom Video
A Loom video will be included as required by the task.
The video will explain:
1. Task 14 objective.
2. Terraform project structure.
3. EC2 module.
4. ECR module.
5. S3 module.
6. Root main.tf.
7. How variables are passed to modules.
8. How module outputs are used.
9. S3 bucket name flow from S3 module to EC2 module.
10. Terraform validation commands.
11. Terraform plan result.
12. Confirmation that terraform apply was not executed.
The face must remain visible throughout the Loom video as required.


18. Final Status
Task 14 Terraform implementation and verification are completed.
EC2 Module             ✅
ECR Module             ✅
S3 Module              ✅
Variables              ✅
Outputs                ✅
terraform.tfvars       ✅
Root Module Calls      ✅
terraform init         ✅
terraform fmt          ✅
terraform validate     ✅
terraform plan         ✅
terraform apply        ❌ Not executed
Branch                 ✅ bkkrish007-task14
Git Commit              ✅
Git Push                ✅

Conclusion
Task 14 successfully refactors the Terraform configuration into reusable EC2, ECR, and S3 modules.
The root Terraform configuration calls the modules and passes configuration values using variables. Module outputs are used to connect the infrastructure components, including passing the S3 bucket name to the EC2 module.
The configuration was successfully initialized, formatted, validated, and planned. As required, no terraform apply operation was performed.