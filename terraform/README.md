# Task 17: Ansible and AWS EC2 Deployment

**Author:** Shubham Singh
**Date:** 17 September 2026
**Branch:** `shubham-17`

---

## Overview

This task demonstrates deploying Twenty CRM on AWS EC2 using a two-tool approach:

- **Terraform** — provisions the bare EC2 instance and networking
- **Ansible** — configures the server and deploys the application

This is a production-level separation of concerns — Terraform manages infrastructure, Ansible manages configuration and deployment. Neither tool does the other's job.

---

## Architecture

```
Local Machine
│
├── Terraform (infrastructure)
│   ├── Creates EC2 instance (t3.small, us-east-1)
│   ├── Creates Security Group (port 22 + 2020)
│   └── Outputs EC2 public IP
│
└── Ansible (configuration + deployment)
    ├── Role: common  → updates packages, installs dependencies
    ├── Role: docker  → installs Docker CE + Docker Compose
    └── Role: twentycrm → deploys Twenty CRM via Docker Compose
```

```
EC2 Instance (98.92.191.222)
│
└── Docker Network: twenty-net
    ├── twenty-app  (twentycrm/twenty:v2.35.0) → port 2020:3000
    ├── twenty-db   (postgres:15-alpine)        → port 5432
    └── twenty-redis (redis:7-alpine)           → port 6379
```

---

## Project Structure

```
devops-crm-project/
├── terraform/
│   ├── main.tf                    # EC2 + Security Group
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # EC2 IP, SSH command, Ansible command
│   ├── providers.tf               # AWS provider
│   ├── terraform.tfvars           # Variable values
│   ├── terraform.tfvars.example   # Template for secrets
│   └── modules/
│       └── ec2/                   # Reusable EC2 module
│
└── ansible/
    ├── site.yml                   # Main playbook entry point
    ├── ansible.cfg                # Ansible configuration
    ├── requirements.yml           # Galaxy collections
    ├── inventory/
    │   └── hosts.ini              # EC2 IP and SSH config
    ├── group_vars/
    │   └── all.yml                # Shared variables and secrets
    └── roles/
        ├── common/                # Base system setup
        ├── docker/                # Docker installation
        └── twentycrm/             # Twenty CRM deployment
            ├── tasks/main.yml
            ├── defaults/main.yml
            ├── handlers/main.yml
            └── templates/
                ├── docker-compose.yml.j2
                └── twenty.env.j2
```

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.7.0 installed
- Ansible >= 2.14 installed
- SSH key pair created in us-east-1

---

## Step 1 — Create SSH Key Pair

```bash
aws ec2 create-key-pair \
  --key-name shubhamsingh-task17 \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/shubhamsingh-task17.pem
chmod 400 ~/.ssh/shubhamsingh-task17.pem
```

Key pair is created outside Terraform so it survives `terraform destroy` cycles.

---

## Step 2 — Terraform: Provision EC2

### Configure variables

```bash
cd terraform/
cat terraform.tfvars
```

```hcl
aws_region    = "us-east-1"
project_name  = "shubham-singh-task17"
environment   = "dev"
owner         = "shubham-singh"
instance_type = "t3.small"
ami_id        = "ami-0b6d9d3d33ba97d99"
key_pair_name = "shubhamsingh-task17"
app_port      = 2020
volume_size   = 20
```

### Run Terraform

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Terraform Output

```
Outputs:

ansible_run_command      = "ansible-playbook -i inventory/hosts.ini site.yml"
app_url                  = "http://98.92.191.222:2020"
ec2_instance_id          = "i-050009584328677d3"
ec2_public_ip            = "98.92.191.222"
ssh_command              = "ssh -i ~/.ssh/shubhamsingh-task17.pem ubuntu@98.92.191.222"
update_inventory_command = "sed -i 's/REPLACE_WITH_EC2_IP/98.92.191.222/' ../ansible/inventory/hosts.ini"
```

### What Terraform creates

- EC2 instance (t3.small, Ubuntu, us-east-1)
- Security Group — allows port 22 (SSH) and port 2020 (app) from internet
- No user_data — Ansible handles all configuration

---

## Step 3 — Update Ansible Inventory

```bash
EC2_IP=$(cd terraform && terraform output -raw ec2_public_ip)
sed -i "s/REPLACE_WITH_EC2_IP/$EC2_IP/" ansible/inventory/hosts.ini
```

Verify:

```bash
cat ansible/inventory/hosts.ini
```

```ini
[crm_servers]
shubham-task17 ansible_host=98.92.191.222 ansible_user=ubuntu \
  ansible_ssh_private_key_file=~/.ssh/shubhamsingh-task17.pem \
  ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[crm_servers:vars]
ansible_python_interpreter=/usr/bin/python3
```

---

## Step 4 — Ansible: Configure and Deploy

### Install Galaxy collections

```bash
cd ansible/
ansible-galaxy collection install -r requirements.yml
```

### Syntax check

```bash
ansible-playbook -i inventory/hosts.ini site.yml --syntax-check
```

### Run playbook

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

### What Ansible does

**Role: common**
- Updates apt cache and upgrades all packages
- Installs curl, wget, git, python3, jq and other dependencies
- Sets timezone to UTC
- Ensures /opt directory exists

**Role: docker**
- Removes old conflicting Docker packages
- Installs Docker CE and Docker Compose plugin
- Enables Docker to start on boot (`systemctl enable docker`)
- Adds ubuntu user to docker group

**Role: twentycrm**
- Creates `/opt/twenty` application directory
- Templates `.env` file with secrets from `group_vars/all.yml`
- Templates `docker-compose.yml` with health checks and restart policies
- Pulls Twenty CRM Docker image
- Runs `docker compose up -d`
- Waits for health endpoint to return HTTP 200
- Displays container status and logs

### Playbook Result

```
PLAY RECAP
shubham-task17 : ok=50   changed=12   unreachable=0   failed=0
```

---

## Step 5 — Verification

### Container status

```bash
docker ps -a
```

```
CONTAINER ID   IMAGE                      STATUS                    PORTS
cb95e3c9e7f2   twentycrm/twenty:v2.35.0   Up 12 minutes (healthy)   0.0.0.0:2020->3000/tcp
451a848f92ee   postgres:15-alpine         Up 12 minutes (healthy)   5432/tcp
ccce685cede8   redis:7-alpine             Up 12 minutes (healthy)   6379/tcp
```

### Health check status

```bash
docker inspect twenty-app --format='Health: {{.State.Health.Status}}'
# Health: healthy

docker inspect twenty-db --format='Health: {{.State.Health.Status}}'
# Health: healthy

docker inspect twenty-redis --format='Health: {{.State.Health.Status}}'
# Health: healthy
```

### Restart policy

```bash
docker inspect twenty-app --format='Restart Policy: {{.HostConfig.RestartPolicy.Name}}'
# Restart Policy: unless-stopped
```

### HTTP response

```bash
curl -I http://98.92.191.222:2020
# HTTP/1.1 200 OK
```

### Application logs

```bash
docker logs twenty-app --tail 10
# [Nest] 1 - LOG [NestApplication] Nest application successfully started
```

### Docker Compose status

```bash
cd /opt/twenty && docker compose ps
```

```
NAME           IMAGE                      SERVICE   STATUS              PORTS
twenty-app     twentycrm/twenty:v2.35.0   twenty    Up (healthy)        0.0.0.0:2020->3000/tcp
twenty-db      postgres:15-alpine         db        Up (healthy)        5432/tcp
twenty-redis   redis:7-alpine             redis     Up (healthy)        6379/tcp
```

---

## Step 6 — Failure Recovery (Applied from Task 16)

Task 16 taught us Docker restart policies and failure recovery. That knowledge is applied here.

### Container crash recovery

```bash
# kill main process inside container (simulates app crash)
docker exec twenty-app kill -9 1

# verify auto restart
sleep 10 && docker ps -a
docker inspect twenty-app --format='RestartCount: {{.RestartCount}}'
```

Result: Docker detects the crash and restarts the container automatically within seconds.

### EC2 reboot recovery

```bash
sudo reboot
```

After 2-3 minutes, SSH back in:

```bash
ssh -i ~/.ssh/shubhamsingh-task17.pem ubuntu@98.92.191.222
docker ps -a
```

Result: All 3 containers come back automatically because:
- `systemctl enable docker` — Docker starts on EC2 boot
- `restart: unless-stopped` — containers start with Docker

```bash
# confirm docker starts on boot
sudo systemctl is-enabled docker
# enabled
```

---

## Step 7 — Destroy Infrastructure

```bash
cd terraform/
terraform destroy -auto-approve
```

---

## Key Differences: Task 16 vs Task 17

| | Task 16 | Task 17 |
|---|---|---|
| EC2 provisioning | Terraform | Terraform |
| App deployment | user_data (bash script) | Ansible playbook |
| Configuration management | Hardcoded in bash | Jinja2 templates + variables |
| Reusability | Low — tied to one EC2 | High — run against any server |
| Idempotency | No — runs once on boot | Yes — safe to run multiple times |
| Role separation | Mixed in one script | Separate roles: common, docker, app |
| Secret management | terraform.tfvars | group_vars/all.yml |

---

## Why Ansible over user_data

user_data runs once on EC2 creation and cannot be re-run. If something fails midway you have no way to retry just that step.

Ansible is idempotent — each task checks the current state before making changes. If Docker is already installed it skips that step. If the container is already running it skips that too. You can run the playbook 10 times and it produces the same result safely.

This is why Ansible is the production standard for configuration management while user_data is only used for minimal bootstrapping.

---

## Application Access

Twenty CRM is accessible at: `http://98.92.191.222:2020`

Default login is created automatically on first boot.
