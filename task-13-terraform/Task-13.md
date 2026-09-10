# Task 13 - Twenty CRM + AWS S3 using Terraform

## 1. Objective

The objective of Task 13 was to provision AWS infrastructure using Terraform and deploy the Twenty CRM application on an EC2 instance with an S3 bucket configured for application storage.

---

## 2. Task Requirements

The implementation followed these requirements:

- Use Terraform with AWS region `us-east-1`.
- Use the existing/default VPC, Use an existing/default subnet.
- Provision one EC2 instance, EC2 instance type must be `t3.small` and Use one of the approved AMIs.
- Provision one S3 bucket, Enable S3 Block Public Access, Enable S3 Versioning, Enable server-side encryption and Apply appropriate tags.
- Attach the provided `EC2S3AccessRole` to EC2.
- Configure Twenty CRM to use the Terraform-created S3 bucket.
- Verify the infrastructure using Terraform and AWS CLI.
- Run `terraform init`, `terraform validate`, `terraform plan`, and `terraform apply`.
- Run `terraform destroy` after testing.

---
## 3. Terraform Files

| File | Purpose |
|------|---------|
| `providers.tf` | Configures the AWS provider and region used by Terraform. |
| `variables.tf` | Defines configurable values such as AWS region, EC2 instance type, S3 bucket name, SSH CIDR, and key pair. |
| `vpc.tf` | Retrieves the existing default VPC and its subnets. No new VPC is created. |
| `s3.tf` | Creates the S3 bucket and configures public access blocking, versioning, and server-side encryption. |
| `ec2.tf` | Creates the security group and EC2 instance, attaches the existing `EC2S3AccessRole`/`EC2S3AccessRole` instance profile, and passes the S3 configuration to the instance. |
| `user-data.sh` | Installs Docker and AWS CLI on the EC2 instance and starts the Twenty CRM Docker container configured to use the Terraform-created S3 bucket. |
| `outputs.tf` | Displays useful Terraform outputs such as EC2 instance ID, public IP, S3 bucket name/ARN, VPC ID, and subnet ID. |

## 4. Twenty CRM Docker Deployment

After the EC2 instance was created, the user-data script installed Docker and started the Twenty CRM container.

The running container was verified with:

```bash
sudo docker ps
```

The result showed:

```text
CONTAINER ID   IMAGE                             COMMAND   STATUS
7ffd378495f7   twentycrm/twenty-app-dev:latest   "/init"   Up
```

The container name was:

```text
twenty-crm
```

The port mapping was:

```text
0.0.0.0:2020 -> 2020/tcp
```

---

## 5. Twenty CRM Application Verification

The Twenty CRM application logs showed:

```text
Nest application successfully started
```

The application was also tested locally on the EC2 instance using:

```bash
curl http://localhost:2020
```

The command returned the Twenty CRM HTML page.

This confirmed that the application was successfully running and responding on port `2020`.

---

## 6. Twenty CRM S3 Configuration

The Docker container was checked to verify the S3 configuration.

Command:

```bash
sudo docker exec twenty-crm env | grep '^STORAGE_'
```

Output:

```text
STORAGE_TYPE=S3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=twenty-crm-task13-purva
```

This confirms that Twenty CRM was configured to use:

```text
Storage Type: S3
Region: us-east-1
Bucket: twenty-crm-task13-purva
```
---

## 7. EC2 to S3 Access Verification

S3 access was verified directly from the EC2 instance.

Command:

```bash
aws s3 ls s3://twenty-crm-task13-purva
```

The command successfully returned an S3 prefix, which confirmed that the EC2 instance could access the Terraform-created S3 bucket.

---

## 8. S3 Upload and Download Test

An actual S3 read/write test was also performed from the EC2 instance.

A test file was created:

```bash
echo "Task 13 S3 verification" > /tmp/task13-test.txt
```

The file was uploaded to S3:

```bash
aws s3 cp /tmp/task13-test.txt \
  s3://twenty-crm-task13-purva/task13-test.txt
```

The file was downloaded again:

```bash
aws s3 cp \
  s3://twenty-crm-task13-purva/task13-test.txt \
  /tmp/task13-download.txt
```

The downloaded file was verified:

```bash
cat /tmp/task13-download.txt
```

The expected content was returned:

```text
Task 13 S3 verification
```

The test object was then removed:

```bash
aws s3 rm s3://twenty-crm-task13-purva/task13-test.txt
```

This verified both S3 write and read access from the EC2 instance.

---
## 9. Terraform Validation

Terraform configuration was formatted and validated before deployment.

Commands used:

```bash
terraform fmt
```

and:

```bash
terraform validate
```

Terraform returned:

```text
Success! The configuration is valid.
```

---

## 10. Terraform Initialization

Terraform was initialized using:

```bash
terraform init
```

The AWS provider was installed successfully.

---

## 11. Terraform Plan

The infrastructure plan was generated using:

```bash
terraform plan \
  -var="s3_bucket_name=twenty-crm-task13" -var="key_name=pem_filename"
```

## 12. Terraform Apply

Terraform apply was executed using:

```bash
terraform apply -var="s3_bucket_name" -var="key_name"
```

The infrastructure was successfully created.

The resulting EC2 instance was:

```text
i-08327e4b3f4ca82c0
```

The S3 bucket was:

```text
twenty-crm-task13-purva
```

The application was successfully deployed and verified after the infrastructure creation.

---

## 13. IAM Permission Issues During Deployment

During the Terraform workflow, several AWS S3 read permissions were initially missing from the existing `purva-wankhede` IAM user.

The first error was:

```text
s3:GetBucketPolicy
```

After that permission was provided, Terraform continued and exposed additional required read operations such as:

```text
s3:GetBucketAcl
s3:GetBucketCORS
s3:GetBucketWebsite
```

These permissions were related to Terraform refreshing the existing `aws_s3_bucket` resource.

---

## 14. IAM Permission Issue During Cleanup

After testing, the required cleanup was attempted using:

```bash
terraform destroy \
  -var="s3_bucket_name=twenty-crm-task13-purva" \
  -var="key_name=task-10-purva"
```

Terraform successfully began destroying the infrastructure.

However, deletion of the S3 bucket was blocked because the existing IAM user did not have:

```text
s3:ListBucketVersions
```

Therefore, the S3 bucket remained because of the AWS IAM permission limitation.

---

## 15. Conclusion

Task 13 successfully demonstrated infrastructure provisioning with Terraform and deployment of Twenty CRM on AWS EC2 with S3-backed application storage.

### Thank you!
