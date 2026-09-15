# Task 15 — AWS Application Load Balancer with Terraform

## Objective

Deploy Twenty CRM on an AWS EC2 instance behind an Application Load Balancer (ALB) using Terraform, configure health checks and security groups, verify the application through the ALB, and destroy the created AWS resources after verification.

## AWS Configuration

- Region: `us-east-1`
- Instance Type: `t3.small`
- AMI: `ami-0b6d9d3d33ba97d99`
- VPC: Default VPC
- EC2 Subnet: Default VPC subnet
- Application Port: `3000`
- Load Balancer Port: `80`

## Terraform Resources

The following resources were provisioned using Terraform:

- Application Load Balancer
- ALB Security Group
- EC2 Security Group
- Target Group
- Target Group Attachment
- ALB Listener
- EC2 Instance

## Architecture

````text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
   |
   | Forward to Target Group
   | HTTP :3000
   v
EC2 Instance
   |
   +-- Twenty CRM :3000
   +-- PostgreSQL
   +-- Redis

## Security Groups

### ALB Security Group

Inbound HTTP traffic allowed on port 80 from `0.0.0.0/0`

Outbound traffic allowed

### EC2 Security Group

Inbound TCP traffic allowed on port 3000

Source restricted to the ALB Security Group

Outbound traffic allowed

This prevents direct public access to the Twenty CRM application port while allowing the ALB to communicate with the EC2 instance.

## Target Group

The Twenty CRM EC2 instance was registered with the target group on port 3000.

Health check configuration:

- Protocol: HTTP
- Path: `/`
- Port: Traffic Port (3000)
- Healthy threshold: 2
- Unhealthy threshold: 3
- Timeout: 5 seconds
- Interval: 30 seconds
- Success codes: 200-399

## ALB Listener

The ALB listener was configured as:

- Protocol: HTTP
- Port: 80
- Default action: Forward traffic to the Twenty CRM target group

## Twenty CRM Deployment

Terraform provisioned the EC2 instance and used EC2 user data to:

- Install Docker, AWS CLI and curl.
- Configure a 2 GB swap file.
- Start Docker.
- Pull the Twenty CRM Docker image.
- Create a Docker network.
- Start PostgreSQL.
- Start Redis.
- Wait for PostgreSQL and Redis to become ready.
- Start Twenty CRM on port 3000.
- Start the Twenty CRM worker.

## Terraform Commands

The following Terraform workflow was completed:

```text
terraform init
terraform validate
terraform plan
terraform apply

Terraform apply completed successfully with:

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The ALB, target group, listener and security groups had already been created successfully during the provisioning workflow.

## Verification

After deployment, the target group health was initially unhealthy while the EC2 bootstrap process was running.

After allowing the application to finish starting, the target became:

    State: healthy

Target:

    Instance ID: i-08f75ae13a4e63fb
    Port: 3000
    Health Check Port: 3000

## ALB Verification

The Twenty CRM application was successfully accessed through the Task 15 ALB.

ALB DNS:

    twenty-crm-t15-alb-10817067.us-east-1.elb.amazonaws.com

The application page successfully loaded through the ALB, confirming that:

    Internet → ALB :80 → Target Group → EC2 :3000 → Twenty CRM

A screenshot of the successful ALB access was captured as task evidence.

## Terraform Destroy

After successful verification, the Task 15 AWS resources were destroyed using:

    terraform destroy

The Task 15 Terraform-managed resources were successfully destroyed after verification.

## Result

Task 15 was successfully completed using Terraform.

- ALB configured
- Target Group configured
- EC2 registered
- Security Groups configured
- Health check configured
- Target verified as healthy
- Twenty CRM successfully accessed through ALB
- AWS resources destroyed after verification
````
