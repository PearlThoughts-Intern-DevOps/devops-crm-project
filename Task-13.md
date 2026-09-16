# Task 13: Twenty CRM + AWS S3 using Terraform

## Objective

Deploy Twenty CRM on AWS EC2 using Docker and configure Amazon S3 as the storage backend. All required AWS infrastructure is provisioned using Terraform.

## Infrastructure

* AWS Region: `us-east-1`
* VPC: Existing/default VPC
* Subnet: Existing/default subnet
* EC2 Instance Type: `t3.small`
* AMI: Approved AWS AMI
* IAM Role: `EC2S3AccessRole`
* Storage: Amazon S3
* Container Platform: Docker / Docker Compose
* Application: Twenty CRM

## Terraform Resources

Terraform was used to provision the required infrastructure:

* EC2 instance
* Amazon S3 bucket
* IAM instance profile attachment using the provided `EC2S3AccessRole`

No new IAM users, roles, or policies were created.

No new VPC was created.

## S3 Configuration

The Terraform-created S3 bucket was configured with:

* Block Public Access enabled
* Versioning enabled
* Server-side encryption enabled
* Appropriate resource tags

Twenty CRM was configured to use the Terraform-created S3 bucket as its storage backend.

The container environment was verified using:

```bash
sudo docker inspect twenty-crm --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -iE 'STORAGE|S3'
```

Verified configuration:

```text
STORAGE_TYPE=s3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6
```

## Docker Deployment

Twenty CRM was deployed using Docker Compose with the following services:

* Twenty CRM
* PostgreSQL
* Redis

Container status was verified using:

```bash
sudo docker compose ps
```

The Twenty CRM application was exposed on port `2020`.

Application availability was verified using:

```bash
curl -I http://localhost:2020
```

The application returned:

```text
HTTP/1.1 200 OK
```

## AWS S3 Verification

The EC2 instance uses the provided `EC2S3AccessRole` to access the S3 bucket.

Bucket access was verified using:

```bash
aws s3api head-bucket --bucket mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6
```

The command successfully returned the bucket ARN and region.

The bucket contents were verified using:

```bash
aws s3 ls s3://mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6/
```

An S3 write test was performed:

```bash
echo "Task 13 S3 upload test" > /tmp/s3-test.txt

aws s3 cp /tmp/s3-test.txt \
s3://mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6/
```

The uploaded object was verified with:

```bash
aws s3 ls s3://mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6/
```

The test object was then removed:

```bash
aws s3 rm \
s3://mujtaba-task-13-twenty-crm-bf896262d2fb4a5a95ffd837e6/s3-test.txt
```

This confirmed S3 write and delete access from the EC2 instance.

## Terraform Validation

The Terraform configuration was validated and applied using:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

The infrastructure was tested using AWS CLI and EC2 commands.

After completion of testing, the infrastructure will be removed using:

```bash
terraform destroy
```

This will ensure that Terraform-created resources, including the S3 bucket, are removed as required.

## Verification Summary

The following were successfully verified:

* Terraform infrastructure provisioning
* Existing/default VPC and subnet usage
* Approved EC2 configuration
* `t3.small` EC2 instance
* Provided `EC2S3AccessRole`
* Terraform-created S3 bucket
* S3 access from EC2
* S3 upload and delete operations
* Twenty CRM Docker deployment
* PostgreSQL and Redis services
* Twenty CRM HTTP response
* Twenty CRM S3 storage configuration

## Branch and Pull Request

Task branch:

```text
Mujtaba-Task-13-PT
```

The Terraform configuration and Task 13 documentation will be committed to the task branch and submitted through a pull request to `devops-crm-project`.

