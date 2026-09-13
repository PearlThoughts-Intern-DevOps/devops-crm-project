# Task 12: Terraform + AWS Infrastructure for Twenty CRM

## Overview

This task implements the AWS infrastructure required to deploy Twenty CRM using Terraform and Amazon ECR.

The configuration uses the existing/default VPC and subnet instead of creating a new VPC. Terraform manages the required EC2, ECR, IAM, and security group resources.

## Infrastructure

The following infrastructure was configured using Terraform:

- Existing/default VPC and subnet accessed through Terraform data sources
- Amazon ECR repository for the Twenty CRM Docker image
- EC2 `t3.small` instance
- IAM instance profile for ECR access
- Security group for SSH and application traffic
- Terraform outputs for important infrastructure details

The AWS provider is configured for the `us-east-1` region, and configurable values are managed through Terraform variables.

## Twenty CRM Deployment

The Twenty CRM Docker image was built locally and pushed to the Terraform-created Amazon ECR repository.

The EC2 instance uses the ECR image to run Twenty CRM. The deployment is automated through EC2 User Data, so manual application setup is not required after instance creation.

## EC2 User Data

The User Data script automatically prepares the EC2 instance and starts the application.

It performs the following:

- Creates and enables a 2 GB swap file to provide additional memory capacity for the `t3.small` instance.
- Installs and starts Docker.
- Installs the required AWS CLI dependency.
- Authenticates with Amazon ECR.
- Pulls the Twenty CRM image from ECR.
- Retries the image pull when the image is not immediately available.
- Starts the Twenty CRM container after a successful image pull.

The swap configuration is also made persistent through `/etc/fstab`.

## Verification

Terraform configuration was initialized, formatted, validated, planned, and applied successfully.

The EC2 instance was verified as running with healthy AWS system and instance status checks.

The Twenty CRM container was confirmed to be running on the EC2 instance.

Application connectivity was tested locally on the instance and through the EC2 public IP. The application returned:

```text
HTTP/1.1 200 OK
Twenty CRM was also successfully opened and verified in the browser.

The 2 GB swap configuration was verified and showed the expected available swap space.

Issue Encountered
During initial testing, SSH access to the EC2 instance experienced connection timeouts.

The security group rules, public IP address, and EC2 instance status were checked. After the instance became fully healthy and the network connection was retried, SSH access worked successfully.

Some OpenSSH debug3: obfuscate_keystroke_timing messages were also displayed during the SSH session. These were SSH debug messages and did not affect the application.

Repository Structure
terraform/
├── .gitignore
├── .terraform.lock.hcl
├── README.md
├── data.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── security.tf
├── terraform.tfvars.example
├── user_data.sh
├── variables.tf
└── versions.tf

Git
The work was completed on the branch:

ambur-task12

The Terraform configuration and documentation were committed to this branch for Pull Request submission.

The unrelated Task 8 file was not included in the Task 12 commit.

Cleanup
After successful verification, the Terraform-managed resources will be removed using terraform destroy.

The EC2 instance and ECR repository created for this task should be verified as deleted after the destroy operation completes.

Security
AWS credentials and private SSH keys are not stored in the repository.

Sensitive files such as Terraform variable files, state files, and .pem keys are excluded through .gitignore.

AWS credentials are configured locally and are never committed to Git.

Conclusion
Task 12 successfully implemented the required Terraform-based AWS infrastructure for Twenty CRM.

The Docker image was deployed through Amazon ECR, the EC2 instance was automatically configured using User Data, and Twenty CRM was successfully verified with an HTTP 200 OK response and through the browser.

The final submission includes the Terraform configuration, documentation, Git branch, Pull Request, and Loom walkthrough.
