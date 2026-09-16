# Task 15: AWS Application Load Balancer

**Name:** P.Harish
**Date:** 15 September 2026
**PR link:** [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/353]
**Loom link:** [https://drive.google.com/file/d/1alaawjWzp3GH9vkLShPVc0ymmFnk7wah/view?usp=drive_link]

## Objective

Deploy Twenty CRM on AWS EC2 behind an Application Load Balancer (ALB) using Terraform.

## What Newly Done

- Created a reusable Terraform ALB module.
- Created an Application Load Balancer in the default VPC.
- Created an ALB security group to allow HTTP traffic on port 80.
- Created a target group for Twenty CRM on port 3000.
- Registered the EC2 instance with the target group.
- Created an HTTP listener on port 80.
- Configured the Twenty CRM `/healthz` health check.
- Updated the EC2 security group to allow port 3000 only from the ALB security group.
- Verified Twenty CRM through the ALB DNS.
- Removed unused S3 and ECR modules from the Task 15 configuration.

## Commands Used

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Check target health:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN>
```

Test the ALB:

```bash
curl -I http://<ALB_DNS_NAME>/healthz
```

## Issues and Solutions

### Issue 1: S3 and ECR were not required

**Problem:** The previous Terraform configuration contained S3 and ECR modules, but they were not required for Task 15.

**Solution:** Removed the S3 and ECR modules from the Task 15 Terraform configuration and kept a backup of the previous project directory.

### Issue 2: Terraform validation showed undeclared variables

**Problem:** Terraform showed warnings for:

- `iam_instance_profile`
- `ecr_repository_name`

These variables were still present in `terraform.tfvars` but were no longer declared in the root Terraform configuration.

**Solution:** Removed the unused variables from `terraform.tfvars`.

### Issue 3: ALB target was initially unhealthy

**Problem:** The EC2 target initially failed the ALB health check.

**Solution:** Configured Twenty CRM to run on port 3000 and configured the target group health check to use `/healthz`. The EC2 security group was also updated to allow port 3000 traffic from the ALB security group.

### Issue 4: Twenty CRM backend connection problem

**Problem:** The application initially showed a backend connection error because the `SERVER_URL` configuration was not correctly set for ALB access.

**Solution:** Configured the Twenty CRM `SERVER_URL` to use the ALB DNS name and recreated the application container. The application was then working successfully through the ALB.

## Verification

- Terraform configuration validated successfully.
- Terraform plan and apply completed successfully.
- ALB was created successfully.
- EC2 instance was registered with the target group.
- Target health check returned healthy.
- `/healthz` returned HTTP 200.
- Twenty CRM was accessible through the ALB DNS name.
- Verified the application in the browser through the ALB.

## Cleanup

After completing verification and the Loom recording, destroy the temporary AWS resources:

```bash
terraform destroy
```

Verify that the Terraform-managed resources have been removed:

```bash
terraform state list
```

The temporary EC2 and ALB resources should be destroyed after the task is completed.
