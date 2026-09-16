---

## Task 13 – Twenty CRM + AWS S3 using Terraform

### Objective

Deploy Twenty CRM on AWS EC2 and configure Amazon S3 as the storage backend, with the infrastructure provisioned using Terraform.

### Terraform Structure

~~~text
terraform/
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── terraform.tfvars.example
├── .gitignore
└── .terraform.lock.hcl
~~~

### AWS Configuration

- AWS region: `us-east-1`
- Existing/default VPC used
- Existing/default subnet used
- No new VPC created
- EC2 instance type: `t3.small`
- Approved AMI used: `ami-0b6d9d3d33ba97d99`
- One Terraform-managed EC2 instance
- One Terraform-managed S3 bucket

### IAM Configuration

The provided IAM instance profile is used:

~~~text
EC2S3AccessRole
~~~

No IAM users, roles, or policies are created by Terraform.

The EC2 instance uses the provided IAM instance profile to access the Terraform-created S3 bucket.

### S3 Configuration

The Terraform-created S3 bucket includes:

- Block Public Access enabled
- Versioning enabled
- Server-side encryption enabled using AES256
- Appropriate resource tags

Example bucket:

~~~text
twenty-crm-task13-d6056c36
~~~

### Security Group

The EC2 security group allows:

- TCP `22` for SSH access from the administrator IP
- TCP `2020` for Twenty CRM web access
- Outbound internet traffic

### Terraform Commands

Initialize Terraform:

~~~bash
terraform init
~~~

Format the Terraform configuration:

~~~bash
terraform fmt
~~~

Validate the configuration:

~~~bash
terraform validate
~~~

Create an execution plan:

~~~bash
terraform plan
~~~

Apply the infrastructure:

~~~bash
terraform apply
~~~

View Terraform outputs:

~~~bash
terraform output
~~~

### Twenty CRM Deployment

The EC2 User Data script:

1. Updates the Ubuntu package index.
2. Installs required dependencies.
3. Installs and starts Docker.
4. Creates the required Docker network.
5. Starts PostgreSQL.
6. Starts Redis.
7. Pulls the Twenty CRM Docker image.
8. Starts the Twenty CRM server and worker.
9. Configures Twenty CRM to use the Terraform-created S3 bucket as the storage backend.
10. Performs an HTTP health check on the Twenty CRM service.
11. Captures container logs if the health check fails.

### S3 Storage Configuration

Twenty CRM is configured to use Amazon S3 through environment variables including:

~~~text
STORAGE_TYPE
STORAGE_S3_REGION
STORAGE_S3_NAME
STORAGE_S3_ENDPOINT
~~~

The S3 bucket name and AWS region are passed from Terraform into the EC2 User Data configuration.

### Terraform Verification

Terraform successfully completed:

~~~text
terraform init
terraform validate
terraform plan
terraform apply
~~~

The final Terraform deployment created:

~~~text
EC2 instance
S3 bucket
S3 public access block
S3 versioning configuration
S3 server-side encryption configuration
Security group
Random bucket name suffix
~~~

### S3 Verification

The S3 bucket was verified using AWS CLI.

Block Public Access:

~~~text
BlockPublicAcls: true
IgnorePublicAcls: true
BlockPublicPolicy: true
RestrictPublicBuckets: true
~~~

Versioning:

~~~text
Status: Enabled
~~~

Server-side encryption:

~~~text
SSEAlgorithm: AES256
~~~

### EC2 Verification

The EC2 instance was verified using AWS CLI.

Verified:

- EC2 instance state: `running`
- Instance type: `t3.small`
- Approved AMI used
- Provided IAM instance profile attached
- EC2 and system status checks passed

### Twenty CRM Verification

Twenty CRM was successfully verified using HTTP requests.

Health endpoint:

~~~bash
curl -I http://100.57.6.133:2020/healthz
~~~

Result:

~~~text
HTTP/1.1 200 OK
~~~

Main application endpoint:

~~~bash
curl -I http://100.57.6.133:2020
~~~

Result:

~~~text
HTTP/1.1 200 OK
~~~

### Terraform Outputs

Example outputs from the deployment:

~~~text
ec2_instance_id = i-0885a9c9c9dc9d624
ec2_public_ip = 100.57.6.133
iam_instance_profile = EC2S3AccessRole
s3_bucket_name = twenty-crm-task13-d6056c36
security_group_id = sg-0d0fb5b69a88fc462
subnet_id = subnet-078d52bfe579c74f2
vpc_id = vpc-0c241509159132524
twenty_crm_url = http://100.57.6.133:2020
~~~

### Issues Encountered

During the deployment, Terraform initially failed because the IAM user did not have the required S3 permission for `s3:GetBucketLogging`.

The required S3 permission was subsequently granted, after which Terraform completed successfully.

No manual AWS resource provisioning was performed through the AWS Console.

### Cleanup

After testing, all Terraform-managed resources must be removed using:

~~~bash
terraform destroy
~~~

The cleanup operation should remove the EC2 instance, security group, S3 bucket, and all other resources created by the Task 13 Terraform configuration.

---

