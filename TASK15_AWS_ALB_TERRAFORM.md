# Task 15 — AWS Application Load Balancer with Terraform

## Objective

Deploy the Twenty CRM application on AWS EC2 and expose it through an AWS Application Load Balancer (ALB) using Terraform.

## Architecture

```text
Internet
   |
   v
AWS Application Load Balancer :80
   |
   v
Target Group :3000
   |
   v
EC2 Instance :3000
   |
   v
Twenty CRM
```

## Work Completed

### Terraform Infrastructure

Created a standalone Terraform configuration under `terraform/` containing:

- `alb.tf`
- `ec2.tf`
- `network.tf`
- `outputs.tf`
- `security_groups.tf`
- `templates/user_data.sh.tpl`
- `terraform.tfvars`
- `variables.tf`
- `versions.tf`

The configuration provisions the default VPC/subnets, EC2 instance, security groups, Application Load Balancer, Target Group, Target Group attachment, and HTTP listener.

### EC2 and Twenty CRM

Configured an Amazon Linux 2023 `t3.small` EC2 instance in `us-east-1`. Terraform user data installs Docker and Docker Compose, generates the Twenty CRM encryption key, creates the application environment configuration, and starts Twenty CRM with PostgreSQL and Redis.

Twenty CRM listens on port `3000`.

### Application Load Balancer

Configured an internet-facing ALB with:

- HTTP listener on port `80`
- Target Group on port `3000`
- EC2 registered as the target
- HTTP health check on `/`
- Matcher `200-399`

The ALB forwards public HTTP requests to Twenty CRM on the EC2 instance.

### Security Groups

Configured separate ALB and EC2 security groups.

The ALB accepts HTTP traffic on port `80`. The EC2 security group allows port `3000` traffic from the ALB security group and allows outbound traffic.

### Terraform Workflow

The configuration was initialized, validated, planned, applied, verified, and cleaned up using:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Verification

After deployment, the EC2 instance, Twenty CRM service, ALB, Target Group registration, and health check were verified. The target became healthy and Twenty CRM was accessed through the ALB DNS name:

```text
http://<ALB-DNS-NAME>
```

### Cleanup

After verification, the temporary AWS resources were removed using:

```bash
terraform destroy
```

This prevented unnecessary ongoing AWS resource usage.

## Git Workflow

Work was completed on:

```text
netaji-task15
```

The Terraform configuration and documentation were committed and pushed to the repository, and the required Pull Request was prepared.

## Key Learning

This task covered Terraform-based AWS load balancing, ALB listeners, Target Groups, health checks, security-group traffic flow, EC2 application deployment, Docker-based application setup, Terraform resource dependencies, verification, and cleanup.
