# Task 12: Terraform + AWS Infrastructure for Twenty CRM

Provisions the base AWS infrastructure for Twenty CRM using Terraform (EC2 + ECR,
using the account's existing default VPC/subnet) and deploys the app via Docker
through Amazon ECR.

## Architecture

- **VPC/Subnet**: uses the account's existing default VPC and a subnet within it
  (no new VPC created), looked up dynamically via data sources.
- **ECR**: one repository (`twenty-crm`) to store the application image.
- **EC2**: one `t3.small` Ubuntu instance, with a security group allowing SSH
  (22) and the app port (3000), using a pre-existing IAM instance profile
  (`EC2ECRPullRole`) for ECR pull access.
- **User data**: installs Docker + AWS CLI on first boot, authenticates to ECR,
  and retries pulling the app image every 30 seconds (up to 30 attempts) until
  it's available, then runs it.

## Project structure
terraform/task12/
├── providers.tf # AWS provider, region us-east-1
├── variables.tf # all configurable values
├── data.tf # default VPC/subnet lookup, no VPC created
├── ecr.tf # ECR repository
├── ec2.tf # security group + EC2 instance
├── user_data.sh.tpl # bootstrap script (Docker install, ECR auth, retry pull)
├── outputs.tf # ECR URL, EC2 IP, app URL, etc.
├── terraform.tfvars # key_name, ami_id (gitignored where sensitive)
└── README.md # this file


## Prerequisites

- Terraform >= 1.5, AWS CLI v2, Docker
- AWS credentials configured via `aws configure`
- An EC2 key pair (created via `aws ec2 create-key-pair` if none existed)

## Deployment steps actually run

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

```bash
docker build -t twenty-crm:latest .
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
docker tag twenty-crm:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

## Verification

- `terraform state list` — confirms all managed resources (VPC/subnet data
  sources, ECR repo, security group, EC2 instance).
- `aws ecr describe-repositories` / `aws ecr describe-images` — confirms the
  repo and pushed image.
- `aws ec2 describe-instances` — confirms the instance is `running`.
- `docker ps` on the instance and `curl -I http://<public-ip>:3000` returning
  `HTTP/1.1 200 OK` — confirms the app is live.

## Issues encountered

The provided IAM user (`vikash-yadav`) is a tightly scoped intern account.
Several standard actions Terraform performs by default were denied, requiring
workarounds:

| Denied action | Impact | Fix / workaround |
|---|---|---|
| `ec2:DescribeVpcAttribute` | `data "aws_vpc"` failed on lookup | Switched to `data "aws_vpcs"` (plural), which only needs `DescribeVpcs` |
| `ec2:CreateTags` | Any resource with a `tags = {}` block failed to create | Removed all `tags` blocks from every resource |
| `iam:CreateRole` | Couldn't create a role/instance profile for ECR pull access | Reused a pre-existing instance profile (`EC2ECRPullRole`) via a `data` source instead of creating one |
| `ecr:PutLifecyclePolicy` | ECR lifecycle policy resource failed | Removed the lifecycle policy resource (not required by the task) |
| `ec2:RunInstances` restricted to specific `instance_type` | Instance launch denied for `t3.medium`/`t2.micro` | Found the one instance type used elsewhere in the account (`t3.small`) via `describe-instances` and used that |
| `ec2:RunInstances` restricted to a specific AMI | Instance launch denied for a dynamically-resolved Ubuntu AMI | Found the account's approved AMI ID via existing instances and hardcoded it as a variable, instead of a dynamic `aws_ami` lookup |
| `ec2:DescribeInstanceAttribute` | Terraform's post-create read (and every subsequent `terraform plan`) failed | Used `-refresh=false` on `plan`/`apply`/`destroy`; this was later resolved by the account admin |
| `ec2:ModifyInstanceAttribute` | Explicitly setting `instance_initiated_shutdown_behavior` triggered a separate denied API call and forced a resource replacement | Removed the explicit attribute from config; left it at its default |
| `ecr:GetAuthorizationToken` | Couldn't `docker login` to ECR at all, from the CLI, from either the local machine or the EC2 instance's role | Escalated to account admin; resolved once the permission was actually attached (initial "already fixed" reports were inaccurate — verified with a plain `aws ecr get-login-password` before/after) |

**Docker image / app-runtime issue**: the Task 5 Dockerfile in this repo builds
a Twenty SDK *dev-sync* tool (`yarn twenty dev`), not the Twenty CRM
application server itself — its entrypoint waits on a `$TWENTY_URL` pointing
at an already-running Twenty instance, so it can never fully boot standalone
in this infrastructure-only task. Given the deadline, the automated user-data
retry-and-run flow (which correctly retried pulling the ECR image every 30s
until it timed out, proving requirement #12's retry logic works) was followed
by a **manual deployment on the EC2 instance using the official
`twentycrm/twenty:latest` image**, plus `postgres:16` and `redis:7` containers
on a shared Docker network, since Twenty CRM requires both a database and a
cache to start:

```bash
docker network create twenty-net
docker run -d --name twenty-db --network twenty-net -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=default postgres:16
docker run -d --name twenty-redis --network twenty-net redis:7
docker run -d --name twenty-crm --network twenty-net -p 3000:3000 \
  -e SERVER_URL=http://<public-ip>:3000 \
  -e APP_SECRET=<generated> \
  -e PG_DATABASE_URL=postgres://postgres:postgres@twenty-db:5432/default \
  -e REDIS_URL=redis://twenty-redis:6379 \
  twentycrm/twenty:latest
```

This ran migrations successfully and served `HTTP/1.1 200 OK` on port 3000.

**Disk space**: the instance's root volume filled up partway through pulling
the official Twenty image (on top of the earlier custom image); resolved with
`docker image prune -a` before retrying.

## Cleanup

```bash
terraform destroy -refresh=false
```

Followed by confirming via `aws ec2 describe-instances` and
`aws ecr describe-repositories` that all resources were removed.
DOCEOF
