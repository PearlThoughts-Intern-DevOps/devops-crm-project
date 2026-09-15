# Task 15 — AWS Application Load Balancer (ALB) with Twenty CRM

## Overview
Deploy Twenty CRM on EC2 behind an AWS Application Load Balancer (ALB) using Terraform with a modular architecture.

---

## Architecture

Internet (HTTP port 80)
|
v
+----------------------------------+
| Application Load Balancer (ALB) |
| ALB Security Group |
| Inbound: 0.0.0.0/0 -> port 80 |
+----------------------------------+
|
| port 2020
v
+----------------------------------+
| EC2 Instance (t3.small) |
| Ubuntu 22.04 LTS |
| EC2 Security Group |
| Inbound: ALB SG -> port 2020 |
| Inbound: 0.0.0.0/0 -> port 22 |
| |
| +------------------------------+ |
| | Docker Network | |
| | | |
| | twenty-crm | |
| | port 2020 -> 3000 | |
| | | |
| | twenty-worker | |
| | background jobs | |
| | | |
| | postgres:16-alpine | |
| | port 5432 | |
| | | |
| | redis:7-alpine | |
| | port 6379 | |
| +------------------------------+ |
+----------------------------------+


---

## AWS Configuration

| Parameter     | Value                 |
|---------------|-----------------------|
| Region        | us-east-1             |
| Instance Type | t3.small              |
| AMI           | ami-0b6d9d3d33ba97d99 |
| VPC           | Default VPC           |
| Subnet        | Default subnets       |

---

## Project Structure

terraform/
├── main.tf # Root module - VPC, SGs, EC2, ALB
├── variables.tf # All input variables
├── outputs.tf # ALB URL, EC2 IP, TG ARN
├── providers.tf # AWS provider configuration
├── terraform.tfvars.example # Example vars (copy to terraform.tfvars)
├── user_data.sh.tpl # EC2 bootstrap script
└── modules/
├── ec2/ # EC2 instance module
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
└── alb/ # ALB + Target Group + Listener module
├── main.tf
├── variables.tf
└── outputs.tf


---

## What Terraform Creates

aws_security_group.alb - allows port 80 from internet
aws_security_group.ec2 - allows port 2020 from ALB only
module.ec2
aws_instance - EC2 with Twenty CRM via user_data
aws_security_group - EC2 own SG
module.alb
aws_lb - Application Load Balancer
aws_lb_target_group - TG on port 2020 with health check
aws_lb_target_group_attachment - registers EC2 into TG
aws_lb_listener - port 80 forward to TG


---

## Security Group Design

ALB Security Group
Inbound - port 80 from 0.0.0.0/0 (internet to ALB)
Outbound - all traffic allowed

EC2 Security Group
Inbound - port 2020 from ALB SG only (ALB to EC2 only)
Inbound - port 22 from 0.0.0.0/0 (SSH access)
Outbound - all traffic allowed


---

## Health Check Configuration

Path = /
Protocol = HTTP
Port = traffic-port (2020)
Healthy threshold = 2
Unhealthy threshold= 3
Timeout = 10s
Interval = 30s
Matcher = 200-399


---

## Prerequisites

- AWS CLI configured with valid credentials
- Terraform >= 1.7.0
- EC2 Key Pair created in us-east-1
- IAM user with EC2 + ALB + VPC permissions

---

## Setup

### 1. Clone and navigate

```bash
git clone https://github.com/shubhamsingh74888/devops-crm-project.git
cd devops-crm-project/terraform
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

Fill in:

```hcl
key_pair_name  = "your-key-pair-name"
encryption_key = "your-32-char-key"
app_secret     = "your-app-secret"
pg_password    = "YourStrongPassword"
```

### 3. Run Terraform

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Outputs

alb_dns_name = "shubham-singh-task15-alb-xxxx.us-east-1.elb.amazonaws.com"
alb_url = "http://shubham-singh-task15-alb-xxxx.us-east-1.elb.amazonaws.com"
ec2_public_ip = "x.x.x.x"
ec2_instance_id = "i-xxxxxxxxxxxxxxxxx"
target_group_arn = "arn:aws:elasticloadbalancing:..."
default_vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
ssh_command = "ssh -i ~/.ssh/your-key.pem ubuntu@x.x.x.x"


---

## Verify Deployment

### Check target health via CLI

```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region us-east-1 \
  --query 'TargetHealthDescriptions[0].TargetHealth'
```

Expected:

```json
{
    "State": "healthy"
}
```

### Check via browser

Open ALB URL in browser — Twenty CRM login page should load.

### SSH into EC2

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<ec2_public_ip>
sudo docker ps -a
sudo docker logs twenty-crm --tail 20
curl -I http://localhost:2020
```

---

## Twenty CRM Stack

| Container     | Image                      | Port | Memory |
|---------------|----------------------------|------|--------|
| twenty-crm    | twentycrm/twenty:v2.35.0   | 2020 | 768MB  |
| twenty-worker | twentycrm/twenty:v2.35.0   | -    | 384MB  |
| twenty-db     | postgres:16-alpine         | 5432 | 256MB  |
| twenty-redis  | redis:7-alpine             | 6379 | 128MB  |

---

## Destroy Resources

```bash
terraform destroy -auto-approve
```

---

## Notes

- EC2 bootstrap takes 10-12 minutes (Docker pull + 182 DB migrations)
- 3GB swap added to prevent OOM on t3.small
- NODE_OPTIONS=--max-old-space-size=640 set for Node.js heap
- SERVER_URL set to ALB DNS so all redirects stay on ALB
- Direct EC2 IP access blocked by security group design
- terraform.tfvars is gitignored — never commit secrets

---

## Author

**Shubham Singh**
Cloud Support Engineer | MCA 2026 | Garden City University, Bangalore
