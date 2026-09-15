# Task 15: AWS Application Load Balancer (ALB)

## Objective

Deploy the Twenty CRM application on an AWS EC2 instance and expose it through an AWS Application Load Balancer (ALB) using Terraform.

The deployment uses:

- AWS region: `us-east-1`
- Default VPC
- Existing/default VPC subnets
- EC2 instance type: `t3.small`
- Ubuntu AMI: `ami-0b6d9d3d33ba97d99`
- Twenty CRM running on port `2020`
- ALB listening on port `80`

All infrastructure provisioning and configuration was performed using Terraform.

---

## Terraform Files

### `providers.tf`

Configures the AWS provider and deploys resources in `us-east-1`.

### `variables.tf`

Defines configurable values such as:

- AWS region
- EC2 instance name
- EC2 instance type
- Ubuntu AMI ID
- EC2 key pair
- SSH CIDR
- ALB CIDR

### `main.tf`

Uses Terraform data sources to retrieve:

- The default VPC
- Subnets belonging to the default VPC

### `ec2.tf`

Creates:

- EC2 security group
- EC2 instance
- Required ingress and egress rules

The EC2 security group allows:

- SSH on port `22`
- Twenty CRM traffic on port `2020` from the ALB security group

The EC2 instance uses:

- `t3.small`
- Ubuntu AMI
- 20 GiB `gp3` root volume
- Existing EC2 key pair

### `alb.tf`

Creates the Application Load Balancer architecture:

1. Application Load Balancer
2. Target Group
3. Target Group attachment
4. HTTP listener

The ALB listens on:

```text
HTTP :80
```

The Target Group forwards traffic to:

```text
HTTP :2020
```

The EC2 instance is registered as the target.

### `user-data.sh`

Automatically configures the EC2 instance during startup.

It:

1. Updates the Ubuntu package index.
2. Installs Docker.
3. Starts and enables Docker.
4. Creates a 2 GiB swap file if swap is not already configured.
5. Pulls the Twenty CRM Docker image.
6. Starts the Twenty CRM container.
7. Exposes the application on port `2020`.

### `outputs.tf`

Provides useful deployment information including:

- EC2 instance ID
- EC2 public IP
- ALB DNS name
- ALB URL
- Target Group ARN
- Target Group name
- VPC ID

### `terraform.tfvars`

Contains the environment-specific values used for the deployment, including the AWS region, EC2 configuration, key pair, and access CIDRs.

---

# Security Groups

Two security groups were created.

## ALB Security Group

Allows:

```text
HTTP :80
Source: 0.0.0.0/0
```

This allows users to access the application through the ALB.

## EC2 Security Group

Allows:

```text
SSH :22
Source: configured SSH CIDR
```

and:

```text
TCP :2020
Source: ALB Security Group
```

The application port is therefore accessible from the ALB rather than being directly exposed to the internet.

---

# Load Balancer Configuration

The ALB is internet-facing and uses two subnets from the default VPC in different Availability Zones.

The listener is configured as:

```text
HTTP :80
```

Traffic is forwarded to the Twenty CRM Target Group.

The Target Group is configured as:

```text
Protocol: HTTP
Port: 2020
Target type: instance
```

---

# Health Check

The Target Group health check uses:

```text
Protocol: HTTP
Path: /
Port: traffic-port
```

The Twenty CRM application responded successfully on port `2020`.

The registered EC2 target eventually reached:

```text
State: healthy
```

---

# Terraform Execution

The Terraform workflow used was:

```text
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Terraform successfully provisioned the required ALB infrastructure and EC2 instance.

After deployment, the application was verified through the ALB.

---

# Verification

## EC2 Application Verification

The Twenty CRM application was tested locally on the EC2 instance:

```bash
curl -I http://localhost:2020
```

The application returned:

```text
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was running correctly on the EC2 instance.

---

## Target Group Verification

The registered EC2 target was checked through AWS.

The target became:

```text
Healthy
```

This confirmed that the ALB health check could successfully reach the Twenty CRM application.

---

## ALB Verification

The application was tested through the ALB using:

```bash
curl -I "$(terraform output -raw alb_url)"
```

The response was:

```text
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
```

This confirmed the complete request path:

```text
Client
  |
  v
ALB :80
  |
  v
Target Group :2020
  |
  v
EC2
  |
  v
Twenty CRM
```

The ALB URL was also opened successfully in a web browser and the Twenty CRM application was accessible.

---

# Cleanup

After successful verification, Terraform destroy was executed:

```bash
terraform destroy
```

# Result

Task 15 successfully deployed Twenty CRM behind an AWS Application Load Balancer using Terraform.

Verification confirmed:

- ALB was reachable.
- Target Group target became healthy.
- Twenty CRM returned `HTTP 200 OK`.
- Twenty CRM was accessible through the ALB in a browser.
- Terraform destroy successfully removed the Task 15 infrastructure.