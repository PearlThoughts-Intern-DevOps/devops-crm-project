# Task 13 - Terraform Twenty CRM with Amazon S3

**Name:** Harish
**Task:** Task 13 - Deploy Twenty CRM with Terraform and Amazon S3
**Date** 10 September 2026
**PR link** [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/298]
**Loom link** [https://drive.google.com/file/d/1w47kahTZJ5HtSjFDHnLLEM67Vi71EaBt/view?usp=drive_link]

## Objective

* Deploy Twenty CRM on an AWS EC2 instance using Terraform.
* Create an Amazon S3 bucket for Twenty CRM storage.
* Use the existing IAM instance profile to allow EC2 to access S3.
* Automate Docker and Twenty CRM deployment using EC2 user data.
* Verify the infrastructure, S3 configuration, Docker containers, and CRM application.

## Work Completed

* Terraform infrastructure was created for the EC2 instance, security group, SSH key pair, and S3 bucket.
* The existing IAM instance profile `EC2S3AccessRole` was reused.
* Twenty CRM was deployed automatically on EC2 using Docker Compose.
* Twenty CRM storage was configured to use Amazon S3.
* Terraform validation, plan, and apply were completed successfully.
* EC2, Docker containers, Twenty CRM, and S3 configuration were checked.

## Terraform Infrastructure

Created and configured:

* AWS provider in `us-east-1`
* Existing default VPC
* Existing subnet
* One EC2 instance
  * Amazon Linux 2023 AMI
  * `t3.small` instance type
  * Existing IAM instance profile `EC2S3AccessRole`
* Security group for SSH port 22 and Twenty CRM port 3000
* Terraform-generated SSH key pair
* Amazon S3 bucket
  * Versioning enabled
  * AES256 server-side encryption
  * Block Public Access enabled
  * Tags
  * `force_destroy` for cleanup

No new IAM user, IAM role, or IAM policy was created.

## S3 Configuration

The S3 bucket was created using Terraform.

Configured:

```
STORAGE_TYPE=s3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=<Terraform-created bucket>
AWS_REGION=us-east-1
```

The EC2 instance uses the existing `EC2S3AccessRole` instance profile for AWS access.

## Twenty CRM

Twenty CRM was deployed automatically using EC2 user data.

The user-data script:

* Created 4 GB swap
* Updated the Amazon Linux system
* Installed Docker, Git, OpenSSL, and AWS CLI
* Installed Docker Compose when required
* Cloned the `devops-crm-project` repository
* Used the `harish-task13` branch
* Created the `.env` file
* Generated `APP_SECRET`
* Configured S3 storage
* Started Twenty CRM with Docker Compose
* Waited for the application to become ready
* Checked the application response

The deployment completed successfully.

## Docker Verification

* PostgreSQL container was healthy.
* Redis container was healthy.
* Twenty CRM server container was healthy.
* Twenty CRM was exposed on port 3000.

Commands used:

```bash
sudo docker ps
docker ps
docker-compose ps
sudo docker images
curl -I http://localhost:3000
curl -fsS http://localhost:3000
```

The automated user-data check returned:

```
Twenty CRM is responding.
Twenty CRM is running successfully.
```

## Terraform Verification

Terraform formatting, initialization, validation, planning, and apply were completed.

Commands used:

```bash
terraform fmt
terraform init -upgrade
terraform validate
terraform plan
terraform apply
terraform output
terraform show
```

Apply completed successfully:

```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

The Terraform outputs provided the EC2 public IP, EC2 public DNS, S3 bucket name, S3 bucket ARN, VPC ID, subnet ID, and SSH command.

## Issues and Solutions

### Issue 1: Dockerfile on `harish-task5` still contained the broken `.yarn` COPY line

**Problem:** Reusing the Dockerfile from `harish-task5` failed on every fresh clone, since it still had `COPY .yarn ./.yarn`, and `.yarn/` is gitignored, not committed.

**Solution:** Created a corrected Dockerfile and `docker-compose.yml` directly on `harish-task13` with that line removed, and pointed the user-data script's `git clone` at `harish-task13` instead.

```bash
grep -n "\.yarn" Dockerfile
git commit -m "Fix Dockerfile for Task 13"
git push origin harish-task13
```

### Issue 2: IAM permission denied for several S3 verification calls

**Problem:** The provided `EC2S3AccessRole` was missing several S3 read permissions (`GetBucketLogging`, `GetBucketVersioning`, `GetBucketWebsite`, `ListAllMyBuckets`, `GetBucketAcl`), causing `AccessDenied` errors during verification.

**Solution:** Reported the exact error messages and required actions to the mentor channel as instructed; access was granted, and verification succeeded.

```bash
aws s3api get-bucket-versioning --bucket "$(terraform output -raw s3_bucket_name)"
```

### Issue 3: Original storage configuration used local disk instead of S3

**Problem:** The Twenty CRM environment inherited from earlier tasks defaulted to `STORAGE_TYPE=local`, which doesn't satisfy Task 13's S3 requirement.

**Solution:** Compared Twenty CRM's supported storage backends and set the environment to use the Terraform-provisioned S3 bucket.

```bash
# .env
STORAGE_TYPE=s3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=<bucket>

grep STORAGE_ .env
```

### Issue 4: `APP_SECRET` missing caused Twenty CRM to fail on startup

**Problem:** Twenty CRM requires `APP_SECRET` to be set and refuses to start correctly when the value is empty or missing.

**Solution:** Generated a random secret inside the user-data script itself so every fresh deployment gets a valid, unique value automatically.

```bash
APP_SECRET="${APP_SECRET:-$(openssl rand -hex 32)}"
```

### Issue 5: Application not reachable despite SSH working fine

**Problem:** SSH access on port 22 alone doesn't expose the Twenty CRM web application; the browser/curl couldn't reach port 3000.

**Solution:** Added an explicit inbound rule for TCP port 3000 to the EC2 security group in Terraform, then re-applied.

```bash
terraform plan
terraform apply
curl -I http://localhost:3000
```

### Issue 6: Changing `user_data` triggered EC2 replacement

**Problem:** Updating the Terraform `user_data` script (e.g. to fix the Dockerfile branch) caused Terraform to plan a full instance replacement, not an in-place update.

**Solution:** Reviewed the plan output carefully before applying, since `user_data_replace_on_change` intentionally forces a new instance to guarantee the updated bootstrap script actually runs.

```bash
terraform plan   # review "1 to add, 1 to destroy" before confirming
terraform apply
```

## AWS Verification Commands

```bash
# Check existing IAM instance profile
aws iam get-instance-profile --instance-profile-name EC2S3AccessRole

# Get S3 bucket name
terraform output -raw s3_bucket_name

# Check S3 versioning
aws s3api get-bucket-versioning --bucket "$(terraform output -raw s3_bucket_name)"

# Check S3 encryption
aws s3api get-bucket-encryption --bucket "$(terraform output -raw s3_bucket_name)"

# Check S3 Block Public Access
aws s3api get-public-access-block --bucket "$(terraform output -raw s3_bucket_name)"

# Check S3 tags
aws s3api get-bucket-tagging --bucket "$(terraform output -raw s3_bucket_name)"

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=twenty-crm-harish"

# Check EC2 security group
aws ec2 describe-security-groups --group-ids <security-group-id>

# Check EC2 deployment
sudo cloud-init status

# Check Docker
sudo docker ps

# Check Twenty CRM
curl -I http://localhost:3000
```

## All Commands Used in Task 13

### Git Commands

```bash
git checkout -b harish-task13
git branch --show-current
git add .
git commit -m "Task 13: Terraform Twenty CRM with S3 storage"
git push -u origin harish-task13
git status
```

### Terraform Commands

```bash
terraform fmt
terraform init -upgrade
terraform validate
terraform plan
terraform apply
terraform output
terraform output -raw s3_bucket_name
terraform show
terraform destroy
terraform state list
```

### AWS Commands

```bash
aws iam get-instance-profile --instance-profile-name EC2S3AccessRole
aws s3api get-bucket-versioning --bucket "$(terraform output -raw s3_bucket_name)"
aws s3api get-bucket-encryption --bucket "$(terraform output -raw s3_bucket_name)"
aws s3api get-public-access-block --bucket "$(terraform output -raw s3_bucket_name)"
aws s3api get-bucket-tagging --bucket "$(terraform output -raw s3_bucket_name)"
aws ec2 describe-instances --filters "Name=tag:Project,Values=twenty-crm-harish"
aws ec2 describe-security-groups --group-ids <security-group-id>
```

### EC2 Commands

```bash
ssh -i twenty-crm-harish.pem ec2-user@3.228.13.187
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo usermod -aG docker ec2-user
newgrp docker
free -h
swapon --show
sudo cloud-init status
sudo docker ps
docker ps
sudo docker images
```

### Docker and Twenty CRM Commands

```bash
docker-compose --version
docker compose version
docker-compose up -d
docker-compose ps
docker-compose logs --tail=100
curl -I http://localhost:3000
curl -fsS http://localhost:3000
grep -E 'STORAGE_TYPE|STORAGE_S3_REGION|STORAGE_S3_NAME|AWS_REGION' .env
```

### Git Repository Verification Commands on EC2

```bash
sudo git -C /opt/twenty-crm/devops-crm-project branch --show-current
sudo git -C /opt/twenty-crm/devops-crm-project remote -v
```

## Final Status

| Item | Status |
|---|---|
| Objective | ✅ Completed |
| Work completed | ✅ Completed |
| Terraform infrastructure | ✅ Completed |
| S3 configuration | ✅ Completed |
| Twenty CRM deployment | ✅ Completed |
| Docker verification | ✅ Completed |
| Terraform verification | ✅ Completed |
| AWS verification | ✅ Completed |
