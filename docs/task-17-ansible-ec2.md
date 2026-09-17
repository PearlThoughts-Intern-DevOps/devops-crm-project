# Task 17: Ansible and AWS EC2 Deployment

## Overview

Deployed Twenty CRM on an AWS EC2 instance using Terraform and Ansible.

## Infrastructure

- AWS Region: us-east-1
- Instance Type: t3.small
- AMI: ami-0b6d9d3d33ba97d99
- Default VPC and default subnet
- Application Port: 2020
- Container Port: 3000

## Terraform

Terraform was used to create:

- EC2 instance
- Security group
- SSH access
- Twenty CRM application port access

## Ansible

Ansible was used to:

- Update Ubuntu packages
- Configure 2 GB swap for memory headroom
- Install Docker and Docker Compose
- Start and enable Docker
- Create the Twenty CRM application directory
- Generate PostgreSQL and Twenty CRM encryption secrets
- Create Docker Compose configuration
- Deploy Twenty CRM
- Configure restart policies
- Configure container health checks
- Start the application
- Verify Twenty CRM health
- Display Docker container status
- Display Twenty CRM application logs

## Issues Encountered and Recovery

During the initial deployment, the t3.small EC2 instance experienced severe memory pressure because it had approximately 2 GB of RAM and no swap configured.

The Linux OOM (Out-Of-Memory) killer terminated the Twenty CRM server process multiple times. This caused the Twenty CRM health check to remain in a `starting` state and eventually caused the Ansible SSH connection to become unreachable.

The EC2 instance was rebooted to recover the system.

A 2 GB swap file was then created using:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

The swap configuration was also added to `/etc/fstab` so it persists across reboots.

The Ansible playbook was updated to automate the same swap configuration for future deployments.

After enabling swap, the Ansible playbook was rerun successfully and Twenty CRM reached a healthy state.

## Deployment Verification

The final Ansible playbook execution completed successfully with:

- `ok=21`
- `changed=2`
- `unreachable=0`
- `failed=0`

Twenty CRM was verified as running and healthy at:

`http://100.58.209.247:2020`

Docker verification showed:

- PostgreSQL container: healthy
- Redis container: healthy
- Twenty CRM server container: healthy
- Twenty CRM worker container: running

The Twenty CRM server health check returned:

`healthy`

## Cleanup

After completing verification and collecting evidence, the EC2 instance is to be destroyed using Terraform:

```bash
terraform destroy
```

## Evidence

Screenshots were captured showing:

- Successful Ansible deployment
- Docker Compose container status
- Twenty CRM server health status
- Twenty CRM application logs

