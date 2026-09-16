# DevOps CRM Project

This repository contains the DevOps implementation for deploying and managing Twenty CRM using Docker, AWS, Terraform, and Ansible.

---

## Task 12 – Terraform + AWS Infrastructure

### Objective

Provision Twenty CRM infrastructure on AWS using Terraform while using the existing/default VPC and subnet.

The infrastructure includes:

- Amazon ECR repository
- EC2 instance
- IAM role and instance profile
- Security group
- Terraform variables and outputs
- EC2 User Data for Docker installation, ECR authentication, image pulling, and application startup

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
- Root volume: `20 GiB gp3`
- ECR repository: `twenty-crm-task12`
- ECR image scanning enabled on push

### Security Group

The EC2 security group allows:

- TCP `22` for SSH access from the administrator IP
- TCP `2020` for Twenty CRM web access
- Outbound internet traffic for package installation and ECR communication

### IAM Configuration

Terraform creates and manages:

- IAM role: `twenty-crm-task12-role`
- IAM instance profile: `twenty-crm-task12-profile`
- AWS managed policy: `AmazonEC2ContainerRegistryReadOnly`

The IAM role allows the EC2 instance to authenticate with Amazon ECR and pull the Twenty CRM container image.

### Terraform Commands

Initialize Terraform:

~~~bash
terraform init
~~~

Format the configuration:

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

### Docker Image Build

The Twenty CRM image was built locally using `Dockerfile.task12`:

~~~bash
docker build -f Dockerfile.task12 -t twenty-crm-task12:latest .
~~~

### ECR Image Tagging

The local image was tagged with the ECR repository URL:

~~~bash
docker tag twenty-crm-task12:latest \
  992382810695.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12:latest
~~~

### ECR Image Push

Docker was authenticated to Amazon ECR and the image was pushed:

~~~bash
docker push \
  992382810695.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12:latest
~~~

The image push completed successfully and the `latest` image became available in the ECR repository.

### EC2 User Data

The EC2 User Data script performs the following operations:

1. Updates the Ubuntu package index.
2. Installs required dependencies.
3. Installs and starts Docker.
4. Installs AWS CLI v2 when required.
5. Authenticates Docker with Amazon ECR.
6. Retries the ECR image pull until the image becomes available.
7. Starts the Twenty CRM container on port `2020`.
8. Performs an HTTP health check.
9. Prints container logs when the application health check fails.

### Verification

Terraform successfully provisioned the AWS resources.

The EC2 instance passed AWS instance status checks.

The EC2 User Data successfully:

- Authenticated to Amazon ECR
- Pulled the Twenty CRM image from ECR
- Started the Twenty CRM container
- Exposed the container on port `2020`

The container remained running and the application logs showed Twenty CRM/NestJS initialization activity.

The final application-level HTTP verification was not completed before the KodeKloud AWS Playground session expired.

### Issues Encountered

During deployment, the following issues were encountered:

1. The initial EC2 configuration referenced an IAM instance profile that was not available in the KodeKloud Playground.
2. Terraform was updated to create and manage its own EC2 IAM role and instance profile with ECR read-only permissions.
3. The initial User Data retry period expired because the ECR image had not yet been pushed.
4. The retry count was increased and the EC2 instance was replaced.
5. The image was subsequently pulled successfully from ECR.
6. The Twenty CRM container started successfully.
7. The application health check did not complete successfully before the Playground session expired.

### Terraform Outputs

The deployment produced the following outputs:

~~~text
ec2_instance_id
ec2_public_ip
ecr_repository_url
iam_instance_profile
iam_role_name
security_group_id
subnet_id
twenty_crm_url
vpc_id
~~~

Example deployment values included:

~~~text
ECR Repository:
992382810695.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-task12

Twenty CRM URL:
http://44.211.194.13:2020
~~~

The final EC2 public IP may change because the EC2 instance was replaced during troubleshooting.

### Cleanup

The infrastructure can be removed using:

~~~bash
terraform destroy
~~~

An earlier KodeKloud Playground deployment was successfully destroyed. The final Playground session expired before the final cleanup operation could be executed.

---

