# Task 17 – Automated Twenty CRM Deployment Using Terraform and Ansible


## 1. Objective

The objective of Task 17 is to automate the provisioning and configuration of an AWS EC2 server using Terraform and Ansible, and deploy the Twenty CRM application using Docker.

This task demonstrates Infrastructure as Code (IaC), configuration management, containerization, health monitoring, restart policies, and end-to-end deployment verification.


## 2. Requirements

The following requirements were implemented:

- Provision one EC2 instance using Terraform.
- Deploy in AWS region `us-east-1`.
- Use EC2 instance type `t3.small`.
- Use the specified Ubuntu 24.04 LTS AMI.
- Use the default VPC and default subnet.
- Retrieve the EC2 public IP dynamically via Terraform outputs.
- Configure the public IP in the Ansible inventory.
- Configure the server and install prerequisites using Ansible.
- Update server packages.
- Install Docker and required system dependencies.
- Create application directories.
- Configure Twenty CRM environment variables.
- Deploy Twenty CRM using Docker Compose.
- Configure a Docker restart policy (`always`).
- Configure a Docker health check (`/healthz`).
- Start and verify the application.
- Display Docker container status.
- Display application logs.
- Provide cleanup instructions to destroy infrastructure after completion.


## 3. Technologies Used

| Technology | Purpose |
| :--- | :--- |
| **AWS EC2** | Cloud compute infrastructure |
| **Terraform** | Infrastructure as Code (IaC) provisioning |
| **Ansible** | Server configuration management and deployment automation |
| **Docker** | Container runtime engine |
| **Docker Compose** | Multi-container application specification and orchestration |
| **Twenty CRM** | Open-source CRM web application |
| **Ubuntu Linux** | Host operating system (24.04 LTS) |
| **Git & GitHub** | Version control and collaboration |


## 4. AWS Infrastructure

The EC2 instance was provisioned in the AWS `us-east-1` region with the following specifications:

| Parameter | Value |
| :--- | :--- |
| **Region** | `us-east-1` |
| **Instance Type** | `t3.small` |
| **Root Volume** | 20 GB gp3 (Encrypted) |
| **VPC** | Default VPC |
| **Subnet** | Default VPC Subnet |
| **Application** | Twenty CRM |
| **Application Port** | `2020` |

> **Note:** The root volume was configured to 20 GB because the Twenty CRM Docker image layers and runtime storage require more disk capacity than a minimal default root disk.


## 5. Project Structure

The Task 17 project files are organized as follows:

```text
task17/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── ansible/
│   ├── inventory.ini
│   └── deploy-twenty.yml
│
├── screenshots/
│   ├── terraform plan.png
│   ├── terraform apply.png
│   ├── ec2.png
│   ├── ansible playbook.png
│   ├── ansible playbook 2.png
│   ├── ec2 docker ps.png
│   ├── restart, http check, logs.png
│   └── app.png
│
└── task17.md
```


## 6. Terraform Configuration

Terraform was used to declare and provision the AWS infrastructure.

The configuration includes:
- AWS provider configuration (`~> 6.0`)
- Default VPC lookup
- Default VPC subnet lookup
- Security group creation
- EC2 instance creation with SSH key pair
- 20 GB encrypted gp3 root volume
- Standardized Terraform outputs

```hcl
resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.task17.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "bkkrish007-twenty-task17"
  }
}
```


## 7. Security Group Configuration

A dedicated security group (`bkkrish007-task17-sg`) was created for the EC2 instance with the following ingress rules:

| Port | Protocol | Source | Purpose |
| :--- | :--- | :--- | :--- |
| `22` | TCP | `0.0.0.0/0` | SSH remote management |
| `2020` | TCP | `0.0.0.0/0` | Twenty CRM application web access |

*Outbound traffic (egress) was allowed unconditionally to enable package downloads, Docker image pulls, and security updates.*


## 8. Terraform Outputs

Terraform exports key instance identifiers upon provisioning:

| Output Variable | Description | Value |
| :--- | :--- | :--- |
| `instance_id` | EC2 Instance ID | `i-028c467809673114d` |
| `public_ip` | Public IPv4 Address | `44.198.188.223` |
| `public_dns` | Public DNS Hostname | `ec2-44-198-188-223.compute-1.amazonaws.com` |


## 9. Terraform Validation and Deployment

Terraform formatting and validation were executed:

```bash
terraform fmt
terraform validate
```

**Output:**
```text
Success! The configuration is valid.
```

The infrastructure was provisioned using:

```bash
terraform apply -auto-approve
```

**Output:**
```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-028c467809673114d"
public_dns = "ec2-44-198-188-223.compute-1.amazonaws.com"
public_ip = "44.198.188.223"
```


## 10. Ansible Inventory

After Terraform provisioned the EC2 instance, the public IP address was added to the Ansible inventory file `ansible/inventory.ini`:

```ini
[twenty]
44.198.188.223 ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/bkkrish007-key-task16.pem
```

This configuration enables Ansible to authenticate over SSH using the specified private key.


## 11. Ansible Connectivity Verification

Ansible connectivity was verified using the `ping` module:

```bash
ansible -i inventory.ini twenty -m ping
```

**Output:**
```text
44.198.188.223 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.14"
    },
    "changed": false,
    "ping": "pong"
}
```


## 12. Ansible Playbook

The Ansible playbook (`ansible/deploy-twenty.yml`) automates the full configuration and application deployment pipeline:

1. Gather host facts.
2. Update APT cache and perform package upgrades.
3. Install Docker, Docker Compose V2, and required dependencies.
4. Enable and start the Docker systemd service.
5. Add the `ubuntu` user to the `docker` group.
6. Create the application directory `/opt/twenty-crm`.
7. Generate the `docker-compose.yml` configuration file.
8. Deploy the Twenty CRM container using `community.docker.docker_compose_v2`.
9. Poll and verify the application health endpoint (`http://127.0.0.1:2020/healthz`).
10. Display the active Docker container status.
11. Display recent application logs.


## 13. Required Packages

The following packages were installed by Ansible:

- `docker.io` – Docker container engine
- `docker-compose-v2` – Docker Compose plugin
- `python3` – Python runtime environment
- `python3-pip` – Python package installer
- `python3-docker` – Docker Python SDK for Ansible modules
- `curl` – Command-line data transfer utility
- `wget` – Network file retrieval utility

Docker was enabled as a persistent system service to start automatically on system boot.


## 14. Application Directory

The application directory was created at:

```text
/opt/twenty-crm
```

The Docker Compose configuration was stored at:

```text
/opt/twenty-crm/docker-compose.yml
```


## 15. Twenty CRM Docker Configuration

Twenty CRM was deployed using the following configuration:

- **Docker Image**: `twentycrm/twenty-app-dev:latest`
- **Container Name**: `task17-twenty-server`
- **Port Mapping**: `2020:2020`


## 16. Environment Variables

The container was configured with the following environment variables:

```yaml
environment:
  PORT: "2020"
  SERVER_URL: "http://{{ ansible_host }}:2020"
  NODE_ENV: "development"
  STORAGE_TYPE: "local"
  APPLICATION_LOG_DRIVER: "CONSOLE"
```


## 17. Docker Volumes

Persistent Docker volumes were configured for persistent storage:

```yaml
volumes:
  - twenty-data:/data/postgres
  - twenty-storage:/app/packages/twenty-server/.local-storage
```

**Named Volumes:**
- `twenty-data` – Stores PostgreSQL database files.
- `twenty-storage` – Stores local media and application uploads.


## 18. Docker Health Check

A Docker health check was defined to verify the Twenty CRM HTTP `/healthz` endpoint:

```yaml
healthcheck:
  test:
    [
      "CMD-SHELL",
      "wget --no-verbose --tries=1 --spider http://127.0.0.1:2020/healthz || exit 1"
    ]
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 180s
```

The container status is marked `healthy` once the endpoint returns HTTP 200.


## 19. Docker Restart Policy

The container was configured with:

```yaml
restart: always
```

Runtime inspection confirmed:
- `Status` = `running`
- `Health` = `healthy`
- `RestartPolicy` = `always`

This ensures that the container starts automatically upon host reboots and recovers from unexpected process terminations.


## 20. Ansible Deployment Execution

The playbook was executed with:

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini deploy-twenty.yml
```

**Play Recap:**
```text
PLAY RECAP *********************************************************************
44.198.188.223             : ok=12   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

All playbook tasks completed successfully with zero unreachable hosts and zero failures.


## 21. Docker Container Verification

The running Docker container was verified on the EC2 instance:

```bash
docker ps --filter name=task17-twenty-server
```

**Output:**
```text
CONTAINER ID   IMAGE                             COMMAND                  CREATED          STATUS                    PORTS                                       NAMES
4f1a5249df2a   twentycrm/twenty-app-dev:latest   "/app/packages/twent…"   16 minutes ago   Up 16 minutes (healthy)   0.0.0.0:2020->2020/tcp, [::]:2020->2020/tcp   task17-twenty-server
```


## 22. Application Health Verification

The application health endpoint was verified externally using `curl`:

```bash
curl -s http://44.198.188.223:2020/healthz
```

**Response:**
```json
{
  "status": "ok",
  "info": {},
  "error": {},
  "details": {}
}
```

This confirms the application server initialized properly and is accepting incoming traffic.


## 23. Application Logs Verification

Application logs were verified using:

```bash
docker logs --tail 20 task17-twenty-server
```

**Sample Output:**
```text
WorkflowCronTriggerCronJob started
Found 1 active workspaces
WorkflowCronTriggerCronJob completed
WorkflowRunEnqueueCronJob processed
twenty-server successfully started
twenty-worker successfully started
```

The logs demonstrate that core background workers, cron schedulers, and server components are actively executing.


## 24. Final Deployment Architecture

```text
                       Internet / User Browser
                                  │
                                  │ (HTTP Port 2020 / SSH Port 22)
                                  ▼
                     ┌───────────────────────────┐
                     │      AWS EC2 Instance     │
                     │  t3.small | 20 GB (gp3)   │
                     │     Ubuntu 24.04 LTS      │
                     │  Public IP: 44.198.188.223│
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │       Docker Engine       │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │    Docker Compose Stack   │
                     │   (task17-twenty-server)  │
                     │                           │
                     │   • Port: 2020:2020       │
                     │   • Restart: always       │
                     │   • Health: /healthz      │
                     │   • Volumes: data/storage │
                     └───────────────────────────┘
```


## 25. Automation Flow

```text
┌────────────────────────────────────────────────────────┐
│ 1. Terraform (Infrastructure Provisioning)             │
│    • Define AWS Provider & Default VPC / Subnets       │
│    • Provision Security Group (Ports 22, 2020)         │
│    • Launch EC2 (t3.small, 20 GB gp3)                  │
│    • Output Public IP (44.198.188.223)                 │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Ansible Inventory Configuration                     │
│    • Populate inventory.ini with EC2 Public IP         │
│    • Verify SSH Connectivity with `ansible -m ping`    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Ansible Server Configuration & Setup                │
│    • Update APT cache & upgrade packages               │
│    • Install Docker, Docker Compose V2, & Python pkgs  │
│    • Enable & start Docker systemd service             │
│    • Add `ubuntu` user to `docker` group               │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Twenty CRM Container Deployment                     │
│    • Create /opt/twenty-crm directory                  │
│    • Render docker-compose.yml configuration           │
│    • Deploy Twenty CRM via docker_compose_v2           │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 5. Verification & Monitoring                           │
│    • Wait for /healthz endpoint (HTTP 200 OK)          │
│    • Verify container status (Up & Healthy)            │
│    • Inspect Twenty CRM runtime logs                   │
└────────────────────────────────────────────────────────┘
```


## 26. Challenges Encountered & Solutions

### 26.1 Root Disk Space Limitation
- **Problem:** The default EC2 root volume (~8 GB) was exhausted during Docker image extraction and dependency installation (`df -h` showed 100% disk utilization).
- **Solution:** The Terraform configuration was updated to provision a **20 GB gp3 encrypted root volume**, providing sufficient capacity for Docker images and container runtime layers.

### 26.2 Docker Permission Denied for Non-Root User
- **Problem:** Running Docker commands as the `ubuntu` user resulted in `permission denied while trying to connect to the Docker API socket`.
- **Solution:** Added an Ansible task to append the `ubuntu` user to the `docker` group:
  ```yaml
  - name: Add ubuntu user to Docker group
    ansible.builtin.user:
      name: ubuntu
      groups: docker
      append: true
  ```

### 26.3 SSH Host Key Verification
- **Problem:** When recreating the EC2 instance, the newly assigned public IP caused `Host key verification failed` errors due to stale entries in `~/.ssh/known_hosts`.
- **Solution:** Stale host keys were cleared and `ANSIBLE_HOST_KEY_CHECKING=False` was passed during playbook execution.

### 26.4 Application Health Check Timeout
- **Problem:** The initial deployment playbook encountered an escalation timeout while waiting for Twenty CRM to finish first-time database migrations.
- **Solution:** Configured appropriate retry count (`retries: 30`) and delay (`delay: 10`) parameters on the `uri` module, allowing sufficient time for Twenty CRM service startup.


## 27. Verification Summary

| Component / Step | Verification Method | Result | Status |
| :--- | :--- | :--- | :--- |
| **Terraform Validation** | `terraform validate` | Configuration is valid | Passed |
| **Infrastructure Provisioning** | `terraform apply` | 2 resources added | Passed |
| **EC2 Instance Creation** | AWS Console / Terraform Output | `i-028c467809673114d` running | Passed |
| **SSH Connectivity** | `ansible -m ping` | Ping / Pong response | Passed |
| **Docker Engine** | `systemctl is-active docker` | Active (Running) | Passed |
| **Docker Compose Deployment** | `community.docker.docker_compose_v2` | Stack deployed | Passed |
| **Container Status** | `docker ps` | `Up 16 minutes (healthy)` | Passed |
| **Restart Policy** | Container inspection | `RestartPolicy=always` | Passed |
| **Health Check Endpoint** | `curl /healthz` | `{"status":"ok"}` | Passed |
| **Application Logs** | `docker logs` | Background workers active | Passed |
| **Ansible Playbook Run** | `ansible-playbook` | `failed=0, unreachable=0` | Passed |


## 28. Final Result

Task 17 successfully implemented an automated, end-to-end Infrastructure as Code and Configuration Management workflow:
1. **Terraform** provisioned the EC2 compute instance with custom security rules and an expanded 20 GB gp3 root disk.
2. **Ansible** automated server configuration, dependency installation, Docker configuration, and Twenty CRM container orchestration.
3. **Twenty CRM** was verified running with Docker health checks and restart policies enabled, returning `{"status": "ok"}` on `http://44.198.188.223:2020/healthz`.


## 29. Cleanup

To prevent unnecessary cloud billing after testing and verification are complete, the provisioned AWS infrastructure can be destroyed with:

```bash
cd task17/terraform
terraform destroy -auto-approve
```
