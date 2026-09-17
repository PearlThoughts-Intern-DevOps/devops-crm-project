# Task 17: Ansible and AWS EC2 Deployment

**Name:** Mujtaba Shaikh

**Date:** 17 September 2026

## Summary of Work

* Created an AWS EC2 instance using Terraform in `us-east-1`.
* Used a `t3.small` instance with the default VPC and subnet.
* Added the EC2 public IP to the Ansible inventory.
* Verified Ansible connectivity using the `ping` module.
* Updated server packages and installed Docker with required dependencies.
* Created the required Twenty CRM application directory.
* Configured Twenty CRM environment variables using Ansible.
* Created the Docker Compose configuration using an Ansible Jinja2 template.
* Deployed Twenty CRM with Docker Compose.
* Configured Docker restart policy and container health checks.
* Started Twenty CRM along with PostgreSQL and Redis containers.
* Verified Docker container status and application logs.
* Verified Twenty CRM using HTTP on port `2020`.

## Ansible Verification

Ansible connectivity was verified successfully:

```text
98.92.199.1 | SUCCESS
"ping": "pong"
```

The Ansible playbook completed successfully:

```text
ok=14
changed=5
unreachable=0
failed=0
skipped=0
rescued=0
ignored=0
```

## Docker Container Status

The deployed containers were:

```text
twenty-crm
twenty-postgres
twenty-redis
```

Twenty CRM was exposed on:

```text
0.0.0.0:2020 -> 3000/tcp
```

PostgreSQL and Redis containers were running successfully.

## Application Verification

Twenty CRM was verified using:

```bash
curl -I http://98.92.199.1:2020
```

Response:

```text
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was responding successfully on port `2020`.

## Terraform and Ansible Workflow

The deployment workflow was:

1. Terraform created the EC2 infrastructure.
2. The EC2 public IP was added to the Ansible inventory.
3. Ansible connected to the EC2 instance.
4. Ansible configured Docker and the required dependencies.
5. Ansible generated the Twenty CRM environment and Docker Compose files.
6. Ansible deployed the Twenty CRM stack.
7. The application health and HTTP response were verified.
8. The EC2 instance will be destroyed using Terraform after completing the required documentation and evidence.

## Files Added or Updated

* `ansible-mujtaba/site.yml`
* `ansible-mujtaba/inventory/hosts.ini`
* `ansible-mujtaba/group_vars/all.yml`
* `ansible-mujtaba/templates/twenty.env.j2`
* `ansible-mujtaba/templates/docker-compose.yml.j2`
* Terraform EC2 configuration
* Terraform root configuration and outputs

## Result

Twenty CRM was successfully deployed on AWS EC2 using Terraform and Ansible and verified with an HTTP `200 OK` response on port `2020`.

