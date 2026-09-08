Task 11: Terraform Preparation
Objective

The objective of this task was to prepare Terraform configuration for the AWS infrastructure required for the Twenty CRM application.

The Terraform configuration includes VPC networking, EC2 infrastructure, and an Amazon ECR repository.

Terraform Project Structure
terraform/
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── README.md
├── .gitignore
└── .terraform.lock.hcl

File Description
provider.tf – Configures Terraform and the AWS provider.
variables.tf – Defines configurable Terraform variables.
main.tf – Defines the VPC, networking, security group, EC2 instance, and ECR repository.
outputs.tf – Defines outputs for important AWS resource information.
README.md – Provides documentation for the Terraform configuration.
.gitignore – Excludes Terraform state files and generated files.
.terraform.lock.hcl – Locks the selected AWS provider version.
AWS Provider

The AWS provider is configured for:

us-east-1


The AWS region is defined as a Terraform variable instead of being hardcoded in the resource configuration.

VPC and Networking

The Terraform configuration defines a VPC with:

CIDR block: 10.0.0.0/16
DNS support enabled
DNS hostnames enabled

The networking configuration also includes:

Internet Gateway
Public subnet
Public route table
Route table association
Automatic public IP assignment for the public subnet

The subnet uses the configurable CIDR block:

10.0.1.0/24


and availability zone:

us-east-1a

EC2 Instance

The Terraform configuration defines an EC2 instance for the Twenty CRM application.

The EC2 configuration includes:

Configurable AMI ID
Configurable instance type
Public subnet
Public IP association
Security group
SSH access on port 22
HTTP access on port 80

The AMI ID and instance type are managed through Terraform variables.

Security Group

A security group is configured for the EC2 instance.

The current inbound rules allow:

Port 22 – SSH
Port 80 – HTTP

Outbound traffic is allowed so that the instance can communicate with external resources.

For a production environment, SSH access should be restricted to trusted IP addresses rather than allowing access from all IP addresses.

Amazon ECR

An Amazon ECR repository is configured for the Twenty CRM application.

The repository includes:

Configurable repository name
Mutable image tags
Image scanning on push

The repository name is managed through a Terraform variable.

Variables

Configurable values are defined in variables.tf.

The variables include:

AWS region
VPC CIDR block
Subnet CIDR block
Availability zone
EC2 instance type
EC2 AMI ID
ECR repository name

Using variables makes the Terraform configuration easier to modify and reuse.

Outputs

Important resource information is defined in outputs.tf.

The outputs include:

VPC ID
Subnet ID
EC2 instance ID
EC2 public IP
ECR repository URL

These outputs provide useful information about the infrastructure after deployment.

Terraform Formatting

The configuration was formatted using:

terraform fmt


The formatting check was also completed using:

terraform fmt -check


Both completed successfully.

Terraform Initialization

Terraform was initialized using:

terraform init


Terraform successfully initialized the project and downloaded the required AWS provider.

Terraform Validation

The configuration was validated using:

terraform validate


The validation completed successfully:

Success! The configuration is valid.

Terraform Plan

terraform plan requires valid AWS credentials to communicate with AWS.

The local environment did not have valid AWS credentials configured, so the plan could not be generated.

The Terraform configuration itself successfully passed terraform validate.

Important

As required by Task 11:

terraform apply was NOT executed.


No AWS infrastructure was created using terraform apply.

This task is only for preparing and validating the Terraform configuration.

Conclusion

Task 11 successfully prepared a clean Terraform configuration for the Twenty CRM AWS infrastructure.

The configuration uses:

Terraform variables for configurable values
Terraform outputs for important resource information
AWS provider configured for us-east-1
VPC and networking resources
EC2 infrastructure
Amazon ECR repository
Terraform formatting and validation
Git-friendly project structure

Branch: ambur-task11

AWS Region: us-east-1
