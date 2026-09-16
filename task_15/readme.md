# Task 15 - Deploy Twenty CRM Behind AWS Application Load Balancer Using Terraform

## 1. Objective

The objective of this task was to deploy **Twenty CRM** on an AWS EC2 instance and expose the application through an **AWS Application Load Balancer (ALB)** using Terraform.

The infrastructure had to be provisioned and configured using Terraform, including:

* EC2 instance
* Security groups
* Application Load Balancer
* ALB target group
* ALB listener
* Target group attachment
* Twenty CRM application deployment
* ALB health checks

After deployment, the application and ALB target health were verified successfully. Once verification was completed, all resources created for the task were destroyed using Terraform.

---

# 2. AWS Configuration

The following AWS configuration was used for the task:

| Configuration        | Value                      |
| -------------------- | -------------------------- |
| AWS Region           | `us-east-1`                |
| VPC                  | Existing Default VPC       |
| EC2 Instance Type    | `t3.small`                 |
| Operating System     | Amazon Linux 2023          |
| Application          | Twenty CRM                 |
| Twenty CRM Port      | `3000`                     |
| ALB Type             | Application Load Balancer  |
| ALB Listener         | HTTP                       |
| Listener Port        | `80`                       |
| Target Group Port    | `3000`                     |
| Target Protocol      | HTTP                       |
| Health Check Path    | `/`                        |
| Health Check Matcher | `200-399`                  |
| Docker Image         | `twentycrm/twenty:v2.35.0` |

---

# 3. Architecture

The final application flow was:

```text
                    Internet
                       |
                       | HTTP :80
                       v
          +---------------------------+
          |   Application Load        |
          |       Balancer            |
          |                           |
          |   ALB Security Group      |
          +-------------+-------------+
                        |
                        | HTTP :3000
                        v
          +---------------------------+
          |       EC2 Instance        |
          |                           |
          |     EC2 Security Group   |
          |                           |
          |   +-------------------+   |
          |   |    Twenty CRM     |   |
          |   |      :3000        |   |
          |   +-------------------+   |
          |                           |
          |   +-------------------+   |
          |   |    PostgreSQL     |   |
          |   +-------------------+   |
          |                           |
          |   +-------------------+   |
          |   |      Redis        |   |
          |   +-------------------+   |
          +---------------------------+
```

The ALB accepts HTTP traffic from the internet on port `80` and forwards requests to the EC2 instance on port `3000`.

The EC2 security group does not allow public access to port `3000`. Instead, port `3000` is allowed only from the ALB security group.

---

# 4. Terraform Project Structure

The Task 15 Terraform configuration was organized using reusable modules.

```text
task_15/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── user_data.sh
├── .gitignore
├── .terraform.lock.hcl
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── alb/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Unnecessary modules from the previous task were removed before implementing Task 15.

---

# 5. EC2 Module

The EC2 module was used to create the instance running Twenty CRM.

The module accepts variables for:

* AMI ID
* Instance type
* Subnet
* Key pair
* Security group
* User data
* Twenty CRM Docker image
* Project name
* Environment

The EC2 instance was configured with:

```text
AMI: Approved Amazon Linux 2023 AMI
Instance Type: t3.small
Subnet: Default VPC subnet
Public IP: Enabled
```

The EC2 instance was also associated with the dedicated EC2 security group.

---

# 6. Twenty CRM Deployment

Docker was installed on the EC2 instance using the Terraform-managed `user_data.sh` script.

Twenty CRM was deployed using:

```text
twentycrm/twenty:v2.35.0
```

The application listens on:

```text
3000
```

The deployment also required supporting services:

* PostgreSQL
* Redis

These services were connected to Twenty CRM through a Docker network.

The application was configured using environment variables including:

```text
PG_DATABASE_URL
REDIS_URL
ENCRYPTION_KEY
```

The encryption key was generated during instance setup rather than being hardcoded into Terraform configuration.

---

# 7. Security Groups

Two security groups were created.

## 7.1 ALB Security Group

The ALB security group allows HTTP traffic from the internet.

```text
Inbound:
TCP 80
Source: 0.0.0.0/0
```

Outbound traffic was allowed so that the ALB could communicate with the EC2 target.

---

## 7.2 EC2 Security Group

The EC2 security group allows Twenty CRM traffic only from the ALB security group.

```text
Inbound:
TCP 3000
Source: ALB Security Group
```

This prevents users from directly accessing the application through the EC2 instance's port `3000`.

A temporary SSH rule was also used during troubleshooting to allow administrative access to the EC2 instance.

---

# 8. Application Load Balancer

A dedicated Application Load Balancer was created using Terraform.

The ALB was configured as:

```text
Type: Application
Scheme: Internet-facing
Protocol: HTTP
Port: 80
```

The ALB was attached to the default VPC subnets.

The ALB received requests from the internet and forwarded them to the Twenty CRM target group.

---

# 9. Target Group

A target group was created for the Twenty CRM EC2 instance.

Configuration:

```text
Target Type: Instance
Protocol: HTTP
Port: 3000
VPC: Default VPC
```

The EC2 instance was registered with the target group using Terraform.

The target group attachment was configured to forward traffic to port `3000`.

---

# 10. ALB Listener

An HTTP listener was created on port `80`.

The listener forwards incoming requests to the Twenty CRM target group.

The traffic flow is:

```text
Client
  |
  | HTTP :80
  v
ALB
  |
  | Forward
  v
Target Group
  |
  | HTTP :3000
  v
EC2 / Twenty CRM
```

---

# 11. Health Check Configuration

The target group's health check was configured as:

```text
Protocol: HTTP
Path: /
Port: traffic-port
Healthy Threshold: 2
Unhealthy Threshold: 3
Timeout: 5 seconds
Interval: 30 seconds
Success Codes: 200-399
```

The health check verifies that Twenty CRM is responding correctly on port `3000`.

Once the application was running correctly, the target changed from:

```text
unhealthy
```

to:

```text
healthy
```

---

# 12. Terraform Deployment

The following Terraform commands were used during deployment.

## Initialize Terraform

```bash
terraform init
```

Terraform initialized the AWS provider and module configuration successfully.

## Validate Configuration

```bash
terraform validate
```

The Terraform configuration passed validation successfully.

## Create Execution Plan

```bash
terraform plan
```

The plan was reviewed before applying the infrastructure.

## Apply Infrastructure

```bash
terraform apply
```

The infrastructure was successfully provisioned.

The deployment created the required:

* Security groups
* EC2 instance
* Application Load Balancer
* Target group
* Target attachment
* ALB listener

---

# 13. Issues Faced During the Task

## Issue 1 - EC2 Key Pair Not Found

### Problem

The initial Terraform deployment failed while creating the EC2 instance because the configured key pair did not exist in AWS.

The error indicated that the specified key pair could not be found.

### Resolution

Available AWS key pairs were checked and the correct existing key pair was selected:

```text
Abhi-Task-15
```

The `terraform.tfvars` file was updated accordingly.

After updating the key pair, Terraform was executed again and the EC2 instance was created successfully.

---


# 14. Issue 2 - Port 3000 Was Not Visible Using `ss`

### Problem

The following command did not return a listener:

```bash
docker exec twenty-crm sh -c 'ss -lntp 2>/dev/null | grep 3000 || true'
```

Initially this suggested that Twenty CRM might not be listening on port `3000`.

### Investigation

The application was tested directly from the EC2 host:

```bash
curl -v http://127.0.0.1:3000
```

The request returned the Twenty CRM frontend HTML, including:

```html
<noscript>You need to enable JavaScript to run this app.</noscript>
<div id="root"></div>
```

### Resolution

The successful HTTP response confirmed that Twenty CRM was actually reachable on port `3000`.

Therefore, the missing `ss` output was not treated as an application failure.

---

# 15. Issue 3 - AWS CLI Credentials Used the Wrong Account

### Problem

When attempting to check ALB target health using AWS CLI, the following error occurred:

```text
The target group ARN is not a valid target group ARN
```

The Terraform output showed resources belonging to account:

```text
579138738751
```

However, the AWS CLI was authenticated to:

```text
336457597463
```

### Root Cause

The AWS CLI profiles were using credentials for a different AWS account.

Both existing profiles, `default` and `configs`, returned account:

```text
336457597463
```

### Resolution

A new AWS CLI profile named `task15` was created using the correct access credentials.

The account was verified with:

```bash
aws sts get-caller-identity --profile task15
```

The result confirmed:

```text
Account: 579138738751
User: abhi-kadam
```

The ALB health check could then be performed successfully using the `task15` profile.

---

# 16. Target Health Verification

The target health was checked using:

```bash
aws elbv2 describe-target-health \
  --profile task15 \
  --target-group-arn "$(terraform output -raw target_group_arn)" \
  --region us-east-1 \
  --query "TargetHealthDescriptions[].TargetHealth.State"
```

The final result was:

```text
[
    "healthy"
]
```

This confirmed that the EC2 instance was successfully registered with the ALB target group and that the ALB health check was passing.

---

# 17. ALB Connectivity Verification

The ALB URL was obtained from Terraform:

```bash
terraform output -raw alb_url
```

The application was tested through the ALB using:

```bash
curl -I "$(terraform output -raw alb_url)"
```

The response was:

```text
HTTP/1.1 200 OK
```

The ALB was also tested directly using its DNS name:

```bash
curl -I http://abhi-task-15-alb-1862833729.us-east-1.elb.amazonaws.com
```

The response was:

```text
HTTP/1.1 200 OK
```

The response confirmed that traffic was successfully flowing through:

```text
Internet
   ↓
Application Load Balancer :80
   ↓
Target Group :3000
   ↓
EC2 Instance
   ↓
Twenty CRM
```

---

# 18. Successful Verification

The following requirements were successfully verified:

* [x] EC2 instance created using Terraform
* [x] Twenty CRM deployed using Docker
* [x] PostgreSQL configured for Twenty CRM
* [x] Redis configured for Twenty CRM
* [x] Application Load Balancer created
* [x] Target group created
* [x] EC2 registered with target group
* [x] HTTP listener configured on port `80`
* [x] ALB security group configured
* [x] EC2 security group configured
* [x] Twenty CRM health check configured
* [x] Target reported as `healthy`
* [x] Twenty CRM returned HTTP `200 OK` through ALB
* [x] Application successfully accessed through ALB

---

# 19. Important Terraform Outputs

The deployment produced the following important outputs:

```text
EC2 Instance ID:
i-05a0df5b29fc8ab5f

EC2 Public IP:
13.218.189.56

ALB DNS:
abhi-task-15-alb-1862833729.us-east-1.elb.amazonaws.com

ALB URL:
http://abhi-task-15-alb-1862833729.us-east-1.elb.amazonaws.com
```

These values were generated by Terraform and exposed through Terraform outputs for verification.

---

# 20. Cleanup

After successfully verifying the ALB, target health, and Twenty CRM accessibility, the infrastructure was removed as required by the task.

The following command was used:

```bash
terraform destroy
```

The destroy plan was reviewed before confirming the operation.

Terraform then removed the resources created for Task 15, including:

* EC2 instance
* Application Load Balancer
* Target group
* Target group attachment
* ALB listener
* ALB security group
* EC2 security group

This ensured that no unnecessary AWS resources remained after task completion.

---

# 21. Final Result

The Task 15 implementation successfully deployed Twenty CRM behind an AWS Application Load Balancer using Terraform.

The ALB accepted HTTP requests on port `80` and forwarded them to the Twenty CRM EC2 instance on port `3000`. The target group health check successfully identified the EC2 instance as healthy, and the ALB returned an HTTP `200 OK` response from Twenty CRM.

The main deployment issues involving the EC2 key pair, missing PostgreSQL/Redis dependencies, missing encryption key, application startup delay, and AWS CLI account mismatch were identified and resolved.

After verification, all infrastructure was destroyed using Terraform as required.

## Conclusion

This task demonstrated the complete Terraform-based deployment and verification of a containerized application behind an AWS Application Load Balancer, including infrastructure provisioning, security group configuration, target health monitoring, application troubleshooting, connectivity validation, and resource cleanup.

