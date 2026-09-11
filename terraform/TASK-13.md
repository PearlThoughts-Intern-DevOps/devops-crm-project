# Task 13 – Twenty CRM + AWS S3 using Terraform

## Objective

Provision Twenty CRM infrastructure using Terraform on AWS and configure S3 storage without creating a new VPC or IAM resources.

## AWS Configuration

- Region: `us-east-1`
- VPC: Existing default VPC
- VPC ID: `vpc-0c241509159132524`
- Subnet: Existing default subnet
- Subnet ID: `subnet-078d52bfe579c74f2`
- EC2 AMI: `ami-081b0a6eac00b4f53`
- Instance type: `t3.small`
- IAM Instance Profile: `EC2S3AccessRole`
- EC2 Instance ID: `i-004f92d2226ce2618`
- EC2 Public IP: `13.223.93.141`

## S3 Configuration

Bucket:

`twenty-crm-task13-579138738751`

Security configuration:

- Block Public ACLs: Enabled
- Ignore Public ACLs: Enabled
- Block Public Policy: Enabled
- Restrict Public Buckets: Enabled
- Versioning: Enabled
- Server-side encryption: AES256

## Terraform Resources

Terraform manages:

1. EC2 security group
2. EC2 instance
3. S3 bucket
4. S3 public access block
5. S3 bucket versioning
6. S3 server-side encryption

The existing VPC, subnet and IAM instance profile are referenced through Terraform data sources.

No IAM users, roles or policies are created by this configuration.

## Twenty CRM Deployment

The EC2 user-data script:

- installs Docker and curl
- enables Docker
- installs Docker Compose
- deploys Twenty CRM using the `twentycrm/twenty:latest` image
- deploys PostgreSQL 16
- deploys Redis
- configures Twenty CRM to use the S3 bucket
- uses the EC2 IAM instance profile instead of hard-coded AWS access keys
- exposes Twenty CRM on port `3000`

## Terraform Implementation

Terraform uses variables for:

- AWS region
- approved AMI
- EC2 instance type
- instance name
- root volume size
- S3 bucket name
- container port

Terraform outputs:

- VPC ID
- subnet ID
- EC2 instance ID
- EC2 public IP
- S3 bucket name
- S3 bucket ARN

## Verification

### Terraform Validation

```text
Success! The configuration is valid.




