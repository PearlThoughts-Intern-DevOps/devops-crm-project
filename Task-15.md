# Task 15: AWS Application Load Balancer

**Name:** Mujtaba Shaikh
**Task:** 15
**Date:** 15 September 2026

## Summary

* Created AWS Application Load Balancer using Terraform.
* Created target group and registered the Twenty CRM EC2 instance.
* Configured HTTP listener on port 80.
* Configured health check on port 2020 with path `/`.
* Configured security groups to allow ALB traffic to EC2 on port 2020.
* Deployed Twenty CRM using Docker Compose with PostgreSQL and Redis.
* Verified the ALB target became **Healthy**.
* Verified Twenty CRM is accessible through the ALB.

## Terraform Resources

* EC2
* Application Load Balancer
* Target Group
* ALB Listener
* Security Groups

## Verification

```text
Terraform validate: Success
Terraform apply: Successful
ALB Target: Healthy
Twenty CRM: Running on port 2020
```

