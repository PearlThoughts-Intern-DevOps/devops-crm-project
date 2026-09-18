# Task 12: Terraform + AWS Infrastructure

## Objective

Extend the Terraform configuration prepared in Task 11, deploy the required
AWS infrastructure, push a Twenty CRM image to Amazon ECR, and automatically
run the image on Amazon EC2 through User Data.

Branch:

```text
chirag-task-12
```

AWS credentials use the normal AWS credential chain. No access keys, secret
keys, private keys, Terraform state, or local variable files are committed.

## Architecture

```text
Developer Mac
  |
  | Build linux/amd64 image and push it
  v
Amazon ECR
  |
  | Pull with temporary IAM role credentials
  v
EC2ECRPullRole instance profile
  |
  v
EC2 in existing default VPC and default subnet
  |
  +-- Amazon Linux 2023 x86_64
  +-- Docker
  +-- twenty-start.service
  `-- Twenty CRM container on TCP 2020
      +-- Web server and worker
      +-- PostgreSQL and Redis
      `-- Persistent Docker volumes

Security group
  +-- TCP 22 from administrator /32 CIDR
  +-- TCP 2020 from administrator /32 CIDR
  `-- Outbound TCP 443
```

The default VPC, subnet, EC2 key pair, and IAM profile already exist. Terraform
references them but does not create or destroy them.

## Project Structure

```text
.
|-- Readme-Task-12-Terraform-AWS-Infrastructure.md
`-- terraform/
    |-- .gitignore
    |-- .terraform.lock.hcl
    |-- Dockerfile.twenty
    |-- README.md
    |-- ec2.tf
    |-- ecr.tf
    |-- outputs.tf
    |-- provider.tf
    |-- terraform.tfvars.example
    |-- user-data.sh.tftpl
    |-- variables.tf
    |-- versions.tf
    `-- vpc.tf
```

`.terraform/`, `terraform.tfvars`, `*.tfstate*`, and `*.tfplan` are local or
generated files and are excluded by `terraform/.gitignore`.

## Terraform Resources and Configuration

Task 12 extends the existing Task 11 project instead of creating a new
Terraform project.

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and AWS provider constraints |
| `provider.tf` | AWS provider and region variable |
| `vpc.tf` | Existing default VPC and subnet lookups |
| `ec2.tf` | Security group, EC2, instance profile, and User Data |
| `ecr.tf` | Private ECR repository |
| `variables.tf` | Validated configuration inputs |
| `outputs.tf` | Resource IDs, addresses, and ECR URL |
| `Dockerfile.twenty` | Pinned Twenty CRM image definition |
| `user-data.sh.tftpl` | EC2 bootstrap and automatic deployment |

Task 12 added the `key_name` and `image_tag` inputs, attached
`EC2ECRPullRole`, rendered User Data with `templatefile()`, and enabled
`user_data_replace_on_change`.

Terraform manages:

- One EC2 instance and its encrypted root volume.
- One security group with separate ingress and egress rules.
- One private ECR repository.

## Default VPC and Subnet Reuse

`data.aws_vpc.default` selects the default VPC, and
`data.aws_subnet.selected` selects its default subnet in the configured
availability zone. They are data sources, so `terraform destroy` leaves both
unchanged.

## EC2 Configuration

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| AMI | Amazon Linux 2023 |
| Architecture | `x86_64` |
| Instance type | `t3.small` |
| Root disk | Encrypted 20 GiB `gp3` |
| Public address | Public IPv4 requested |
| Metadata | IMDSv2 required |
| SSH key | Existing key pair from `var.key_name` |
| Application port | TCP 2020 |
| Image tag | `task12-v1` |

The selected AMI was verified as available in `us-east-1` and compatible with
the `linux/amd64` container image.

## Security Group Configuration

| Direction | Protocol/port | Source or destination | Purpose |
| --- | --- | --- | --- |
| Inbound | TCP 22 | Configured administrator `/32` | SSH |
| Inbound | TCP 2020 | Configured administrator `/32` | Twenty CRM |
| Outbound | TCP 443 | `0.0.0.0/0` | Package and ECR access |

The administrator's address was obtained with:

```bash
curl -4 https://checkip.amazonaws.com
```

Both ingress CIDRs were updated when that public address changed.

## Existing EC2ECRPullRole Usage

EC2 authenticates through the existing instance profile:

```text
EC2 -> instance profile -> EC2ECRPullRole -> ECR read permissions
```

Terraform attaches it with:

```hcl
iam_instance_profile = "EC2ECRPullRole"
```

The profile was verified before deployment with `aws iam
get-instance-profile --instance-profile-name EC2ECRPullRole`.

The profile provides temporary credentials to EC2. User Data does not contain
static AWS credentials. Successful ECR login and image pulling supplied the
runtime permission check. The profile remains outside Terraform state, so
Terraform cleanup does not delete it.

## EC2 User Data Deployment Flow

Terraform renders `user-data.sh.tftpl` with the AWS region, ECR URL, image tag,
and application port.

```text
EC2 boots
  -> Install Docker and confirm the preinstalled AWS CLI
  -> Enable and start Docker
  -> Create restricted configuration and application secret
  -> Create persistent database and storage volumes
  -> Authenticate with ECR through EC2ECRPullRole
  -> Attempt docker pull
  -> If unavailable, wait 30 seconds and retry
  -> Read the EC2 public IP through IMDSv2
  -> Run Twenty CRM on port 2020
  -> Keep it available with systemd and Docker restart policies
```

Important implementation details:

| Component | Behavior |
| --- | --- |
| Dependencies | `dnf install -y docker openssl` |
| Application secret | Generated on EC2 with `openssl rand -hex 32` |
| Database volume | Mounted at `/data/postgres` |
| Storage volume | Mounted at `/app/packages/twenty-server/.local-storage` |
| Container | Named `twenty-crm` |
| Restart policy | `unless-stopped` |
| Boot service | `twenty-start.service` |

Troubleshooting logs:

```bash
sudo cat /var/log/cloud-init-output.log
sudo journalctl -u twenty-start.service --no-pager
```

## Terraform Variables and Outputs

Actual values are stored in ignored `terraform.tfvars`. The shared example
contains placeholders only.

| Variable | Purpose |
| --- | --- |
| `aws_region` | AWS region |
| `availability_zone` | Default subnet availability zone |
| `project_name`, `environment` | Names and tags |
| `ami_id`, `instance_type` | EC2 image and size |
| `root_volume_size` | Root disk size |
| `key_name` | Existing EC2 key pair |
| `ssh_allowed_cidr` | SSH source CIDR |
| `application_allowed_cidr` | Twenty CRM source CIDR |
| `application_port` | Published application port |
| `ecr_repository_name` | Task-specific repository name |
| `image_tag` | Image tag pulled by EC2 |

Outputs expose:

- Existing VPC and subnet IDs.
- EC2 instance ID, public IP, and public DNS.
- Security group ID.
- ECR repository URL.

## Terraform Workflow

Run Terraform from its directory:

```bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate
terraform plan -input=false
terraform apply
```

The initial plan showed:

```text
Plan: 6 to add, 0 to change, 0 to destroy.
```

The six additions were ECR, EC2, the security group, two ingress rules, and
one egress rule. The VPC and subnet appeared only as data sources.

Inspect the applied infrastructure with:

```bash
terraform output
terraform state list
```

Expected state entries:

```text
data.aws_subnet.selected
data.aws_vpc.default
aws_ecr_repository.twenty
aws_instance.twenty
aws_security_group.twenty
aws_vpc_security_group_egress_rule.https
aws_vpc_security_group_ingress_rule.application
aws_vpc_security_group_ingress_rule.ssh
```

After EC2 and ECR were deleted outside Terraform, a recovery apply recreated
them and updated both ingress CIDRs:

```text
Apply complete! Resources: 2 added, 2 changed, 0 destroyed.
```

## Docker Image Build for Linux/AMD64

The Mac Docker environment is ARM64, while the EC2 instance is x86_64.
Registry inspection confirmed that the pinned Twenty image supports both
architectures.

The repository root Dockerfile is an application-manifest installer, not the
CRM server. `terraform/Dockerfile.twenty` therefore derives from the existing
pinned Twenty development image, which includes the server, worker,
PostgreSQL, and Redis.

Build from the repository root:

```bash
docker build --platform linux/amd64 --file terraform/Dockerfile.twenty --tag twenty-crm:task12-v1 terraform
```

Verify:

```bash
docker image inspect twenty-crm:task12-v1 --format '{{.Os}}/{{.Architecture}}'
```

Observed result:

```text
linux/amd64
```

The pinned development image exposes port 2020, starts through `/init`, stores
PostgreSQL data in `/data/postgres`, and initializes the bundled services. It
is suitable for this lab but not presented as a production architecture.

## ECR Authentication, Tag, and Push

From the Terraform directory, obtain the repository address from Terraform:

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
ECR_REGISTRY=${ECR_URL%%/*}
```

Authenticate without placing a password in the command or repository:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"
```

Tag and push:

```bash
docker tag twenty-crm:task12-v1 "${ECR_URL}:task12-v1"
docker push "${ECR_URL}:task12-v1"
```

Successful image digest:

```text
sha256:b2807ef701316bd497caa8c4ee52205c51ecd905c013286d7d56109ba5783c86
```

The ECR repository uses immutable tags. A changed image requires a new tag or
deletion of the previous tag.

Verify the image:

```bash
ECR_REPOSITORY_NAME=$(basename "$(terraform output -raw ecr_repository_url)")
aws ecr describe-images --repository-name "$ECR_REPOSITORY_NAME" --region us-east-1 --query 'imageDetails[].{Tags:imageTags,Digest:imageDigest}' --output table --no-cli-pager
```

## EC2 Automatic Pull and Container Startup

EC2 can start before an image exists in ECR. In that state, ECR authentication
succeeds, `docker pull` returns `manifest unknown`, and the service waits 30
seconds before retrying.

After `task12-v1` was pushed, the service automatically:

1. Downloaded the image from ECR.
2. Confirmed the pushed digest.
3. Read the public IP through IMDSv2.
4. Started the `twenty-crm` container.
5. Published host port 2020 to container port 2020.

No manual container start was required.

## Deployment Verification

Connect using the private key for the configured key pair:

```bash
chmod 400 ~/Downloads/KEY_FILE.pem
ssh -i ~/Downloads/KEY_FILE.pem "ec2-user@$(terraform output -raw ec2_public_ip)"
```

On EC2:

```bash
sudo cloud-init status --long
sudo systemctl status twenty-start.service --no-pager
sudo journalctl -u twenty-start.service -n 30 --no-pager
sudo docker ps
sudo docker logs --tail 30 twenty-crm
curl -I http://localhost:2020
```

Observed results:

| Check | Result |
| --- | --- |
| Cloud-init | `status: done` |
| Systemd | `active (exited)`, `status=0/SUCCESS` |
| ECR pull | Successful; digest matched the pushed image |
| Container | `twenty-crm` running with `/init` |
| Port mapping | `0.0.0.0:2020->2020/tcp` |
| Application logs | Twenty jobs running and Redis persistence successful |
| Local HTTP | `HTTP/1.1 200 OK` |
| Browser | Twenty CRM loaded through `http://EC2_PUBLIC_IP:2020` |
| Reboot | Service and container started successfully after reboot |

This verified the complete path from Terraform and ECR through EC2, Docker,
the security group, and the Twenty web server.

## Important Issues and Solutions

| Issue | Cause | Solution |
| --- | --- | --- |
| AWS CLI unavailable on Mac | CLI was not installed | Installed with Homebrew, configured locally, and verified with STS |
| Docker unavailable on Mac | Colima socket did not exist | Started Colima and verified the Docker daemon |
| Root Dockerfile was unsuitable | It installs a custom app into an existing Twenty server | Used a pinned Twenty server image in `Dockerfile.twenty` |
| IAM design changed | Task assigner required the existing profile | Removed new IAM resources and attached `EC2ECRPullRole` |
| ECR name conflict | Repository `twenty-crm` already existed | Used `chirag-task-12-twenty-crm` and reapplied |
| EBS tag warning | IAM user lacked `ec2:CreateTags` for the volume | Kept the encrypted volume and documented the account restriction |
| First push targeted Docker Hub | zsh did not delimit `$ECR_URL` before the tag | Used `"${ECR_URL}:task12-v1"` |
| Image initially unavailable | EC2 started before the ECR push | The 30-second retry loop pulled it after upload |
| EC2 and ECR deleted externally | Resources were removed outside Terraform | Terraform detected drift and recreated them from retained state |
| Temporary CloudShell constraints | Required profile and disk capacity were unavailable | Verified the design there, then completed deployment in the original account |
| SSH access changed | Public IP/CIDR or key path needed correction | Refreshed both `/32` rules and used the matching protected key |

### User Data package failure

The first EC2 bootstrap failed while running:

```bash
dnf install -y docker awscli2 openssl
```

Amazon Linux 2023 returned `No match for argument: awscli2`. Because the User
Data script uses `set -euo pipefail`, that failed command stopped the script.
Docker was therefore not installed, `twenty-start.service` was not created,
and `cloud-init status --long` reported an error.

The selected Amazon Linux 2023 AMI already included AWS CLI v2, so the template
was corrected to:

```bash
dnf install -y docker openssl
aws --version
```

After the correction, cloud-init completed with `status: done`, the systemd
service pulled the image from ECR, and the `twenty-crm` container started
successfully. Keeping this fix in `user-data.sh.tftpl` ensures replacement EC2
instances use the corrected bootstrap automatically.

No credentials or private-key contents were added while resolving these
issues.

## Terraform Destroy and Cleanup

Cleanup is performed after all evidence is saved. Because ECR has
`force_delete = false`, delete its image before destroying the repository.

From the Terraform directory, save identifiers:

```bash
TASK12_INSTANCE_ID=$(terraform output -raw ec2_instance_id)
TASK12_SECURITY_GROUP_ID=$(terraform output -raw security_group_id)
TASK12_ECR_URL=$(terraform output -raw ecr_repository_url)
TASK12_ECR_NAME=${TASK12_ECR_URL##*/}
```

Delete the ECR image first because `force_delete = false`, then preview and
perform the Terraform cleanup:

```bash
aws ecr batch-delete-image --repository-name "$TASK12_ECR_NAME" --image-ids imageTag=task12-v1 --region us-east-1 --no-cli-pager
terraform plan -destroy
terraform destroy
```

The destroy plan must contain only Task 12 managed resources. It must not
delete the default VPC, subnet, existing key pair, or `EC2ECRPullRole`.

Both Terraform commands are necessary: `terraform plan -destroy` provides a
reviewable preview, while `terraform destroy` performs the approved deletion.
The completed destroy plan reported:

```text
Plan: 0 to add, 0 to change, 6 to destroy.
```

It included the EC2 instance, ECR repository, security group, two ingress
rules, and HTTPS egress rule. Destruction then completed successfully:

```text
Destroy complete! Resources: 6 destroyed.
```

Verify cleanup:

```bash
terraform state list
aws ec2 describe-instances --instance-ids "$TASK12_INSTANCE_ID" --region us-east-1 --query 'Reservations[].Instances[].State.Name' --output text --no-cli-pager
aws ecr describe-repositories --repository-names "$TASK12_ECR_NAME" --region us-east-1 --no-cli-pager
aws ec2 describe-security-groups --group-ids "$TASK12_SECURITY_GROUP_ID" --region us-east-1 --no-cli-pager
```

Observed cleanup results:

- `terraform state list` returned no entries.
- EC2 instance `i-01dd4476cf7ae1438` reported `terminated`.
- ECR returned `RepositoryNotFoundException`.
- The security group returned `InvalidGroup.NotFound`.
- The existing `EC2ECRPullRole` instance profile remained available.
- The reused VPC and subnet both reported `available`.

Cleanup status: complete for the Terraform-managed Task 12 resources in the
deployment account. Manually created playground resources remain outside this
Terraform state and require separate cleanup when applicable.

## Git Workflow

Review ignored and changed files:

```bash
git status
git diff
git check-ignore terraform/terraform.tfvars
git check-ignore terraform/terraform.tfstate
```

Stage only Task 12 source and documentation:

```bash
git add terraform/ec2.tf terraform/variables.tf terraform/Dockerfile.twenty terraform/user-data.sh.tftpl terraform/terraform.tfvars.example Readme-Task-12-Terraform-AWS-Infrastructure.md
git status
git diff --cached
```

Commit and push:

```bash
git commit -m "Complete Task 12 Terraform AWS infrastructure deployment"
git push -u origin chirag-task-12
```

Create a pull request from `chirag-task-12` to the required base branch. Add
the commit hash and PR link after creation.

## Evidence Checklist and Current Status

- [x] Terraform formatting and validation
- [x] Terraform plan, apply, outputs, and state
- [x] Default VPC and subnet reuse
- [x] EC2, security group, and existing IAM profile
- [x] ECR repository and `task12-v1` image
- [x] Local `linux/amd64` image
- [x] Cloud-init and systemd service
- [x] Automatic ECR pull and running container
- [x] HTTP 200 and browser verification
- [x] Successful startup after reboot
- [x] Terraform destroy plan and destroy
- [x] AWS cleanup verification
- [ ] Git commit, push, and pull request

Infrastructure creation, image delivery, automatic deployment, restart
behavior, application access, Terraform destroy, and AWS cleanup are complete
and verified. Git commit, push, and pull request remain pending.
