# Task 13: Twenty CRM + AWS S3 using Terraform

This configuration provisions only the resources required for the task:

- The existing default VPC and its first subnet are read with data sources; no VPC is created.
- One S3 bucket is created with public access blocked, versioning enabled, and AES-256 encryption.
- One `t3.small` EC2 instance uses one of the two approved AMIs and the pre-existing `EC2S3AccessRole`.
- The instance installs Docker Compose and runs Twenty CRM, PostgreSQL, and Redis.
- Twenty CRM is configured with the Terraform-created S3 bucket as its storage backend.
- A security group allows HTTP from the internet and SSH only from `ssh_allowed_cidr`.

No AWS credentials are stored in this repository. Configure them locally with the AWS CLI or environment variables.

## Terraform workflow

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

After reviewing the plan, deploy with `terraform apply`. After verification, clean up every resource, including the S3 bucket, with:

```bash
terraform destroy
```

## Verification checklist

```bash
terraform output
curl --fail "$(terraform output -raw server_url)"
aws s3api head-bucket --bucket "$(terraform output -raw s3_bucket_name)" --region us-east-1
aws ec2 describe-instances --filters "Name=tag:Project,Values=devops-crm" --region us-east-1
ssh ubuntu@"$(terraform output -raw server_public_ip)" 'docker compose -f /opt/twenty/docker-compose.yml ps'
```

The final task verification requires AWS credentials, the pre-existing `EC2S3AccessRole`, and a running instance. Capture the successful HTTP response, S3 bucket check, EC2 command output, and destroy result for the PR. The Loom video and PR must be created manually in GitHub; do not record or commit credentials.