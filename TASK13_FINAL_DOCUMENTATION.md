# TASK 13 — Terraform + AWS S3 + Twenty CRM

## Final Deployment and Verification Record

### 1. Objective

Deploy Twenty CRM in AWS `us-east-1` using Terraform with:

- Existing/default VPC and subnet
- One `t3.small` EC2 instance
- Approved AMI `ami-081b0a6eac00b4f53`
- Terraform-created S3 bucket
- S3 Block Public Access
- S3 versioning
- S3 AES256 server-side encryption
- Existing IAM instance profile `EC2S3AccessRole`
- Docker and Docker Compose
- Twenty CRM configured to use the Terraform-created S3 bucket
- No Terraform-created IAM users, roles or policies
- Terraform-based provisioning and cleanup

Branch:

```text
netaji-task13
```

---

# 2. Terraform Files

```text
terraform/
├── data.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── s3.tf
├── templates/
│   └── user_data.sh.tpl
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

> Do not commit `terraform.tfstate`, `terraform.tfstate.backup`, credentials, `.env` files, `.pem` files or API keys.

---

# 3. Terraform Configuration

## Existing AWS resources

`data.tf` references the existing/default VPC, subnet, default security group and existing IAM instance profile:

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_iam_instance_profile" "s3_access" {
  name = var.iam_instance_profile_name
}
```

No new VPC or IAM resources are created.

## EC2

The EC2 uses:

```text
AMI: ami-081b0a6eac00b4f53
Instance type: t3.small
Region: us-east-1
IAM instance profile: EC2S3AccessRole
```

## S3

Terraform creates:

```text
Bucket: netaji-twenty-crm-storage-2026
```

with:

- Block Public Access
- Versioning
- AES256 server-side encryption
- `force_destroy = true`

---

# 4. Terraform Commands

## Local WSL terminal

```bash
cd ~/workspace/internship/PearlThoughts/devops-crm-project/terraform
```

```bash
terraform fmt
```

```bash
terraform validate
```

```bash
terraform plan
```

```bash
terraform apply
```

Successful deployment:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

---

# 5. Current Terraform Outputs

```text
ec2_iam_instance_profile = "EC2S3AccessRole"
ec2_instance_id = "i-0632a145a73548039"
ec2_public_ip = "3.237.201.74"
s3_bucket_arn = "arn:aws:s3:::netaji-twenty-crm-storage-2026"
s3_bucket_name = "netaji-twenty-crm-storage-2026"
subnet_id = "subnet-078d52bfe579c74f2"
vpc_id = "vpc-0c241509159132524"
```

---

# 6. Terraform State Verification

## Local WSL terminal

```bash
terraform state list
```

Current state:

```text
data.aws_iam_instance_profile.s3_access
data.aws_security_group.default
data.aws_subnets.default_vpc
data.aws_vpc.default
aws_instance.twenty
aws_s3_bucket.twenty_storage
aws_s3_bucket_public_access_block.twenty_storage
aws_s3_bucket_server_side_encryption_configuration.twenty_storage
aws_s3_bucket_versioning.twenty_storage
```

The `data.*` entries reference existing AWS resources.

The five `aws_*` resources are managed by this Task 13 Terraform configuration.

---

# 7. EC2 Connection

## Local WSL terminal

```bash
ssh -i ~/.ssh/task7-netaji.pem ec2-user@3.237.201.74
```

Current EC2:

```text
Instance ID: i-0632a145a73548039
Public IP:   3.237.201.74
```

---

# 8. User Data Verification

## EC2 terminal

```bash
sudo tail -50 /var/log/user-data.log
```

The final User Data log showed:

```text
Image twentycrm/twenty:latest Pulled
Network twenty-crm_default Created
Volume twenty-crm_twenty-redis-data Created
Volume twenty-crm_twenty-db-data Created
Container twenty-crm-redis Started
Container twenty-crm-db Started
Container twenty-crm-worker Started
Container twenty-crm-server Started
=== Twenty CRM S3 bootstrap completed ===
=== S3 bucket: netaji-twenty-crm-storage-2026 ===
```

This confirms that the automated Docker/Twenty bootstrap completed.

---

# 9. Docker and Twenty CRM Verification

## EC2 terminal

```bash
sudo docker compose -f /opt/twenty-crm/docker-compose.yml ps
```

Current result:

```text
twenty-crm-db       Up
twenty-crm-redis    Up
twenty-crm-server   Up
twenty-crm-worker   Up
```

The Twenty server is exposed on:

```text
0.0.0.0:3000->3000/tcp
```

---

# 10. Twenty CRM HTTP Verification

## EC2 terminal

```bash
curl -I http://localhost:3000
```

Verified:

```text
HTTP/1.1 200 OK
```

This confirms the Twenty CRM server is responding.

---

# 11. Twenty CRM Browser Verification

Initially, opening:

```text
http://3.237.201.74:3000/
```

redirected to:

```text
http://localhost:3000/welcome
```

and Chrome showed:

```text
ERR_CONNECTION_REFUSED
```

## Root cause

The Docker Compose configuration contained:

```yaml
SERVER_URL: http://localhost:3000
```

Twenty used this value to generate external redirect URLs.

`localhost` refers to the user's own computer/browser, not the EC2 server.

## Temporary verification fix

On the EC2, the running Compose file was temporarily changed with:

```bash
sudo sed -i 's|SERVER_URL: http://localhost:3000|SERVER_URL: http://3.237.201.74:3000|' /opt/twenty-crm/docker-compose.yml
```

Then the server container was recreated:

```bash
sudo docker compose -f /opt/twenty-crm/docker-compose.yml up -d --force-recreate server
```

The running container was verified with:

```bash
sudo docker inspect twenty-crm-server --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^SERVER_URL='
```

Result:

```text
SERVER_URL=http://3.237.201.74:3000
```

The browser then successfully displayed:

```text
Welcome to your workspace
```

at:

```text
http://3.237.201.74:3000/welcome
```

---

# 12. Important Terraform Fix for SERVER_URL

The manual fix above is not sufficient for the final Terraform configuration because an EC2 replacement may receive a different public IP.

Do **not** hardcode:

```text
3.237.201.74
```

in Terraform.

Instead, the User Data template should dynamically discover the EC2 public IPv4 address using IMDSv2:

```bash
echo "=== Detecting EC2 public IP ==="
IMDS_TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $${IMDS_TOKEN}" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "=== EC2 public IP: $${PUBLIC_IP} ==="
```

The Compose configuration should then use:

```yaml
SERVER_URL: http://$${PUBLIC_IP}:3000
```

This makes the deployment reproducible when Terraform creates a new EC2 with a different public IP.

After making this change in `templates/user_data.sh.tpl`, run:

```bash
terraform fmt
terraform validate
terraform plan
```

Do not manually rely on the EC2-only `sed` change for the final solution.

---

# 13. IAM Verification

## EC2 terminal

```bash
aws sts get-caller-identity
```

Verified:

```text
Arn: arn:aws:sts::579138738751:assumed-role/EC2S3AccessRole/i-0632a145a73548039
```

This proves that:

- The EC2 has AWS credentials.
- The credentials come from the EC2 IAM role.
- The existing `EC2S3AccessRole` is being assumed.
- Static AWS access keys are not required.

---

# 14. S3 Access Verification

## EC2 terminal

```bash
aws s3api head-bucket --bucket netaji-twenty-crm-storage-2026
```

Verified:

```text
BucketArn: arn:aws:s3:::netaji-twenty-crm-storage-2026
BucketRegion: us-east-1
```

This proves that the EC2 IAM role can access the Terraform-created S3 bucket.

---

# 15. S3 Versioning Verification

## EC2 terminal

```bash
aws s3api get-bucket-versioning --bucket netaji-twenty-crm-storage-2026
```

Verified:

```json
{
    "Status": "Enabled"
}
```

---

# 16. S3 Encryption Verification

## EC2 terminal

```bash
aws s3api get-bucket-encryption   --bucket netaji-twenty-crm-storage-2026
```

Verified:

```text
SSEAlgorithm: AES256
BucketKeyEnabled: true
```

---

# 17. S3 Block Public Access Verification

## EC2 terminal

```bash
aws s3api get-public-access-block   --bucket netaji-twenty-crm-storage-2026
```

Verified:

```text
BlockPublicAcls:       true
IgnorePublicAcls:      true
BlockPublicPolicy:     true
RestrictPublicBuckets: true
```

---

# 18. S3 Actual Data Verification

The bucket already contains objects created by Twenty CRM, for example:

```text
server/application-registration/.../public/gallery/...
server/application-registration/.../public/logo.svg
server/application-registration/.../public/cover.generated.png
```

This was verified with:

## EC2 terminal

```bash
aws s3 ls s3://netaji-twenty-crm-storage-2026 --recursive
```

This is strong evidence that Twenty CRM is actually writing application assets to the configured S3 bucket.

---

# 19. Earlier Issues and Fixes

## Issue 1 — curl/curl-minimal package conflict

Original:

```bash
dnf install -y docker curl openssl
```

Amazon Linux 2023 already had `curl-minimal`, causing a package conflict.

Fix:

```bash
dnf install -y docker openssl
```

---

## Issue 2 — Docker Compose initially unavailable

Compose was initially unavailable during the first deployment.

The Compose v2 plugin was installed with:

```bash
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL   https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64   -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
```

The corrected User Data now installs Compose automatically.

---

## Issue 3 — Twenty migration/startup delay

Twenty initially displayed:

```text
Running database setup and migrations...
```

The worker briefly restarted during startup.

After initialization, all containers became stable.

---

## Issue 4 — SSH timeout during an earlier deployment

An earlier EC2 became difficult to access and returned:

```text
Connection timed out during banner exchange
```

AWS health checks were still OK and port 22 was allowed by the security group.

That earlier instance was replaced.

The current instance is:

```text
i-0632a145a73548039
3.237.201.74
```

and is reachable.

---

## Issue 5 — localhost redirect

Twenty redirected external browser requests to:

```text
http://localhost:3000/welcome
```

Root cause:

```yaml
SERVER_URL: http://localhost:3000
```

The running container was fixed and the browser subsequently displayed the Twenty workspace welcome page.

The permanent Terraform fix is to dynamically obtain the EC2 public IP through IMDSv2.

---

# 20. Current Verification Matrix

| Requirement | Status |
|---|---|
| Terraform apply | PASS |
| 5 resources created | PASS |
| Approved AMI | PASS |
| t3.small | PASS |
| Existing/default VPC | PASS |
| Existing/default subnet | PASS |
| Existing `EC2S3AccessRole` | PASS |
| No new IAM resources | PASS |
| Docker | PASS |
| Docker Compose | PASS |
| PostgreSQL | PASS |
| Redis | PASS |
| Twenty server | PASS |
| Twenty worker | PASS |
| Twenty HTTP response | PASS — HTTP 200 |
| Twenty browser welcome page | PASS |
| EC2 assumes IAM role | PASS |
| EC2 can access S3 | PASS |
| Twenty assets present in S3 | PASS |
| S3 versioning | PASS |
| S3 AES256 encryption | PASS |
| S3 Block Public Access | PASS |
| Dynamic SERVER_URL Terraform fix | PENDING |
| Final `terraform plan` | PENDING |
| Final `terraform destroy` | PENDING |
| Cleanup verification | PENDING |
| Git commit/push | PENDING |
| Pull Request | PENDING |

---

# 21. Final Verification Sequence

After updating `templates/user_data.sh.tpl` with the dynamic `PUBLIC_IP` fix:

## Local WSL terminal

```bash
terraform fmt
```

```bash
terraform validate
```

```bash
terraform plan
```

Review the plan carefully.

Because `user_data_replace_on_change = true`, changing User Data may cause the EC2 instance to be replaced.

After confirming the plan:

```bash
terraform apply
```

Then obtain the new public IP:

```bash
terraform output ec2_public_ip
```

Connect to it:

```bash
ssh -i ~/.ssh/task7-netaji.pem ec2-user@<NEW_PUBLIC_IP>
```

Verify:

```bash
sudo docker compose -f /opt/twenty-crm/docker-compose.yml ps
```

Then:

```bash
curl -I http://localhost:3000
```

Finally open:

```text
http://<NEW_PUBLIC_IP>:3000/
```

and confirm that Twenty remains on the EC2 public address instead of redirecting to localhost.

---

# 22. Final Terraform Convergence Check

## Local WSL terminal

```bash
terraform plan
```

Desired result:

```text
No changes. Your infrastructure matches the configuration.
```

This should be shown in the Loom recording.

---

# 23. Optional S3 Upload/Download Test

## EC2 terminal

```bash
echo "Task 13 S3 test" > /tmp/task13-s3-test.txt
```

```bash
aws s3 cp /tmp/task13-s3-test.txt s3://netaji-twenty-crm-storage-2026/task13-s3-test.txt
```

```bash
aws s3 cp s3://netaji-twenty-crm-storage-2026/task13-s3-test.txt /tmp/task13-s3-test-downloaded.txt
```

```bash
cat /tmp/task13-s3-test-downloaded.txt
```

Expected:

```text
Task 13 S3 test
```

Clean up:

```bash
aws s3 rm s3://netaji-twenty-crm-storage-2026/task13-s3-test.txt
```

---

# 24. Final Cleanup Required by Assignment

Only after the working deployment has been demonstrated and the Loom recording is complete:

## Local WSL terminal

```bash
terraform destroy -auto-approve
```

Then:

```bash
terraform state list
```

Verify that the Terraform-managed resources are gone.

Verify the bucket is gone:

```bash
aws s3api head-bucket --bucket netaji-twenty-crm-storage-2026
```

The lookup should fail because the bucket no longer exists.

---

# 25. Git Safety Check

## Local WSL terminal

```bash
git status --short
```

Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
.env
*.pem
AWS credentials
Twenty API keys
```

Make sure `.gitignore` excludes Terraform state and secret files.

---

# 26. Git Commit and Push

## Local WSL terminal

```bash
git status --short
```

```bash
git add .
```

```bash
git commit -m "Add Terraform S3 integration for Twenty CRM"
```

```bash
git push origin netaji-task13
```

Then create the Pull Request for `netaji-task13`.

---

# 27. Loom Video Script

## Introduction

"Hi, I'm Netaji Sai Akash, and this is my Task 13 implementation.

The objective is to deploy Twenty CRM using Terraform and integrate it with an S3 bucket."

## Terraform

"Terraform uses the existing default VPC and subnet instead of creating a new VPC.

The EC2 instance uses the mentor-approved Amazon Linux 2023 AMI and a t3.small instance type."

## IAM

"The assignment requires using the existing EC2S3AccessRole and does not allow creating new IAM users, roles or policies.

Therefore Terraform references the existing instance profile using a data source."

## S3

"The S3 bucket is created by Terraform.

Block Public Access is enabled, versioning is enabled, and server-side encryption uses AES256."

## Docker and Twenty

"The EC2 User Data installs Docker and Docker Compose and starts the Twenty CRM stack.

The stack contains the Twenty server, worker, PostgreSQL and Redis."

## S3 Integration

"Twenty CRM is configured to use the Terraform-created S3 bucket in us-east-1.

The EC2 instance uses its IAM role for AWS access rather than static AWS access keys."

## Verification

"I verified that Twenty CRM returns HTTP 200.

I verified that the EC2 is assuming EC2S3AccessRole.

I verified that the EC2 can access the S3 bucket.

I also verified S3 versioning, AES256 encryption and all four Block Public Access settings."

## S3 Data

"The S3 bucket also contains assets generated by the Twenty CRM application, confirming that application storage is being written to S3."

## Troubleshooting

"I encountered a curl and curl-minimal package conflict on Amazon Linux, so I removed curl from the Docker installation command.

I also initially had a Docker Compose availability issue, so Compose installation was automated in User Data.

Twenty CRM needed time for database initialization and migrations.

Finally, I found that SERVER_URL was configured as localhost, which caused external browser redirects to localhost. I corrected the running container and am making the fix permanent in Terraform by dynamically detecting the EC2 public IP."

## Final

"After the final Terraform configuration is verified, I will run terraform plan to confirm there are no changes, complete the required testing, and run terraform destroy to verify that Terraform can clean up the created resources."

---

# 28. Loom Checklist

- [ ] Face visible throughout
- [ ] Show Terraform tree
- [ ] Explain default VPC/subnet
- [ ] Show approved AMI
- [ ] Show t3.small
- [ ] Explain existing EC2S3AccessRole
- [ ] Explain no IAM resources are created
- [ ] Show S3 Terraform configuration
- [ ] Show Docker Compose configuration
- [ ] Explain S3 environment variables
- [ ] Show Docker containers
- [ ] Show HTTP 200
- [ ] Show Twenty CRM welcome page
- [ ] Show `aws sts get-caller-identity`
- [ ] Show S3 bucket access
- [ ] Show S3 versioning
- [ ] Show S3 encryption
- [ ] Show Block Public Access
- [ ] Show S3 application objects
- [ ] Explain package conflict
- [ ] Explain Docker Compose issue
- [ ] Explain Twenty migrations
- [ ] Explain localhost/SERVER_URL issue
- [ ] Show final `terraform plan`
- [ ] Show `terraform destroy`
- [ ] Show cleanup verification

---

# 29. Final Status

The major Task 13 functionality has been successfully demonstrated:

- Terraform provisioning: PASS
- EC2 deployment: PASS
- Twenty CRM Docker deployment: PASS
- Twenty HTTP response: PASS
- Twenty browser welcome page: PASS after SERVER_URL correction
- EC2 IAM role integration: PASS
- S3 access: PASS
- S3 application assets: PASS
- S3 versioning: PASS
- S3 AES256 encryption: PASS
- S3 Block Public Access: PASS

The remaining work is to make the dynamic `SERVER_URL` change permanent in the Terraform User Data template, run the final convergence check, record Loom, perform the required Terraform destroy/cleanup, and complete Git/PR submission.
