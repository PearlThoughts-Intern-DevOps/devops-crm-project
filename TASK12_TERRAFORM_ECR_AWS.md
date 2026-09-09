# Task 12: Terraform + AWS Infrastructure

## Objective

Use Terraform to provision the basic AWS infrastructure required for Twenty CRM and deploy the custom Docker image through Amazon ECR.

### Requirements covered

- Existing/default VPC
- EC2
- Amazon ECR
- AWS provider in `us-east-1`
- Terraform variables and outputs
- EC2 User Data automation
- Local Docker image build
- ECR authentication and image push
- EC2 ECR image pull
- Twenty CRM container startup
- Verification
- Final `terraform destroy`
- Git branch and PR submission

> **Security:** AWS credentials and Twenty API keys are intentionally excluded. Never commit credentials, API keys, Terraform state, or secrets to Git.

---

## Branch

```text
netaji-task12
```

---

## Project Structure

```text
terraform/
├── main.tf
├── variables.tf
├── iam.tf
├── data.tf
├── provider.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars.example
└── templates/
    └── user_data.sh.tpl
```

`.terraform/`, Terraform state files, and local `.tfvars` files are excluded through `.gitignore`.

---

## AWS Provider

The AWS provider is configured for:

```text
us-east-1
```

Example:

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS provider is constrained to `~> 6.0`.

---

## Existing VPC and Subnet

The task requires using the existing/default VPC rather than creating a new VPC.

Terraform discovers the default VPC:

```hcl
data "aws_vpc" "default" {
  default = true
}
```

The deployment used:

```text
VPC:    vpc-0c241509159132524
Subnet: subnet-078d52bfe579c74f2
```

The existing default security group was reused.

---

## Approved EC2 AMI

The internship account has restricted EC2 permissions. The mentor provided approved AMI IDs.

The approved Amazon Linux 2023 AMI used by this deployment is:

```text
ami-081b0a6eac00b4f53
```

The other mentor-provided AMI was Ubuntu, while the User Data uses `dnf`, so Amazon Linux 2023 was selected.

Terraform exposes the AMI through a variable:

```hcl
variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI ID for us-east-1"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}
```

The EC2 resource uses:

```hcl
ami = var.ami_id
```

---

## EC2 Configuration

The Terraform-created EC2 instance uses:

```text
Instance type: t3.small
AMI:           ami-081b0a6eac00b4f53
Key pair:      task7-netaji
Region:        us-east-1
Name:          netaji-twenty-crm
```

The existing IAM instance profile is:

```text
EC2ECRPullRole
```

No new IAM role is created because the internship account does not grant `iam:CreateRole`.

Terraform uses:

```hcl
data "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "EC2ECRPullRole"
}
```

and:

```hcl
iam_instance_profile = data.aws_iam_instance_profile.ec2_ecr_profile.name
```

This lets EC2 authenticate to ECR without storing AWS access keys on the server.

---

## Amazon ECR

Terraform creates:

```text
Repository: netaji-twenty-crm
```

Repository URL:

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/netaji-twenty-crm
```

The repository uses image scanning on push.

---

## Terraform Variables

Configurable values include:

```text
aws_region
instance_type
key_name
ecr_repository_name
environment
project_name
ami_id
image_tag
```

Example:

```hcl
aws_region          = "us-east-1"
instance_type       = "t3.small"
key_name            = "demo-value"
ecr_repository_name = "twenty-crm"
environment         = "dev"
project_name        = "twenty-crm"
```

The actual local `terraform.tfvars` is not committed.

---

## Terraform Outputs

Important outputs:

```text
vpc_id
subnet_id
ec2_instance_id
ec2_public_ip
ecr_repository_name
ecr_repository_url
ec2_iam_instance_profile
```

---

## Terraform Initialization and Validation

Executed successfully:

```bash
terraform init
terraform validate
```

Validation result:

```text
Success! The configuration is valid.
```

---

## Terraform Plan

After switching to the mentor-approved AMI, the plan showed:

```text
AMI:           ami-081b0a6eac00b4f53
Instance type: t3.small
IAM profile:   EC2ECRPullRole
Key pair:      task7-netaji
```

The final plan was:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The ECR repository was already present in Terraform state.

---

## Terraform Apply

Executed:

```bash
terraform apply
```

Result:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Created EC2:

```text
Instance ID: i-05748c551da5f2385
Public IP:   44.204.208.155
```

ECR:

```text
netaji-twenty-crm
```

IAM profile:

```text
EC2ECRPullRole
```

---

## Initial EC2 Permission Issue

The first apply attempt failed because the internship IAM policy explicitly denied:

```text
ec2:RunInstances
```

The denial referenced the `DevOpsInternEC2Access` policy and the EBS volume resource.

The issue was not bypassed. The mentor provided approved AMI IDs, and Terraform was changed to use the approved Amazon Linux 2023 AMI.

After that change, EC2 creation succeeded.

---

## EC2 User Data

Terraform renders:

```text
templates/user_data.sh.tpl
```

The User Data automatically:

1. Updates packages.
2. Installs Docker.
3. Enables Docker.
4. Starts Docker.
5. Adds `ec2-user` to the Docker group.
6. Authenticates to ECR using the EC2 IAM instance profile.
7. Attempts to pull the ECR image.
8. Retries the image pull if it is unavailable.
9. Creates the Docker Compose configuration.
10. Pulls the Twenty CRM server image.
11. Starts the Twenty CRM server and custom ECR application container.

Retry configuration:

```bash
MAX_ATTEMPTS=30
DELAY_SECONDS=30
```

---

## ECR Authentication on EC2

The EC2 instance uses its IAM instance profile.

User Data performs ECR authentication without hard-coded credentials:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-registry>
```

AWS access keys are not stored in User Data.

---

## Local Docker Build

From the project root:

```bash
docker build -t netaji-twenty-crm:latest .
```

The image built successfully.

The local image was:

```text
netaji-twenty-crm:latest
```

---

## Tagging for ECR

The image was tagged:

```bash
docker tag netaji-twenty-crm:latest 579138738751.dkr.ecr.us-east-1.amazonaws.com/netaji-twenty-crm:latest
```

Both local tags referenced the same image ID.

---

## Local ECR Login

Executed:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 579138738751.dkr.ecr.us-east-1.amazonaws.com
```

Result:

```text
Login Succeeded
```

---

## Docker Image Push

Executed:

```bash
docker push 579138738751.dkr.ecr.us-east-1.amazonaws.com/netaji-twenty-crm:latest
```

Push completed successfully.

Image digest:

```text
sha256:927d6cf2555e990e9681cef4a835fda2fe1cfc96e3edd914131f0075e3462deb
```

The image was visible in the ECR repository.

---

## EC2 User Data Race Condition

The EC2 instance booted before the local image was pushed.

The User Data retry loop initially received:

```text
manifest unknown: Requested image not found
```

for attempts 1 through 30.

The script eventually logged that the image was unavailable.

This was caused by the deployment order:

```text
Terraform creates EC2
        ↓
EC2 User Data starts
        ↓
Image not yet in ECR
        ↓
Local Docker build/push
```

The retry mechanism was included specifically to handle this race condition.

---

## EC2 ECR Pull Verification

After the image was pushed, EC2 successfully executed:

```bash
sudo docker pull 579138738751.dkr.ecr.us-east-1.amazonaws.com/netaji-twenty-crm:latest
```

Result:

```text
Status: Downloaded newer image
```

The digest matched:

```text
sha256:927d6cf2555e990e9681cef4a835fda2fe1cfc96e3edd914131f0075e3462deb
```

This verified:

```text
EC2 → IAM instance profile → ECR → Docker image
```

---

## Terraform User Data Verification

The actual EC2 User Data script was located at:

```text
/var/lib/cloud/instance/scripts/part-001
```

For verification, the Terraform-generated script was rerun after the ECR image became available:

```bash
sudo bash /var/lib/cloud/instance/scripts/part-001
```

It successfully:

```text
Pulled the Twenty server image
Created Docker volumes
Created Docker network
Created twenty-crm-server
Created devops-crm-app
Started twenty-crm-server
Started devops-crm-app
```

The bootstrap completed successfully.

---

## Docker Container Verification

Executed on EC2:

```bash
sudo docker ps
```

The result showed:

```text
devops-crm-app       Up
twenty-crm-server    Up
```

Twenty CRM server port:

```text
0.0.0.0:2020 -> 2020/tcp
```

Custom application image:

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/netaji-twenty-crm:latest
```

---

## Twenty CRM Architecture

The custom Docker image runs:

```text
yarn twenty dev
```

It is a CLI-driven application and does not provide the standalone Twenty CRM HTTP server.

Therefore the EC2 deployment runs:

```text
twenty-crm-server
        |
        | Twenty CRM server
        |
devops-crm-app
        |
        | Custom ECR image
        | CLI-driven application
```

The application container uses:

```yaml
network_mode: "service:twenty"
```

This allows it to share the network namespace of the Twenty server container.

---

## Twenty CRM Logs

The Twenty server logs showed successful initialization of application modules and database configuration loading.

The logs reached:

```text
==> DONE
==> START Running upgrade
```

No severe database checkpoint failure was observed in the inspected logs.

An immediate health request initially returned:

```text
curl: (56) Recv failure: Connection reset by peer
```

The container logs indicated that the application was still completing initialization/upgrade work. Final readiness verification should be performed after startup has fully completed.

---

## CLI Authentication

The custom application requires one-time Twenty CLI authentication.

The expected command is:

```bash
docker compose exec app yarn twenty remote:add   --url http://localhost:2020   --api-key '<key>'
```

The real API key must be entered privately and must never be committed or included in documentation, screenshots, or Loom recordings.

---

## Security

The implementation follows these practices:

- No AWS access keys in Terraform.
- No AWS access keys in User Data.
- EC2 uses an IAM instance profile for ECR.
- Existing `EC2ECRPullRole` is reused.
- No Twenty API key is stored in source code.
- Local `terraform.tfvars` is ignored.
- `.terraform/` is ignored.
- Terraform state files are ignored.
- Secrets must not appear in screenshots or Loom recordings.

---

## Verification Checklist

| Requirement | Status |
|---|---|
| Terraform init | Completed |
| Terraform validate | Completed |
| Terraform plan | Completed |
| ECR repository | Created |
| EC2 | Created |
| Approved AMI | `ami-081b0a6eac00b4f53` |
| Instance type | `t3.small` |
| Existing/default VPC | Used |
| Existing subnet | Used |
| Existing ECR IAM profile | Used |
| Docker image build | Completed |
| ECR authentication | Completed |
| ECR image push | Completed |
| EC2 ECR image pull | Completed |
| Terraform User Data execution | Completed |
| Twenty server container | Running |
| Custom ECR app container | Running |
| HTTP health endpoint | Final readiness check pending |
| Twenty CLI authentication | One-time manual step |
| Terraform destroy | Pending final verification |

---

## Final Cleanup

After final application verification:

```bash
terraform destroy
```

Confirm:

```text
yes
```

Then verify:

```bash
terraform state list
```

The task-created EC2 and ECR resources should no longer be present.

If the ECR repository contains an image and `force_delete = false`, the image may need to be removed before destroying the repository.

---

## Git Submission

Before committing:

```bash
git status
```

Check that no secrets or local Terraform files are tracked:

```bash
git ls-files terraform/.terraform
```

Expected:

```text
(no output)
```

Then:

```bash
git add terraform/
git commit -m "Task12: Terraform AWS infrastructure and ECR deployment"
git push -u origin netaji-task12
```

Create the PR from:

```text
netaji-task12
```

---

## Loom Outline

Explain:

1. Task objective.
2. Terraform project structure.
3. AWS provider.
4. Existing/default VPC.
5. EC2 configuration.
6. Approved AMI.
7. Existing ECR IAM instance profile.
8. ECR repository.
9. Variables and outputs.
10. User Data automation.
11. Docker installation.
12. ECR authentication.
13. ECR retry logic.
14. Local Docker build.
15. Image tagging and push.
16. EC2 image pull.
17. Docker container verification.
18. Issues and solutions.
19. Terraform destroy and cleanup.

The Loom must keep the face visible throughout the explanation.

---

## Issues and Solutions

### Issue 1: EC2 `RunInstances` denied

The internship IAM policy initially denied EC2 creation.

**Solution:** Use the mentor-approved AMI and `t3.small`.

### Issue 2: Dynamic AMI was not approved

The previous dynamic lookup selected:

```text
ami-0ac62d2d72afdce51
```

**Solution:** Use:

```text
ami-081b0a6eac00b4f53
```

### Issue 3: ECR image was unavailable during boot

EC2 launched before the image was pushed.

**Solution:** User Data contains a retry loop. The image was subsequently pushed and successfully pulled from EC2.

### Issue 4: Custom image is not the standalone Twenty server

The custom image runs the Twenty CLI.

**Solution:** Start the official Twenty server alongside the custom ECR image and use:

```yaml
network_mode: "service:twenty"
```

### Issue 5: Initial health request reset

The first health request occurred while Twenty was still initializing/upgrading.

**Solution:** Inspect container logs and perform the final health check after the application is fully ready.

---

## Final Result

The Task 12 deployment demonstrated:

```text
Terraform
   ↓
Existing AWS VPC
   ↓
EC2 t3.small
   ↓
EC2ECRPullRole
   ↓
Amazon ECR
   ↓
Custom Twenty CRM Docker image
   ↓
EC2 User Data
   ↓
Docker
   ↓
Twenty CRM server + custom application
```

Terraform successfully created the required infrastructure. The Docker image was built locally and pushed to ECR. The EC2 instance successfully authenticated to ECR using its IAM instance profile, pulled the image, and the Terraform-generated User Data successfully started the required containers.

The remaining operational steps are final Twenty readiness verification, `terraform destroy`, cleanup verification, Git commit/push, PR creation, and Loom submission.
