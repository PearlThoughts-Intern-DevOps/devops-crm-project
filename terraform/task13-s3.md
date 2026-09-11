# Task 13: Twenty CRM + Amazon S3 Using Terraform

## 1. Overview

This task deployed **Twenty CRM on AWS EC2** and configured **Amazon S3 as the storage backend**, with the infrastructure provisioned using Terraform. The deployment used the existing/default VPC and subnet, the required `t3.small` EC2 instance, the approved AMI, and the provided `EC2S3AccessRole` instance profile.

### Requirements Completed

- **Region:** `us-east-1`
- **VPC/Subnet:** Existing default VPC and subnet; no new VPC was created.
- **EC2:** `t3.small` using approved AMI `ami-0b6d9d3d33ba97d99`.
- **IAM:** Existing `EC2S3AccessRole` attached to the EC2 instance.
- **S3:** Terraform-created bucket with Block Public Access, versioning, AES256 server-side encryption, and tags.
- **Application:** Twenty CRM deployed with Docker and configured to use the S3 bucket.
- **Validation:** Terraform, AWS CLI, EC2 commands, and HTTP health checks were used for verification.

---

## 2. Terraform Project

The Terraform project is stored in the `terraform/` directory.

The configuration uses:

- Terraform AWS provider configured for `us-east-1`
- Data sources for the existing/default VPC and subnet
- Terraform variables for configurable values
- Outputs for EC2, VPC, subnet, security group, and S3 information
- An EC2 `user_data` bootstrap script for Docker and Twenty CRM setup
- The existing `EC2S3AccessRole` instance profile for S3 access

The configuration also enforces the required `t3.small` instance type and approved AMI values through Terraform variable validation.

The S3 bucket was configured with:

- Block Public Access enabled
- Versioning enabled
- AES256 server-side encryption
- Terraform-managed tags
- `force_destroy = true` so the bucket could be removed during final cleanup.

---

## 3. Deployment Process

The deployment followed this workflow:

```text
Terraform init
      ↓
Terraform validate
      ↓
Terraform plan
      ↓
Terraform apply
      ↓
EC2 + S3 created
      ↓
Docker + Twenty CRM configured by User Data
      ↓
Application and S3 verified
      ↓
Terraform destroy
```

### Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

The apply successfully created the required infrastructure, including the EC2 instance, security group, and S3 resources.

---

## 4. EC2 and Twenty CRM Verification

The EC2 instance was verified with AWS CLI and confirmed to be:

- Running
- `t3.small`
- Using the approved AMI
- Attached to `EC2S3AccessRole`
- Located in the configured subnet

EC2 status checks also passed successfully.

Twenty CRM was verified through network and HTTP checks:

```bash
curl -I http://<EC2_PUBLIC_IP>:2020
```

The application returned HTTP `200 OK`.

Health check:

```bash
curl -s http://<EC2_PUBLIC_IP>:2020/healthz
```

Result:

```text
{"status":"ok","info":{},"error":{},"details":{}}
```

This confirmed that Twenty CRM was running successfully on EC2.

---

## 5. S3 Configuration Verification

The S3 bucket was verified using AWS CLI.

### Versioning

```bash
aws s3api get-bucket-versioning --bucket <BUCKET_NAME>
```

Result: **Enabled**.

### Encryption

```bash
aws s3api get-bucket-encryption --bucket <BUCKET_NAME>
```

Result: **AES256 server-side encryption enabled**.

### Block Public Access

```bash
aws s3api get-public-access-block --bucket <BUCKET_NAME>
```

All four public-access-block settings were enabled.

### Tags

```bash
aws s3api get-bucket-tagging --bucket <BUCKET_NAME>
```

The bucket contained the expected Terraform-managed tags.

---

## 6. Twenty CRM + S3 Integration

Twenty CRM was configured with S3 storage using:

```text
STORAGE_TYPE=s3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=<BUCKET_NAME>
```

The EC2 instance used the `EC2S3AccessRole` instance profile, so no static AWS access keys were required in the application configuration.

S3 objects were observed in the bucket after Twenty CRM started, confirming that the application was able to write storage objects to S3.

---

## 7. Issues Encountered and Solutions

### IAM access

The provided IAM permissions were scoped to resources using the `mohit-*` naming pattern. Using the bucket name `mohit-twenty-crm-task13-storage` aligned the resource with those permissions and resolved the access issue encountered during Terraform operations.

### Security group dependency

A security-group dependency issue was avoided by keeping the configuration consistent and using `create_before_destroy` so updates could be handled safely while the group was attached to EC2.

### User Data changes

`user_data_replace_on_change = true` was used so changes to the bootstrap configuration would trigger a fresh EC2 deployment when required.

### Memory on `t3.small`

A 4 GB swap file was configured during bootstrap to reduce memory pressure on the 2 GB RAM instance during application startup.

---

## 8. Cleanup

After completing verification, the infrastructure was removed with:

```bash
terraform destroy
```

The S3 bucket was configured for forced destruction so test objects could also be removed during cleanup. The final verification confirmed that the Terraform-managed resources were cleaned up.

---

## 9. Key Learnings

- Terraform can manage both compute and application storage infrastructure consistently.
- Existing AWS resources such as a default VPC can be referenced through data sources instead of recreated.
- IAM instance profiles provide a secure way for EC2 applications to access AWS services without embedding credentials.
- S3 versioning, encryption, and Block Public Access should be enabled when using S3 for application storage.
- `terraform plan` and `terraform validate` are important checks before applying infrastructure.
- `terraform destroy` is useful for cleaning up temporary task environments and avoiding unnecessary AWS charges.
