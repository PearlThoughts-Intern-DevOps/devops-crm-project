# Task 13: Twenty CRM + AWS S3 using Terraform

## Objective

Deploy Twenty CRM on an AWS EC2 instance and configure Amazon S3 as the storage backend, with the infrastructure provisioned and managed using Terraform.

The deployment uses the existing/default VPC and subnet in the `us-east-1` region and attaches the provided `EC2S3AccessRole` IAM instance profile to the EC2 instance for S3 access.

---

## Requirements

* AWS Region: `us-east-1`
* Existing/default VPC and subnet
* EC2 instance type: `t3.small`
* Approved AMI: `ami-081b0a6eac00b4f53`
* One Terraform-managed S3 bucket
* S3 Block Public Access enabled
* S3 Versioning enabled
* S3 Server-Side Encryption enabled
* Provided IAM instance profile: `EC2S3AccessRole`
* Twenty CRM deployed using Docker
* S3 configured as the Twenty CRM storage backend
* Terraform variables and outputs used where appropriate
* Infrastructure verified using Terraform, AWS CLI, and EC2 commands
* Infrastructure destroyed after testing

---

## Architecture

```text
                    AWS
                     |
             Existing VPC
                     |
              Existing Subnet
                     |
              EC2 t3.small
                     |
              Docker Container
                     |
               Twenty CRM
                     |
             S3 Storage Backend
                     |
             Terraform S3 Bucket
          abhi-s3-task-13
```

The EC2 instance uses the provided `EC2S3AccessRole` instance profile to access the Terraform-created S3 bucket without creating any additional IAM users, roles, or policies.

---

## Terraform Resources

Terraform was used to provision the required infrastructure.

### EC2

The EC2 instance was configured with:

* Instance type: `t3.small`
* Approved AMI: `ami-081b0a6eac00b4f53`
* Existing/default VPC
* Existing public subnet
* Existing security group
* IAM instance profile: `EC2S3AccessRole`
* Port `3000` exposed for Twenty CRM
* Appropriate Terraform tags

### S3

The S3 bucket was created with:

* Bucket name: `abhi-s3-task-13`
* Block Public Access enabled
* Versioning enabled
* Server-side encryption using AES256
* Appropriate project and environment tags
* `force_destroy = true` so the bucket could be removed during Terraform cleanup

---

## Twenty CRM Deployment

Twenty CRM was deployed automatically through EC2 user data.

The user-data script performed the following:

1. Updated the Amazon Linux packages.
2. Installed Docker and AWS CLI.
3. Started and enabled Docker.
4. Verified access to the EC2 IAM role credentials.
5. Tested access to the Terraform-created S3 bucket.
6. Pulled the Twenty CRM Docker image.
7. Started the Twenty CRM container.
8. Exposed Twenty CRM on port `3000`.
9. Configured S3 as the storage backend.

Twenty CRM was deployed using:

```text
twentycrm/twenty:v2.35.0
```

The container was configured with S3 storage settings for the `us-east-1` region and the Terraform-created bucket.

---

## Terraform Configuration

The Terraform configuration used AWS data sources to reference existing AWS networking resources rather than creating a new VPC.

Examples of the resources/data sources used include:

```text
data.aws_vpc.default
data.aws_subnet.public
data.aws_security_group.twenty_crm
data.aws_iam_instance_profile.ec2_s3

aws_instance.twenty_crm
aws_s3_bucket.twenty_crm
aws_s3_bucket_public_access_block.twenty_crm
aws_s3_bucket_versioning.twenty_crm
aws_s3_bucket_server_side_encryption_configuration.twenty_crm
```

Variables and outputs were used to keep the configuration reusable and to expose important deployment information such as the EC2 public IP, public DNS, S3 bucket name, and Twenty CRM URL.

---

## Terraform Validation

The required Terraform workflow was followed.

### Initialize Terraform

```bash
terraform init
```

Terraform was successfully initialized with the required AWS provider.

### Validate Configuration

```bash
terraform validate
```

The Terraform configuration was validated successfully.

### Plan Infrastructure

```bash
terraform plan
```

The plan was reviewed before deployment.

### Apply Infrastructure

```bash
terraform apply
```

The required AWS infrastructure was provisioned through Terraform.

---

## Deployment Verification

After deployment, the EC2 instance was accessed and the running Docker containers were verified.

### Docker Containers

```bash
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

The Twenty CRM container was running on port `3000`.

The deployment also included the required database and Redis containers:

```text
twenty-crm
twenty-redis
twenty-db
```

Twenty CRM was accessible through:

```text
http://<EC2-PUBLIC-IP>:3000
```

---

## Container Network Verification

Connectivity between the Twenty CRM container and its dependencies was verified.

### Database

```bash
sudo docker exec twenty-crm getent hosts twenty-db
sudo docker exec twenty-crm sh -c 'nc -zv twenty-db 5432'
```

The database hostname resolved correctly and port `5432` was open.

### Redis

```bash
sudo docker exec twenty-crm getent hosts twenty-redis
sudo docker exec twenty-crm sh -c 'nc -zv twenty-redis 6379'
```

The Redis hostname resolved correctly and port `6379` was open.

---

## S3 Configuration Verification

The Twenty CRM container environment was checked to verify that S3 storage was configured.

```bash
sudo docker exec twenty-crm env | grep AWS
```

The container reported the configured S3 region and bucket.

```text
AWS_S3_REGION=us-east-1
AWS_S3_BUCKET_NAME=abhi-s3-task-13
```

The storage type was also verified:

```bash
sudo docker exec twenty-crm env | grep STORAGE
```

Output:

```text
STORAGE_TYPE=s3
```

This confirmed that Twenty CRM was configured to use S3 storage.

---

## AWS CLI Verification

AWS CLI was used from the EC2 instance to verify access to the S3 bucket.

### Check AWS CLI

```bash
aws --version
```

AWS CLI was available on the EC2 instance.

### Check S3 Bucket

```bash
aws s3 ls s3://abhi-s3-task-13 --region us-east-1
```

The bucket was accessible using the EC2 instance's IAM role.

### S3 Upload Test

A test file was created:

```bash
echo "Task 13 S3 test" > /tmp/task13-test.txt
```

The file was uploaded:

```bash
aws s3 cp /tmp/task13-test.txt \
s3://abhi-s3-task-13/task13-test.txt \
--region us-east-1
```

The uploaded object was verified:

```bash
aws s3 ls s3://abhi-s3-task-13/ --region us-east-1
```

The object appeared successfully in the bucket.

### S3 Cleanup Test Object

The test object was removed:

```bash
aws s3 rm \
s3://abhi-s3-task-13/task13-test.txt \
--region us-east-1
```

The bucket was then checked again and was empty.

---

## IAM Access

The EC2 instance used the provided IAM instance profile:

```text
EC2S3AccessRole
```

No additional IAM users, roles, or policies were created as part of this task.

The successful AWS CLI S3 upload and listing confirmed that the EC2 instance had the required S3 access.

---

## Terraform Outputs

The deployment exposed useful outputs including:

```text
ec2_instance_id
ec2_public_dns
ec2_public_ip
iam_instance_profile
s3_bucket_arn
s3_bucket_name
subnet_id
twenty_crm_url
vpc_id
```

During deployment, the Twenty CRM endpoint was exposed using the EC2 public IP on port `3000`.

---

## Cleanup

After completing the deployment and verification, all Terraform-managed resources were destroyed.

A destroy plan was first reviewed:

```bash
terraform plan -destroy
```

The plan showed:

```text
Plan: 0 to add, 0 to change, 5 to destroy.
```

The infrastructure was then destroyed:

```bash
terraform destroy
```

Terraform successfully removed all five managed resources:

```text
Destroy complete! Resources: 5 destroyed.
```

The S3 bucket was also removed as part of the Terraform destroy operation.

Finally, Terraform state was checked:

```bash
terraform state list
```

No resources were returned, confirming that the Terraform state was empty and all Terraform-managed resources had been removed.

---

## Final Verification

The following requirements were successfully completed:

* Terraform configured for `us-east-1`
* Existing/default VPC and subnet used
* Approved `t3.small` EC2 instance deployed
* Approved AMI used
* Terraform-managed S3 bucket created
* S3 Block Public Access enabled
* S3 Versioning enabled
* S3 Server-Side Encryption enabled
* `EC2S3AccessRole` attached to EC2
* No additional IAM users, roles, or policies created
* Twenty CRM deployed using Docker
* Twenty CRM configured to use S3 storage
* EC2, Docker, database, and Redis connectivity verified
* S3 access verified using AWS CLI
* Terraform validation and deployment workflow completed
* All Terraform-managed resources destroyed after testing

## Conclusion

Task 13 was successfully completed by deploying Twenty CRM on an AWS EC2 instance and configuring Amazon S3 as its storage backend using Terraform.

The deployment was validated through Terraform, AWS CLI, Docker, and EC2 commands. After successful testing, Terraform destroy was executed and all five Terraform-managed resources, including the S3 bucket, were successfully removed.

