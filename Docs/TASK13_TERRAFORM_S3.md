# Task 13: Twenty CRM + AWS S3 using Terraform

## 1. Overview

This task provisions Twenty CRM on AWS EC2 using Terraform and configures Amazon S3 as the storage backend.

All infrastructure required for the deployment is provisioned and managed using Terraform.

### AWS Region

`us-east-1`

### Architecture

```text
                    AWS us-east-1
                         |
                  Default VPC
                         |
                Default Subnet
                         |
                 +-------+-------+
                 |               |
              EC2 t3.small      S3 Bucket
                 |               |
          Twenty CRM Docker      |
                 |               |
                 +-------+-------+
                         |
                    S3 Storage
```

---

## 2. Task Requirements

The implementation follows the Task 13 requirements:

- Terraform is used for AWS infrastructure provisioning.
- AWS region: `us-east-1`.
- Existing/default VPC and subnet are used.
- EC2 instance type: `t3.small`.
- Approved AMI is used.
- Existing IAM instance profile `EC2S3AccessRole` is attached.
- One S3 bucket is created.
- S3 Block Public Access is enabled.
- S3 versioning is enabled.
- S3 server-side encryption using AES256 is enabled.
- Twenty CRM is deployed using Docker.
- Twenty CRM is configured to use the Terraform-created S3 bucket.
- Terraform variables and outputs are used.
- Infrastructure can be destroyed using `terraform destroy`.

---

## 3. Project Structure

```text
terraform/task13/
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── terraform.tfvars.example
├── .gitignore
└── .terraform.lock.hcl
```

---

## 4. Terraform Configuration

### Provider

Terraform uses the AWS provider in the `us-east-1` region.

```hcl
provider "aws" {
  region = var.aws_region
}
```

### Existing VPC and Subnet

The implementation uses the existing/default AWS VPC and subnet instead of creating a new VPC.

### EC2

The EC2 instance uses:

- Approved AMI
- `t3.small`
- Existing/default subnet
- Public IP
- Terraform-managed security group
- Existing `EC2S3AccessRole` instance profile
- 20 GB GP3 root volume

### S3

The S3 bucket is configured with:

- Versioning enabled
- Block Public Access enabled
- AES256 server-side encryption
- Task-specific tags
- `force_destroy = true` for Terraform cleanup after testing

---

## 5. Twenty CRM Deployment

Twenty CRM is deployed automatically through EC2 `user_data`.

The bootstrap script:

1. Updates the operating system.
2. Installs Docker and required dependencies.
3. Configures 2 GB swap memory.
4. Installs AWS CLI when required.
5. Starts Docker.
6. Retrieves the EC2 public IP using IMDSv2.
7. Pulls the Twenty CRM Docker image.
8. Starts the Twenty CRM container.
9. Configures S3 as the storage backend.
10. Waits for the application to become available.

### Docker Image

```text
twentycrm/twenty-app-dev:v2.38.1
```

### Port Mapping

```text
EC2 port 8080 → Container port 2020
```

---

## 6. S3 Configuration in Twenty CRM

Twenty CRM is configured with the following environment variables:

```text
STORAGE_TYPE=S3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=prabhas-task13-twenty-storage-bucket
STORAGE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com
```

The application server URL is dynamically configured using the EC2 public IP:

```text
SERVER_URL=http://<EC2_PUBLIC_IP>:8080
```

The EC2 public IP is retrieved using the EC2 Instance Metadata Service v2 (IMDSv2).

---

## 7. IAM

The task requires using the provided IAM role.

The EC2 instance uses the existing instance profile:

```text
EC2S3AccessRole
```

No new IAM users, roles, or policies are created by this Terraform configuration.

---

## 8. Security Group

The Terraform-managed security group allows:

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH |
| 8080 | TCP | Twenty CRM |
| All | All | Outbound traffic |

For a production deployment, SSH should preferably be restricted to a trusted IP address instead of `0.0.0.0/0`.

---

## 9. Terraform Commands

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

View Terraform outputs:

```bash
terraform output
```

Destroy the infrastructure after testing:

```bash
terraform destroy
```

---

## 10. Verification

### Terraform Outputs

The deployment provides outputs for:

```text
ec2_instance_id
ec2_public_ip
s3_bucket_arn
s3_bucket_name
subnet_id
twenty_url
vpc_id
```

### EC2 Verification

The EC2 instance was verified as running with:

- `t3.small`
- Approved AMI
- Existing/default VPC and subnet
- `EC2S3AccessRole`

### Swap Verification

The EC2 instance was configured with approximately 2 GB swap memory.

### Docker Verification

The Twenty CRM container was verified using:

```bash
docker ps
```

### Application Health

Twenty CRM was tested locally on the EC2 instance:

```bash
curl -I http://localhost:8080
```

The application returned:

```text
HTTP/1.1 200 OK
```

The Twenty CRM dashboard was also accessed successfully through the EC2 public URL.

---

## 11. S3 Verification

### Versioning

Verified using:

```bash
aws s3api get-bucket-versioning \
  --bucket prabhas-task13-twenty-storage-bucket
```

Result:

```text
Status: Enabled
```

### Public Access Block

Verified using:

```bash
aws s3api get-public-access-block \
  --bucket prabhas-task13-twenty-storage-bucket
```

The following settings were enabled:

```text
BlockPublicAcls: true
IgnorePublicAcls: true
BlockPublicPolicy: true
RestrictPublicBuckets: true
```

### Encryption

Verified using:

```bash
aws s3api get-bucket-encryption \
  --bucket prabhas-task13-twenty-storage-bucket
```

Server-side encryption:

```text
AES256
```

---

## 12. Infrastructure Summary

| Resource | Configuration |
|----------|---------------|
| AWS Region | `us-east-1` |
| VPC | Existing/default VPC |
| Subnet | Existing/default subnet |
| EC2 | `t3.small` |
| AMI | `ami-0b6d9d3d33ba97d99` |
| IAM Instance Profile | `EC2S3AccessRole` |
| Docker | Enabled |
| Twenty CRM | `v2.38.1` |
| Application Port | `8080` |
| Swap | `2 GB` |
| S3 Versioning | Enabled |
| S3 Encryption | AES256 |
| S3 Public Access | Blocked |

---

## 13. Cleanup

After completing verification, the infrastructure can be removed using:

```bash
terraform destroy
```

Terraform is configured to remove the resources created for this task, including the EC2 instance, security group, key pair, and S3 bucket.

The S3 bucket uses:

```hcl
force_destroy = true
```

to allow Terraform to remove the bucket during cleanup after testing.

---

## 14. Conclusion

Task 13 demonstrates infrastructure provisioning using Terraform, deployment of Twenty CRM on AWS EC2, and integration of Amazon S3 as the storage backend.

The deployment was verified through Terraform outputs, AWS CLI checks, EC2 commands, Docker health checks, S3 configuration verification, and successful access to the Twenty CRM dashboard.

