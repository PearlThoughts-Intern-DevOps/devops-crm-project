# Task 15: AWS Application Load Balancer (ALB) with Terraform

## Overview

This task provisions and deploys Twenty CRM on an AWS EC2 instance
behind an Application Load Balancer (ALB) using Terraform.

The infrastructure is deployed in the AWS `us-east-1` region using the
default VPC and a `t3.small` EC2 instance.

### Architecture

``` text
                    Internet
                       |
                       | HTTP :80
                       v
          +--------------------------+
          | Application Load         |
          | Balancer (ALB)           |
          | task15-twenty-prabhas-alb|
          +------------+-------------+
                       |
                       | Forward :8080
                       v
          +--------------------------+
          | Target Group             |
          | task15-twenty-prabhas-tg |
          | Health: /api/health      |
          +------------+-------------+
                       |
                       | HTTP :8080
                       v
          +--------------------------+
          | EC2 - t3.small            |
          | Twenty CRM                |
          | Docker :8080 -> :3000    |
          +--------------------------+
                 |             |
                 v             v
          PostgreSQL          Redis
```

## Requirements

-   AWS region: `us-east-1`
-   EC2 instance type: `t3.small`
-   Ubuntu AMI configured through Terraform
-   Default VPC
-   Application Load Balancer
-   Target Group
-   HTTP listener on port `80`
-   Twenty CRM exposed internally on port `8080`
-   ALB health check on `/api/health`
-   Terraform used for provisioning
-   Terraform destroy performed after verification

## Terraform Structure

``` text
terraform/task15/
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── terraform.tfvars
├── terraform.tfvars.example
├── .gitignore
└── task15-prabhas-key.pem        # generated locally; must not be committed
```

## Terraform Providers

The configuration uses:

-   AWS provider
-   TLS provider
-   Local provider
-   Random provider

The TLS provider creates the EC2 SSH key pair and the local provider
writes the private key locally with restrictive permissions.

The Random provider generates the Twenty CRM encryption key during
Terraform deployment.

## Resources

### Default VPC and Subnet

Terraform discovers the default VPC and its subnets:

``` hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

### SSH Key Pair

Terraform generates an RSA 4096-bit private key using the TLS provider
and creates an AWS key pair from its public key.

The private key is written locally as:

``` text
task15-prabhas-key.pem
```

with file permission `0600`.

The private key must not be committed to Git.

### Encryption Key

Terraform generates a random encryption key:

``` hcl
resource "random_password" "encryption_key" {
  length  = 64
  special = false
}
```

The key is passed into EC2 user data and used as:

``` yaml
ENCRYPTION_KEY: "${encryption_key}"
```

This is required by the deployed Twenty version for session
cookie/encryption configuration.

### EC2 Security Group

The EC2 security group allows:

-   SSH on port `22` from the configured SSH CIDR
-   Twenty CRM on port `8080` only from the ALB security group
-   Outbound traffic

The ALB is therefore the intended public application entry point.

### ALB Security Group

The ALB security group allows:

-   HTTP port `80` from the Internet
-   Outbound traffic

### EC2 Instance

The EC2 instance uses:

``` text
Instance type: t3.small
Twenty version: v2.38.1
Application port: 8080
```

Terraform user data installs Docker, creates the required swap space,
and deploys:

``` text
Twenty CRM
PostgreSQL 16
Redis 7
```

The Twenty container maps:

``` text
EC2 port 8080 -> container port 3000
```

The user data also configures:

``` yaml
NODE_OPTIONS: "--max-old-space-size=768"
```

to provide a larger Node.js heap for the application startup/migration
process.

### Application Load Balancer

The ALB is internet-facing and uses the default VPC subnets.

The ALB name is:

``` text
task15-twenty-prabhas-alb
```

### Target Group

The target group is:

``` text
task15-twenty-prabhas-tg
```

Configuration:

``` text
Target type: Instance
Protocol: HTTP
Port: 8080
Protocol version: HTTP1
```

The EC2 instance is registered as the target.

### Health Check

The target group health check uses:

``` text
Protocol: HTTP
Port: 8080
Path: /api/health
Interval: 30 seconds
Timeout: 10 seconds
Healthy threshold: 2
Unhealthy threshold: 3
Success code: 200
```

The application endpoint was verified directly on EC2 and returned:

``` text
200
```

The AWS Target Group also showed:

``` text
Total targets: 1
Healthy: 1
Unhealthy: 0
```

### ALB Listener

The ALB has an HTTP listener:

``` text
HTTP :80
```

The default action forwards requests to:

``` text
task15-twenty-prabhas-tg
```

## User Data Configuration

Terraform uses:

``` hcl
user_data = templatefile("${path.module}/user_data.sh", {
  alb_dns_name   = aws_lb.twenty.dns_name
  encryption_key = random_password.encryption_key.result
})
```

This makes the deployment reproducible.

The resulting Twenty configuration uses the ALB hostname as the
application `SERVER_URL`:

``` yaml
SERVER_URL: http://${alb_dns_name}
```

This is important because using `localhost` would cause browser
redirects to the user's own machine rather than the AWS ALB.

## Deployment Commands

Initialize Terraform:

``` bash
terraform init
```

Format the configuration:

``` bash
terraform fmt
```

Validate the configuration:

``` bash
terraform validate
```

Expected result:

``` text
Success! The configuration is valid.
```

Create a plan:

``` bash
terraform plan
```

Apply:

``` bash
terraform apply
```

Confirm with:

``` text
yes
```

## Verification

### 1. Docker Containers

On the EC2 instance:

``` bash
docker ps
```

Expected services:

``` text
twenty
twenty-postgres
twenty-redis
```

PostgreSQL should report:

``` text
healthy
```

### 2. Twenty Local Health

Verify the application:

``` bash
curl -I http://localhost:8080
```

Expected:

``` text
HTTP/1.1 200 OK
```

Verify the ALB health-check endpoint:

``` bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/api/health
```

Expected:

``` text
200
```

### 3. Target Group

AWS Console:

``` text
EC2
→ Target Groups
→ task15-twenty-prabhas-tg
→ Targets
```

Expected:

``` text
1 target
Healthy: 1
Unhealthy: 0
```

### 4. ALB Access

The application is accessed through the ALB DNS name:

``` text
http://task15-twenty-prabhas-alb-1085806257.us-east-1.elb.amazonaws.com
```

Twenty CRM was successfully displayed through this ALB URL.

The browser remained on the ALB hostname instead of redirecting to
`localhost`.

## Terraform Outputs

Example successful deployment outputs:

``` text
alb_dns_name = "task15-twenty-prabhas-alb-1085806257.us-east-1.elb.amazonaws.com"
alb_url = "http://task15-twenty-prabhas-alb-1085806257.us-east-1.elb.amazonaws.com"
ec2_instance_id = "i-061cf6cdc9b34eda0"
ec2_public_ip = "44.204.116.86"
key_name = "task15-prabhas-key"
private_key_file = "./task15-prabhas-key.pem"
subnet_id = "subnet-078d52bfe579c74f2"
target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:579138738751:targetgroup/task15-twenty-prabhas-tg/374c2cd30924d06d"
vpc_id = "vpc-0c241509159132524"
```

These values are deployment-time outputs and may change when Terraform
recreates resources.

## Troubleshooting During Deployment

### Twenty container initially failed

The initial Twenty startup experienced Node.js heap exhaustion during
database migration.

The configuration was adjusted to use:

``` yaml
NODE_OPTIONS: "--max-old-space-size=768"
```

The Twenty container resource limit was also removed so that the Node
process was not artificially constrained.

### Database migration issue

After the initial failed migration, the PostgreSQL volume was removed
and the stack was recreated.

This allowed Twenty to perform a clean database migration.

The logs then reported:

``` text
Successfully migrated DB!
```

### Missing encryption key

Twenty subsequently reported:

``` text
Cannot derive session cookie secret:
set ENCRYPTION_KEY (or APP_SECRET for legacy deployments)
```

The final Terraform configuration therefore generates an encryption key
and injects it into `user_data.sh`.

### localhost redirect

When `SERVER_URL` was initially:

``` yaml
SERVER_URL: http://localhost:8080
```

the browser was redirected to:

``` text
http://localhost/welcome
```

The final configuration uses the Terraform-generated ALB DNS name
instead.

## Cleanup

The task requires all provisioned AWS resources to be destroyed after
verification.

Run:

``` bash
terraform destroy
```

Confirm:

``` text
yes
```

Expected result:

``` text
Destroy complete!
```

After destruction, verify Terraform state:

``` bash
terraform state list
```

The command should return no managed resources.

## Evidence / Screenshots

Recommended evidence for the task:

1.  Terraform validation/plan
2.  Terraform apply completion
3.  EC2 instance details showing `t3.small`
4.  ALB details showing Active status
5.  ALB listener showing HTTP port `80`
6.  Target Group showing EC2 registered on port `8080`
7.  Target Group showing `Healthy`
8.  Twenty CRM dashboard accessed through the ALB DNS name
9.  Terraform destroy completion
10. Empty Terraform state after destroy

## Security Notes

-   The generated private key is local-only and must never be committed.
-   `terraform.tfvars` should remain ignored if it contains
    environment-specific values.
-   The encryption key is generated by Terraform and should not be
    hardcoded in Git.
-   For production deployments, SSH access should be restricted to a
    trusted IP/CIDR rather than `0.0.0.0/0`.
-   HTTPS with an ACM certificate should be used for production traffic
    instead of plain HTTP.

## Result

Task 15 successfully demonstrates:

-   Terraform-based AWS provisioning
-   EC2 deployment of Twenty CRM
-   Docker-based application deployment
-   Application Load Balancer configuration
-   Target Group registration
-   ALB health checks
-   Security group separation between ALB and EC2
-   Access to Twenty CRM through the ALB DNS name
-   Terraform-based infrastructure cleanup

