# Task 12: Terraform + AWS Infrastructure

## Objective

Provision the basic AWS infrastructure required for Twenty CRM using Terraform and deploy the Twenty CRM Docker image through Amazon ECR.

The Terraform configuration provisions:

- Existing/default AWS VPC
- Existing/default subnet
- EC2 instance
- Security Group
- Amazon ECR repository
- EC2 User Data for Docker and ECR deployment

No new IAM role is created. The existing EC2 instance profile `EC2ECRPullRole` is used for ECR access.

## 1. Terraform Project Structure

```text
terraform/task12/
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── terraform.tfvars
├── .gitignore
└── .terraform.lock.hcl
```

| File | Purpose |
|---|---|
| `main.tf` | AWS provider, default VPC/subnet lookup, ECR, Security Group, EC2 and SSH key resources |
| `variables.tf` | Terraform input variables |
| `outputs.tf` | Infrastructure outputs |
| `user_data.sh` | EC2 initialization and Twenty CRM deployment |
| `terraform.tfvars` | Environment-specific values |
| `.gitignore` | Prevents Terraform state, variables and private keys from being committed |
| `.terraform.lock.hcl` | Locks Terraform provider versions |

## 2. AWS Provider

The AWS provider is configured for `us-east-1`.

Terraform also uses the TLS and Local providers to generate and save an EC2 SSH key pair.

## 3. Existing VPC and Subnet

A new VPC is not created.

Default VPC:

```text
vpc-0c241509159132524
```

Default subnet:

```text
subnet-078d52bfe579c74f2
```

## 4. EC2 Instance

Terraform provisions the Twenty CRM EC2 instance with:

```text
Instance type: t3.small
AMI: Ubuntu
Public IP: 44.193.197.189
Instance ID: i-06ca7998229d3e703
```

The instance uses the existing IAM instance profile:

```text
EC2ECRPullRole
```

Terraform does not create a new IAM role.

Security Group:

```text
SSH:        TCP 22
Twenty CRM: TCP 8080
Outbound:   All traffic
```

Terraform also generates an SSH key pair named `task12-key`. The private key is excluded from Git using `.gitignore`.

## 5. Amazon ECR

Terraform provisions:

```text
Repository: prabhas-task-13-ecr-image
```

Repository URL:

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/prabhas-task-13-ecr-image
```

Image scanning on push is enabled.

Deployed image:

```text
v2.38.1
```

> Note: The repository name was retained as `prabhas-task-13-ecr-image` because an existing repository/image was already present and the AWS user did not have permission to delete its images. Renaming the repository would have required deleting the existing image first.

## 6. Terraform Variables

The main configurable variables are:

```text
aws_region
ami_id
instance_type
ecr_repository_name
image_tag
ssh_allowed_cidr
```

Example:

```hcl
aws_region          = "us-east-1"
instance_type       = "t3.small"
ecr_repository_name = "prabhas-task-13-ecr-image"
image_tag           = "v2.38.1"
ssh_allowed_cidr    = "0.0.0.0/0"
```

## 7. Existing IAM Instance Profile

The EC2 instance uses:

```hcl
iam_instance_profile = "EC2ECRPullRole"
```

No IAM role is created by Terraform.

The existing instance profile provides the permissions required for EC2 to authenticate to Amazon ECR and pull the Docker image.

## 8. EC2 User Data

The EC2 User Data:

1. Updates the Ubuntu package index.
2. Installs Docker and required dependencies.
3. Installs/configures the AWS CLI.
4. Authenticates to Amazon ECR using the EC2 instance role.
5. Attempts to pull the Twenty CRM image from ECR.
6. Retries the image pull periodically if it is not yet available.
7. Starts the Twenty CRM Docker container.
8. Maps EC2 port `8080` to the Twenty application port `2020`.

Container:

```text
twenty-server
```

Port mapping:

```text
EC2 8080 → Container 2020
```

## 9. Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## 10. ECR Image Deployment

The Twenty CRM image was authenticated and pushed to Amazon ECR.

```text
579138738751.dkr.ecr.us-east-1.amazonaws.com/prabhas-task-13-ecr-image:v2.38.1
```

The EC2 instance then authenticated to ECR using its existing IAM instance profile and successfully pulled the image.

## 11. Deployment Verification

Infrastructure:

```text
Instance ID:
i-06ca7998229d3e703

Public IP:
44.193.197.189

Subnet:
subnet-078d52bfe579c74f2

VPC:
vpc-0c241509159132524

Security Group:
sg-02d31f1d50b238e65

IAM Instance Profile:
EC2ECRPullRole
```

Docker verification:

```bash
sudo docker ps
```

The Twenty CRM container was running with:

```text
0.0.0.0:8080->2020/tcp
```

Health verification:

```bash
curl -I http://localhost:8080
```

Result:

```text
HTTP/1.1 200 OK
```

The Twenty CRM dashboard was successfully accessed through:

```text
http://44.193.197.189:8080
```

## 12. Troubleshooting

During verification, the `t3.small` instance experienced high memory pressure.

Initial memory:

```text
RAM: 1.9 GiB
Swap: 0
```

The Twenty CRM container was using approximately:

```text
994 MiB RAM
```

Application logs also showed event-loop stalls.

As a temporary troubleshooting measure, 2 GiB of swap was manually added to the EC2 instance.

After enabling swap, the application responded successfully with:

```text
HTTP/1.1 200 OK
```

and the Twenty CRM dashboard became accessible.

The manual swap configuration was intentionally not added to Terraform User Data because swap was not part of the required Task 12 infrastructure specification.

## 13. Verification Summary

| Component | Status |
|---|---|
| Terraform initialization | PASS |
| Terraform validation | PASS |
| Terraform plan | PASS |
| Terraform apply | PASS |
| Default VPC | PASS |
| Default subnet | PASS |
| EC2 | PASS |
| Existing `EC2ECRPullRole` | PASS |
| Security Group | PASS |
| ECR repository | PASS |
| Docker installation | PASS |
| ECR authentication | PASS |
| ECR image pull | PASS |
| Twenty CRM container | PASS |
| Health endpoint | HTTP 200 |
| Twenty CRM dashboard | PASS |

## 14. Cleanup

After deployment verification and evidence collection:

```bash
terraform destroy
```

Cleanup should be verified using:

```bash
terraform show
```

and AWS CLI/resource checks.

> The ECR repository contains the pushed image. If AWS permissions prevent deletion of the ECR image/repository, the remaining resource should be reported as a permission-related cleanup limitation.

## 15. Evidence

Evidence captured:

1. Twenty CRM dashboard
2. Docker container and HTTP health check
3. EC2 instance details
4. ECR image
5. Terraform outputs

These demonstrate:

```text
Terraform
   ↓
AWS Infrastructure
   ↓
Amazon ECR
   ↓
EC2 + Existing IAM Instance Profile
   ↓
Docker
   ↓
Twenty CRM
   ↓
Working CRM Dashboard
```

## 16. Final Result

Twenty CRM was successfully provisioned and deployed using Terraform and Amazon ECR.

Application URL:

```text
http://44.193.197.189:8080
```

The deployment successfully demonstrated:

```text
Terraform
   ↓
AWS Infrastructure
   ↓
Amazon ECR
   ↓
EC2 + Existing IAM Instance Profile
   ↓
Docker
   ↓
Twenty CRM
   ↓
Working CRM Dashboard
```
:wq

