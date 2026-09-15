# Task 15 — AWS Application Load Balancer (ALB) for Twenty CRM

Deploy Twenty CRM on EC2 behind an AWS Application Load Balancer using Terraform.
All infrastructure provisioned with Terraform; no manual AWS Console actions.

---

## 1. Overview

This Terraform project creates:

| Resource                      | Purpose                                                    |
| ----------------------------- | ---------------------------------------------------------- |
| **Application Load Balancer** | Internet-facing entry point, listens on port 80            |
| **Target Group**              | Registers the EC2 instance, runs HTTP health checks on `/` |
| **Listener**                  | Forwards HTTP:80 traffic to the target group               |
| **Target Group Attachment**   | Registers the EC2 instance as a target                     |
| **ALB Security Group**        | Allows HTTP from the internet                              |
| **EC2 Security Group**        | Allows port 2020 ONLY from the ALB SG (two-tier pattern)   |
| **EC2 Instance**              | Runs Docker + Postgres 16 + Redis 7 + Twenty CRM           |

Uses the **existing default VPC** with two subnets from different Availability Zones (required by the ALB).

---

## 2. Architecture

```text
              ┌─────────────────────────────────────┐
              │            Internet                 │
              └──────────────────┬──────────────────┘
                                 │ http://<alb-dns>
                                 ▼
              ┌─────────────────────────────────────┐
              │  ALB (Application Load Balancer)    │
              │  • Listener: port 80                │
              │  • SG: allow 80 from 0.0.0.0/0      │
              └──────────────────┬──────────────────┘
                                 │ forward to target group
                                 ▼
              ┌─────────────────────────────────────┐
              │  Target Group                       │
              │  • Protocol: HTTP, port 2020        │
              │  • Health check: GET /              │
              │  • Registered target: EC2 instance  │
              └──────────────────┬──────────────────┘
                                 │
                                 ▼
              ┌─────────────────────────────────────┐
              │  EC2 (t3.small) — Twenty CRM        │
              │  • SG: port 2020 from ALB SG only   │
              │  • Docker: Postgres + Redis + App   │
              └─────────────────────────────────────┘
```

---

## 3. Project Structure

```text
terraform/
├── main.tf              # Root — data sources, ALB SG, 2 module calls
├── provider.tf          # AWS + random providers
├── variables.tf         # Root-level variables
├── outputs.tf           # Aggregated outputs (instance + ALB)
├── terraform.tfvars     # Values for root variables
├── user_data.sh.tpl     # Bootstrap for EC2 (Docker + Twenty CRM)
├── README.md
└── modules/
    ├── alb/
    │   ├── main.tf         # ALB + Target Group + Listener + Attachment
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2/
        ├── main.tf         # SG (two-tier) + EC2 instance
        ├── variables.tf
        └── outputs.tf
```

---

## 4. Two-Tier Security Group Pattern

**Task 12/13 pattern:**

* EC2 SG allows port 2020 from `0.0.0.0/0` (internet can reach EC2 directly)

**Task 15 pattern (safer):**

| Security Group | Allows    | Source                                 |
| -------------- | --------- | -------------------------------------- |
| **ALB SG**     | Port 80   | `0.0.0.0/0` (public internet)          |
| **EC2 SG**     | Port 2020 | **Only the ALB's SG** (no public CIDR) |

The EC2 is **not directly reachable** from the internet. All traffic must go through the ALB. This is the recommended production pattern.

Implemented in `modules/ec2/main.tf`:

```hcl
ingress {
  description     = "Twenty CRM application access via ALB"
  from_port       = var.app_port
  to_port         = var.app_port
  protocol        = "tcp"
  security_groups = [var.alb_security_group_id]   # source is the ALB SG
}
```

And in root `main.tf`, the ALB SG is passed into the EC2 module:

```hcl
module "ec2" {
  # ...
  alb_security_group_id = aws_security_group.alb.id
}
```

The ALB SG is created at root level (not in the ALB module) to **avoid a circular dependency** — the EC2 module needs it, and the ALB module needs the EC2 instance ID.

---

## 5. Health Check Configuration

The target group runs HTTP health checks every 30 seconds:

```hcl
health_check {
  enabled             = true
  path                = "/"
  port                = "traffic-port"
  protocol            = "HTTP"
  matcher             = "200-399"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}
```

* **Path:** `/` — Twenty CRM's root responds with HTTP 200
* **Port:** traffic-port — uses the target's registered port (2020)
* **Matcher:** 200-399 — accepts 2xx and 3xx responses
* **Healthy threshold:** 2 consecutive successes → healthy
* **Unhealthy threshold:** 3 consecutive failures → unhealthy

The ALB probes each target every 30s. Once 2 consecutive checks pass, the target enters the `healthy` state and receives traffic.

---

## 6. Commands Run

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan              # 12+ resources to add
terraform apply -auto-approve
```

Then after verification:

```bash
terraform destroy -auto-approve
```

---

## 7. Verification

### 7.1 Terraform outputs

```text
alb_dns_name        = "twenty-crm-dev-alb-187259106.us-east-1.elb.amazonaws.com"
alb_url             = "http://twenty-crm-dev-alb-187259106.us-east-1.elb.amazonaws.com"
instance_id         = "i-0067c460147c02ae7"
instance_public_ip  = "13.219.255.149"
security_group_id   = "sg-0b7cc0edebf98d395"
target_group_arn    = "arn:aws:elasticloadbalancing:us-east-1:579138738751:targetgroup/twenty-crm-dev-tg/6cac04e2d0b98b45"
```

### 7.2 Target Group Health Check

```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:579138738751:targetgroup/twenty-crm-dev-tg/6cac04e2d0b98b45 \
  --region us-east-1
```

Response:

```json
{
    "TargetHealthDescriptions": [
        {
            "Target": { "Id": "i-0067c460147c02ae7", "Port": 2020 },
            "HealthCheckPort": "2020",
            "TargetHealth": { "State": "healthy" }
        }
    ]
}
```

**State: healthy** — the ALB can reach Twenty CRM on port 2020 and health checks pass.

### 7.3 HTTP Access Through the ALB

```bash
curl -v http://twenty-crm-dev-alb-187259106.us-east-1.elb.amazonaws.com
```

Response:

```text
< HTTP/1.1 200 OK
< Content-Type: text/html; charset=utf-8
< X-Powered-By: Express
<title>Twenty</title>
<meta name="description" content="A modern open-source CRM" />
```

**HTTP 200 with Twenty CRM HTML** — the ALB forwards traffic correctly and Twenty CRM responds through the ALB.

### 7.4 Direct EC2 Access Is Blocked

Trying `http://13.219.255.149:2020` from the internet:

* Times out / connection refused
* Because the EC2 SG only accepts port 2020 traffic from the ALB SG

This proves the two-tier security group design works.

---

## 8. Issues Encountered and Resolutions

| # | Symptom                                            | Root Cause                                                                     | Resolution                                                                                  |
| - | -------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| 1 | `ecr:CreateRepository` denied on `terraform apply` | Task 14 config had ECR module; Task 15 doesn't need it                         | Removed `module "ecr"` and its variables/outputs; user_data now pulls from Docker Hub       |
| 2 | `s3:CreateBucket` denied                           | Same — Task 15 doesn't need S3                                                 | Removed `module "s3"` and its variables/outputs                                             |
| 3 | `iam:PassRole` denied on `EC2S3AccessRole`         | Work account restricts `iam:PassRole` for interns; Task 15 doesn't require IAM | Removed `iam_instance_profile` from tfvars, variables, ec2 module, and root main.tf         |
| 4 | Browser timeout on ALB URL                         | Local network uses CGNAT (same issue as Task 12)                               | Verified via `curl` from same machine — HTTP 200 with Twenty HTML confirms end-to-end works |
| 5 | Direct EC2 IP blocked in browser                   | Expected — two-tier SG only allows ALB traffic                                 | Confirmed as correct behavior                                                               |

---

## 9. Cleanup

```bash
terraform destroy -auto-approve
```

Verify state is empty:

```bash
terraform state list
```

Resources destroyed (~10):

* ALB (Listener, Target Group, Target Group Attachment)
* EC2 Security Group, ALB Security Group
* EC2 Instance
* EBS Volume (root, delete_on_termination = true)
* Networking ENIs

---

## 10. Notes for the Reviewer

* **Two-tier SG design:** EC2 is not directly reachable from the internet. All traffic flows through the ALB. This is the recommended production pattern.
* **ALB requires 2 subnets in different AZs.** Root `main.tf` uses `slice(data.aws_subnets.default.ids, 0, 2)` to pick the first two subnets from the default VPC.
* **Health check on `/`:** Twenty CRM's root path returns HTTP 200 once the app is up. Health checks promote the target from `initial` → `healthy` within ~60 seconds of user_data completing.
* **AMI:** `ami-0b6d9d3d33ba97d99` (instructor-approved Ubuntu 26.04).
* **No IAM role needed:** Task 15 only uses EC2, ALB, and SGs. The Twenty CRM image is pulled from Docker Hub. No ECR or S3 involved.
* **Browser timeout note:** On the operator's local network (CGNAT), the browser times out on ALB URLs. The ALB is verified working via `curl` from the same machine — HTTP 200 with Twenty CRM HTML. This is a client-side network limitation, not an ALB issue.

---


