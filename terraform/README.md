# Task 13: Twenty CRM with Amazon S3

This Terraform configuration deploys one Twenty CRM EC2 instance and one S3
bucket in `us-east-1`. It reuses the account's default VPC, a default subnet,
an existing EC2 key pair, and the existing instance profile containing
`EC2S3AccessRole`.

Terraform does not create or manage VPCs, subnets, key pairs, IAM roles, IAM
policies, or IAM instance profiles.

## Architecture

```text
AWS us-east-1
|
+-- Existing default VPC
|   `-- Existing default subnet in us-east-1a
|       `-- One t3.small EC2 instance
|           +-- Existing EC2S3AccessRole instance profile
|           +-- Amazon Linux 2023
|           +-- Docker Compose
|           +-- Twenty server (host TCP 3000)
|           +-- Twenty worker
|           +-- PostgreSQL 16
|           `-- Redis 7
|
`-- One S3 bucket
    +-- Block Public Access enabled
    +-- Versioning enabled
    +-- AES-256 server-side encryption
    `-- force_destroy enabled for lab cleanup
```

PostgreSQL and Redis are available only on the Docker network. The security
group exposes SSH and the configured Twenty web port only.

## Files

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and AWS provider constraints |
| `provider.tf` | AWS provider configuration |
| `variables.tf` | Typed and validated inputs |
| `locals.tf` | Common tags, names, and pinned Compose metadata |
| `vpc.tf` | Existing default VPC and subnet lookups |
| `security-group.tf` | Restricted SSH, application, and HTTPS rules |
| `s3.tf` | S3 bucket security, versioning, and encryption |
| `ec2.tf` | EC2 instance and rendered User Data |
| `docker-compose.yml.tftpl` | Twenty, worker, PostgreSQL, and Redis services |
| `user-data.sh.tftpl` | Docker installation and automatic startup |
| `outputs.tf` | Network, EC2, URL, S3, and profile results |
| `terraform.tfvars.example` | Safe example input values |

## Fixed Task Requirements

Terraform validation rejects a region other than `us-east-1`, an instance type
other than `t3.small`, and any AMI other than:

- `ami-081b0a6eac00b4f53` — Amazon Linux 2023 x86_64
- `ami-0b6d9d3d33ba97d99` — Ubuntu 26.04 x86_64

The default is the Amazon Linux AMI because User Data uses `dnf`.

## Existing IAM Profile

`iam_instance_profile_name` must be the exact existing instance-profile name
that contains `EC2S3AccessRole`. A role cannot be attached directly to EC2;
EC2 receives it through an instance profile.

The EC2 resource only references the supplied profile name:

```hcl
iam_instance_profile = var.iam_instance_profile_name
```

There are no Terraform IAM resources. The deploying principal still requires
`iam:PassRole` for `EC2S3AccessRole`.

An administrator can verify the existing relationship and policies with:

```bash
aws iam get-role --role-name EC2S3AccessRole
aws iam list-instance-profiles-for-role --role-name EC2S3AccessRole
aws iam list-attached-role-policies --role-name EC2S3AccessRole
aws iam list-role-policies --role-name EC2S3AccessRole
```

The role needs bucket-level access such as `s3:ListBucket`, plus the required
`s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` actions for objects in
the Terraform-created bucket.

## Twenty S3 Configuration

Both the server and worker receive the supported Twenty settings:

```text
IS_CONFIG_VARIABLES_IN_DB_ENABLED=false
STORAGE_TYPE=S_3
STORAGE_S3_REGION=us-east-1
STORAGE_S3_NAME=<Terraform-created bucket name>
```

`STORAGE_S3_ENDPOINT` is omitted because native AWS S3 does not need a custom
endpoint. S3 access-key and secret-key variables are intentionally omitted.
The AWS SDK uses temporary instance-profile credentials from IMDSv2.
Environment-only configuration prevents a database-stored setting from
overriding the Terraform-rendered S3 configuration.

The instance requires IMDSv2 and sets its response hop limit to `2` so the
containerized server and worker can reach the credential provider.

Twenty listens on port `3000` inside its container. `application_port` controls
the EC2 host port and defaults to `3000`.

## S3 Destruction Behavior

Versioned buckets retain historical object versions and delete markers. AWS
will refuse to delete a non-empty bucket. `force_destroy = true` directs the
AWS provider to remove current objects, versions, and delete markers before
deleting this lab bucket during `terraform destroy`.

Do not add S3 Object Lock or retention rules to this lab bucket because they
can prevent version deletion even when `force_destroy` is enabled.

## Local Inputs

Copy the example if a local file does not already exist:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Replace the documentation-only CIDRs, key-pair name, and instance-profile name.
Never add AWS access keys or application secrets. `terraform.tfvars` is ignored
by Git.

## Terraform Workflow

Run from this directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=task13.tfplan
terraform show task13.tfplan
terraform apply task13.tfplan
```

Review the plan before applying. It should create exactly one
`aws_instance.twenty` and one `aws_s3_bucket.twenty_storage`, plus the bucket
configuration and security-group resources. Data sources only read existing
infrastructure.

## Verification

Show Terraform results:

```bash
terraform state list
terraform output
```

Verify S3 controls:

```bash
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
aws s3api get-public-access-block --bucket "$BUCKET_NAME"
aws s3api get-bucket-versioning --bucket "$BUCKET_NAME"
aws s3api get-bucket-encryption --bucket "$BUCKET_NAME"
```

Verify the profile association:

```bash
INSTANCE_ID=$(terraform output -raw ec2_instance_id)
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' \
  --output text
```

Connect with the Amazon Linux user and verify the runtime:

```bash
ssh -i /path/to/key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo cloud-init status --wait --long
sudo systemctl status twenty --no-pager
sudo systemctl is-active twenty
sudo systemctl is-enabled twenty
sudo bash -c 'cd /opt/twenty && docker compose ps'
curl --fail http://localhost:3000/healthz
```

`/opt/twenty` is intentionally accessible only to `root` because it contains
generated application secrets. Do not change its permissions or display its
`.env` file. Use the `sudo bash -c` form above for Compose commands.

View the latest Twenty server startup logs without changing directories:

```bash
sudo docker logs twenty-server-1 --tail 100
```

Follow new server logs with `sudo docker logs -f twenty-server-1` and press
`Ctrl+C` to stop. A successful startup includes:

```text
[NestApplication] Nest application successfully started
```

Docker's health status provides an alternative to the HTTP health command:

```bash
sudo docker inspect --format '{{.State.Health.Status}}' twenty-server-1
```

The expected result is `healthy`.

On EC2, verify the role supplied to the instance:

```bash
TOKEN=$(curl -sS -X PUT \
  -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' \
  http://169.254.169.254/latest/api/token)
curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/
aws sts get-caller-identity
```

Test the instance role against the bucket without static credentials:

```bash
BUCKET_NAME=<terraform-output-bucket-name>
echo 'Task 13 S3 verification' >/tmp/task13-s3-test.txt
aws s3 cp /tmp/task13-s3-test.txt "s3://$BUCKET_NAME/verification/task13-s3-test.txt"
aws s3 cp "s3://$BUCKET_NAME/verification/task13-s3-test.txt" -
aws s3 rm "s3://$BUCKET_NAME/verification/task13-s3-test.txt"
```

Finally, upload a file through Twenty and confirm that an object appears under
the bucket. This verifies that Twenty itself, rather than only the host CLI,
uses S3.

Confirm that the running server uses S3 and has no static AWS credentials:

```bash
sudo docker inspect twenty-server-1 \
  --format '{{range .Config.Env}}{{println .}}{{end}}' | \
  grep -E '^STORAGE_(TYPE|S3_REGION|S3_NAME)='

sudo docker inspect twenty-server-1 \
  --format '{{range .Config.Env}}{{println .}}{{end}}' | \
  grep -E '^(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|STORAGE_S3_ACCESS_KEY_ID|STORAGE_S3_SECRET_ACCESS_KEY)=' || \
  echo 'PASS: no static AWS credentials configured'
```

## Verified Task 13 Results

The deployment was verified on September 10, 2026 with the following final
configuration:

- EC2 name: `devops-crm-dev-ec2`
- EC2 type: `t3.small`
- AMI: `ami-081b0a6eac00b4f53`
- Existing instance profile: `EC2S3AccessRole`
- S3 bucket: `devops-crm-dev-579138738751-twenty-storage`
- Twenty image: `twentycrm/twenty:v2.38.1`
- Twenty URL port: `3000`

Verification confirmed that:

- Cloud-init completed successfully and `twenty.service` became active.
- PostgreSQL and Redis were healthy, the Twenty server was healthy, and the
  worker was running.
- Twenty loaded successfully in a browser.
- The EC2 identity was an assumed-role session for `EC2S3AccessRole`.
- The EC2 role successfully wrote, read, and deleted an S3 test object.
- Twenty wrote `server/application-registration/...` objects to S3, proving
  application-to-S3 integration through the instance profile.
- The bucket had all four Block Public Access controls enabled, versioning
  enabled, and `AES256` server-side encryption.
- The Twenty containers had no static AWS access-key environment variables.
- The final `terraform plan` reported `No changes`.

## Repository Safety

Terraform state, saved plans, and private variable values remain local and
must not be committed. The Terraform `.gitignore` excludes:

```text
*.tfstate
*.tfstate.*
*.tfplan
*.tfvars
```

Commit `terraform.tfvars.example` as the safe input template, but never commit
`terraform.tfvars`.

## Cleanup

After testing and collecting evidence, save the resource identifiers before
destroying the Terraform state:

```bash
INSTANCE_ID=$(terraform output -raw ec2_instance_id)
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
terraform plan -destroy -out=task13-destroy.tfplan
terraform apply task13-destroy.tfplan
terraform state list
```

An empty `terraform state list` confirms that no managed resources remain.
Use these simple commands to verify the deleted resources:

```bash
aws s3api head-bucket --bucket "$BUCKET_NAME" --region us-east-1
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region us-east-1 --query 'Reservations[0].Instances[0].State.Name' --output text
```

The bucket check should return `404 Not Found`, and the EC2 check should return
`terminated`.

The verified cleanup result was `0 added, 0 changed, 9 destroyed`. Terraform
state was empty, the bucket returned `404 Not Found`, and the EC2 instance was
`terminated`. The existing default VPC and subnet remained `available`, the
existing `chirag-crm-server` key pair remained present, and no IAM resources
were managed or destroyed.
