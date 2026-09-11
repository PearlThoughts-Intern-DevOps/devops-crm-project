# Task 13: Twenty CRM + AWS S3 using Terraform

## Objective

Deploy Twenty CRM on AWS EC2 and configure Amazon S3 as the storage backend using Terraform.

All AWS infrastructure is provisioned through Terraform. No resources are manually created through the AWS Console.

## Architecture

```text
AWS
├── Existing Default VPC
│   └── Existing Default Subnet
│       └── EC2 (t3.small)
│           ├── Docker
│           ├── Twenty CRM
│           ├── PostgreSQL
│           ├── Redis
│           └── Existing EC2S3AccessRole
│
└── S3 Bucket
    ├── Block Public Access
    ├── Versioning Enabled
    └── Server-Side Encryption


Terraform Structure
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── .terraform.lock.hcl
AWS Configuration
Region: us-east-1
VPC: Existing/default VPC
Subnet: Existing/default subnet
EC2 Instance Type: t3.small
AMI: ami-081b0a6eac00b4f53
IAM Role: Existing EC2S3AccessRole
S3: Terraform-created bucket
Twenty CRM Port: 2020
S3 Configuration

The S3 bucket is provisioned using Terraform.

The following security settings are enabled:

Block all public access
Bucket versioning
Server-side encryption using AES256
Project-specific tags
force_destroy enabled so the test bucket can be removed during Terraform destroy

The S3 bucket name is generated using the project name and AWS account ID.

EC2 Configuration

Terraform provisions one EC2 instance using:

Instance type: t3.small
Approved AMI
Existing/default VPC
Existing/default subnet
Existing IAM instance profile associated with EC2S3AccessRole
Encrypted 20 GB gp3 root volume

The EC2 security group allows:

TCP 22 for SSH
TCP 2020 for Twenty CRM
Twenty CRM Deployment

EC2 User Data installs the required dependencies and starts Twenty CRM using Docker.

The setup includes:

Docker
AWS CLI
PostgreSQL
Redis
Twenty CRM

Twenty CRM is configured with:

STORAGE_TYPE=S_3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=<Terraform-created S3 bucket>

No AWS access keys or secret keys are stored in the Terraform configuration.

The EC2 instance uses the existing IAM role to access S3.

Terraform Commands

Initialize Terraform:

cd terraform
terraform init

Expected:

Terraform has been successfully initialized!

Format Terraform files:

terraform fmt

Expected:

main.tf
outputs.tf
variables.tf
versions.tf

Validate configuration:

terraform validate

Expected:

Success! The configuration is valid.

Create execution plan:

terraform plan

Expected:

Plan: <number> to add, 0 to change, 0 to destroy.

Apply infrastructure:

terraform apply

Enter:

yes

Expected:

Apply complete!
Verification

Check Terraform-managed resources:

terraform state list

Expected resources include:

aws_instance.twenty_crm
aws_s3_bucket.twenty_crm
aws_s3_bucket_public_access_block.twenty_crm
aws_s3_bucket_server_side_encryption_configuration.twenty_crm
aws_s3_bucket_versioning.twenty_crm
aws_security_group.twenty_crm

No IAM role, IAM user, or IAM policy is created by this Terraform project.

S3 Verification

Check bucket:

aws s3api head-bucket \
  --bucket <BUCKET_NAME> \
  --region us-east-1

Check versioning:

aws s3api get-bucket-versioning \
  --bucket <BUCKET_NAME> \
  --region us-east-1

Expected:

{
    "Status": "Enabled"
}

Check public access block:

aws s3api get-public-access-block \
  --bucket <BUCKET_NAME> \
  --region us-east-1

Expected:

{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}

Check encryption:

aws s3api get-bucket-encryption \
  --bucket <BUCKET_NAME> \
  --region us-east-1

Expected:

AES256
EC2 Verification

Connect to the EC2 instance:

ssh -i ~/.ssh/karthikeyan-key.pem ec2-user@<EC2_PUBLIC_IP>

Verify IAM identity:

aws sts get-caller-identity

Expected:

arn:aws:sts::<ACCOUNT_ID>:assumed-role/EC2S3AccessRole/<INSTANCE_ID>

Test S3 access from EC2:

echo "Task 13 S3 test" > /tmp/task13-test.txt

aws s3 cp \
  /tmp/task13-test.txt \
  s3://<BUCKET_NAME>/task13-test.txt \
  --region us-east-1

Expected:

upload: ./task13-test.txt to s3://<BUCKET_NAME>/task13-test.txt

Verify:
aws s3 ls s3://<BUCKET_NAME>/ \
  --region us-east-1

Docker Verification
docker ps


Expected:


twenty-crm

postgres
redis


Check Twenty CRM storage configuration:


docker inspect twenty-crm \

  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -E 'STORAGE_TYPE|STORAGE_S3_REGION|STORAGE_S3_NAME'


Expected:


STORAGE_TYPE=S_3
STORAGE_S3_REGION=us-east-1

STORAGE_S3_NAME=<BUCKET_NAME>


Check Twenty CRM:


curl -I http://localhost:2020


Expected:


HTTP/1.1 200 OK
Cleanup


