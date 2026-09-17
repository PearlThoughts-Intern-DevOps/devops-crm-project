# Task 17: Ansible and AWS EC2 Deployment

## 1. Overview & Objectives

The objective of this task is to automate the deployment of Twenty CRM on an AWS EC2 instance using **Terraform** for infrastructure provisioning and **Ansible** for configuration management and container orchestration.

Key requirements fulfilled:
- Provisioned one EC2 instance (`t3.small`) using Terraform in region `us-east-1` with Ubuntu 26.04 AMI in the default VPC and subnet.
- Added the EC2 public IP to the Ansible inventory.
- Created and executed an Ansible playbook to:
  - Update server packages.
  - Install Docker and its required dependencies.
  - Configure 2GB swap space for memory resilience on `t3.small`.
  - Create required application directories.
  - Configure Twenty CRM environment variables.
  - Deploy Twenty CRM using Docker with a restart policy (`unless-stopped`) and a container health check.
  - Start the application and verify that Twenty CRM is running.
  - Display the Docker container status and application logs.
- Verified end-to-end deployment via HTTP health check probes.
- Cleanly destroyed the EC2 instance using Terraform after task completion.

---

## 2. Infrastructure Specifications

| Parameter | Value | Details |
| :--- | :--- | :--- |
| **Cloud Provider** | AWS | Region: `us-east-1` |
| **VPC** | Default VPC (`vpc-0c241509159132524`) | CIDR: `172.31.0.0/16` |
| **Subnet** | Default Subnet (`subnet-078d52bfe579c74f2`) | Availability Zone: `us-east-1a` |
| **Instance ID** | `i-02a532c4b04515450` | Provisioned and Terminated via Terraform |
| **Instance Type** | `t3.small` | 2 vCPU, 2GB RAM |
| **AMI ID** | `ami-0b6d9d3d33ba97d99` | Canonical Ubuntu 26.04 LTS (Resolute Raccoon) |
| **Public IP** | `44.197.229.112` | Public IPv4 assigned to the instance |
| **Public DNS** | `ec2-44-197-229-112.compute-1.amazonaws.com` | AWS DNS Hostname |
| **Security Group** | `sg-06de0f7638ecd9946` | Ports 22 (SSH), 2020 (Twenty CRM), 80 (HTTP) |
| **Key Pair** | `mohit-task17-key` | SSH ED25519 Key Pair |
| **Docker Image** | `twentycrm/twenty-app-dev:latest` | Twenty CRM Development Container |
| **Port Mapping** | `2020:2020` | Host port mapped to container port |
| **Restart Policy** | `unless-stopped` | Automatic recovery on reboot or unexpected stop |
| **Health Check** | `curl -f http://localhost:2020/healthz` | Interval: 20s, Timeout: 10s, Retries: 15, Start: 60s |

---

## 3. Terraform Infrastructure Provisioning

The infrastructure is defined across the configuration files in [`task-17/terraform/`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform):
- [`provider.tf`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform/provider.tf): Configures AWS provider `~> 5.92` in `us-east-1`.
- [`variables.tf`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform/variables.tf): Variable declarations for region, instance type, AMI ID, ports, and key paths.
- [`main.tf`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform/main.tf): Queries default VPC/subnet and provisions the key pair, security group, and EC2 instance.
- [`outputs.tf`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform/outputs.tf): Exports the instance ID, public IP, DNS, Twenty CRM URL, and Ansible inventory line.
- [`terraform.tfvars`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/terraform/terraform.tfvars): Input variable values.

### 3.1 Terraform Apply Output

```bash
$ terraform -chdir=task-17/terraform apply -auto-approve

Terraform used the selected providers to generate the execution plan.
Plan: 3 to add, 0 to change, 0 to destroy.

aws_key_pair.task17_key: Creating...
aws_security_group.twenty_crm_sg: Creating...
aws_security_group.twenty_crm_sg: Creation complete after 5s [id=sg-06de0f7638ecd9946]
aws_key_pair.task17_key: Creation complete after 0s [id=mohit-task17-key]
aws_instance.twenty_crm: Creating...
aws_instance.twenty_crm: Still creating... [10s elapsed]
aws_instance.twenty_crm: Creation complete after 16s [id=i-02a532c4b04515450]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
ansible_inventory_line = "twenty-node-1 ansible_host=44.197.229.112 ansible_user=ubuntu"
instance_id = "i-02a532c4b04515450"
instance_public_dns = "ec2-44-197-229-112.compute-1.amazonaws.com"
instance_public_ip = "44.197.229.112"
key_name = "mohit-task17-key"
security_group_id = "sg-06de0f7638ecd9946"
ssh_command = "ssh -i ~/.ssh/id_ed25519.pub ubuntu@44.197.229.112"
twenty_crm_url = "http://44.197.229.112:2020"
```

---

## 4. Ansible Inventory & Configuration

The EC2 public IP (`44.197.229.112`) was placed into the inventory file [`task-17/ansible/inventory.ini`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/ansible/inventory.ini). Ansible connection and escalation settings are configured in [`task-17/ansible/ansible.cfg`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/ansible/ansible.cfg).

### 4.1 Connectivity Verification

```bash
$ ansible -i inventory.ini all -m ping
twenty-node-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## 5. Ansible Playbook Execution

The playbook [`task-17/ansible/playbook.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/task-17/ansible/playbook.yml) executes the following tasks sequentially:
1. Waits for SSH readiness and gathers target system facts.
2. Allocates and activates 2GB of swap space (`/swapfile`) to prevent OOM errors on `t3.small`.
3. Updates the APT package cache.
4. Installs required Docker dependencies and tools (`apt-transport-https`, `ca-certificates`, `curl`, `gnupg`, `lsb-release`, `python3-docker`, `python3-pip`).
5. Installs Docker Engine (`docker.io`, `docker-compose-v2`), starts and enables the systemd service, and adds the `ubuntu` user to the `docker` group.
6. Creates required application directories: `/opt/twenty`, `/opt/twenty/data`, and `/opt/twenty/config`.
7. Configures Twenty CRM environment variables in `/opt/twenty/.env`.
8. Deploys the Twenty CRM container using `community.docker.docker_container` with `restart_policy: unless-stopped` and container health check configured.
9. Polls the health endpoint (`http://127.0.0.1:2020/healthz`) until HTTP 200 is confirmed.
10. Queries and displays the Docker container status (`docker ps` and `docker inspect`).
11. Displays Twenty CRM application logs (`docker logs`).

### 5.1 Playbook Execution Log

```bash
$ ansible-playbook -i inventory.ini playbook.yml

PLAY [Task 17 - Configure EC2 Instance and Deploy Twenty CRM via Ansible] ******

TASK [Wait for EC2 instance SSH connection to become ready] ********************
ok: [twenty-node-1]

TASK [Gather system facts] *****************************************************
ok: [twenty-node-1]

TASK [Check if swapfile exists] ************************************************
ok: [twenty-node-1]

TASK [Create 2GB swapfile for t3.small memory optimization] ********************
changed: [twenty-node-1]

TASK [Set correct permissions on swapfile] *************************************
changed: [twenty-node-1]

TASK [Format swapfile as swap space] *******************************************
changed: [twenty-node-1]

TASK [Enable swap space] *******************************************************
changed: [twenty-node-1]

TASK [Persist swap entry in /etc/fstab] ****************************************
changed: [twenty-node-1]

TASK [Update apt package index] ************************************************
changed: [twenty-node-1]

TASK [Install required Docker dependencies and system tools] *******************
changed: [twenty-node-1]

TASK [Install Docker Engine and Compose plugin] ********************************
changed: [twenty-node-1]

TASK [Ensure Docker service is enabled and running] ****************************
ok: [twenty-node-1]

TASK [Add ubuntu user to docker group] *****************************************
changed: [twenty-node-1]

TASK [Create required application directories] *********************************
changed: [twenty-node-1] => (item=/opt/twenty)
changed: [twenty-node-1] => (item=/opt/twenty/data)
changed: [twenty-node-1] => (item=/opt/twenty/config)

TASK [Configure Twenty CRM environment variables (.env)] ***********************
changed: [twenty-node-1]

TASK [Template docker-compose.yml configuration] *******************************
changed: [twenty-node-1]

TASK [Pull Twenty CRM Docker image] ********************************************
changed: [twenty-node-1]

TASK [Deploy Twenty CRM container with restart policy and healthcheck] *********
changed: [twenty-node-1]

TASK [Wait for Twenty CRM HTTP health endpoint to return HTTP 200] *************
ok: [twenty-node-1]

TASK [Verify Twenty CRM root web interface responds] ***************************
ok: [twenty-node-1]

TASK [Query Docker container status] *******************************************
ok: [twenty-node-1]

TASK [Query container health inspection] ***************************************
ok: [twenty-node-1]

TASK [Display Docker Container Status] *****************************************
ok: [twenty-node-1] => {
    "msg": [
        "===============================================================",
        "                  DOCKER CONTAINER STATUS                      ",
        "===============================================================",
        [
            "CONTAINER ID   NAMES        STATUS                   PORTS",
            "21f40baa88af   twenty-crm   Up 8 minutes (healthy)   0.0.0.0:2020->2020/tcp"
        ],
        "Container Health Status: \"healthy\"",
        "==============================================================="
    ]
}

TASK [Query Twenty CRM application logs] ***************************************
ok: [twenty-node-1]

TASK [Display Twenty CRM Application Logs] *************************************
ok: [twenty-node-1] => {
    "msg": [
        "===============================================================",
        "                TWENTY CRM APPLICATION LOGS                    ",
        "===============================================================",
        [
            "[Nest] 571  - LOG [BullMQDriver] Job repeat:WorkflowCronTriggerCronJob processed on queue cron-queue",
            "[Nest] 571  - LOG [BullMQDriver] Job repeat:WorkflowRunEnqueueCronJob processed on queue cron-queue",
            "[Nest] 571  - LOG [BullMQDriver] Job repeat:CronTriggerCronJob processed on queue cron-queue"
        ],
        "==============================================================="
    ]
}

TASK [Display Deployment Verification Summary] *********************************
ok: [twenty-node-1] => {
    "msg": [
        "===============================================================",
        "        TASK 17 TWENTY CRM DEPLOYMENT COMPLETE                 ",
        "===============================================================",
        "Target Host:       twenty-node-1 (44.197.229.112)",
        "Public Web URL:    http://44.197.229.112:2020",
        "Health Check URL:  http://44.197.229.112:2020/healthz",
        "Restart Policy:    unless-stopped",
        "Container State:   21f40baa88af   twenty-crm   Up 8 minutes (healthy)   0.0.0.0:2020->2020/tcp",
        "Healthcheck State: \"healthy\"",
        "Health HTTP Code:  200",
        "Root HTTP Code:    200",
        "==============================================================="
    ]
}

PLAY RECAP *********************************************************************
twenty-node-1              : ok=26   changed=14   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### 5.2 Idempotency Verification

A second execution of the playbook confirmed full idempotency:

```bash
PLAY RECAP *********************************************************************
twenty-node-1              : ok=23   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

---

## 6. Deployment Verification & Evidence

### 6.1 Docker Container Status

```bash
$ ssh -i ~/.ssh/id_ed25519 ubuntu@44.197.229.112 "docker ps -a"

CONTAINER ID   IMAGE                             COMMAND   CREATED         STATUS                   PORTS                    NAMES
21f40baa88af   twentycrm/twenty-app-dev:latest   "/init"   9 minutes ago   Up 9 minutes (healthy)   0.0.0.0:2020->2020/tcp   twenty-crm
```

### 6.2 Restart Policy & Healthcheck Inspection

```bash
$ ssh -i ~/.ssh/id_ed25519 ubuntu@44.197.229.112 "docker inspect --format 'RestartPolicy: {{json .HostConfig.RestartPolicy}} | HealthStatus: {{json .State.Health.Status}}' twenty-crm"

RestartPolicy: {"Name":"unless-stopped","MaximumRetryCount":0} | HealthStatus: "healthy"
```

Healthcheck probe output:

```json
{
  "Status": "healthy",
  "FailingStreak": 0,
  "Log": [
    {
      "Start": "2026-09-17T06:55:20.448611858Z",
      "End": "2026-09-17T06:55:20.601297502Z",
      "ExitCode": 0,
      "Output": "{\"status\":\"ok\",\"info\":{},\"error\":{},\"details\":{}}"
    }
  ]
}
```

### 6.3 External HTTP Endpoint Verification

Testing the `/healthz` endpoint:

```bash
$ curl -s -w "\nHTTP Status: %{http_code}\nTotal Time: %{time_total}s\n" http://44.197.229.112:2020/healthz

{"status":"ok","info":{},"error":{},"details":{}}
HTTP Status: 200
Total Time: 0.403262s
```

Testing the root `/` web interface:

```bash
$ curl -s -w "\nHTTP Status: %{http_code}\nContent Type: %{content_type}\n" http://44.197.229.112:2020/ | head -n 12

<!doctype html>
<html lang="en" translate="no" class="light">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/x-icon" href="/images/icons/android/android-launchericon-48-48.png" data-rh="true" />
    <link rel="apple-touch-icon" href="/images/icons/ios/192.png" />
    <link rel="manifest" href="/manifest.json" />
    <meta name="theme-color" content="#000000" />
HTTP Status: 200
Content Type: text/html; charset=utf-8
```

### 6.4 Host Memory & Swap Space Verification

```bash
$ ssh -i ~/.ssh/id_ed25519 ubuntu@44.197.229.112 "free -m"

               total        used        free      shared  buff/cache   available
Mem:            1905        1549         189          27         437         356
Swap:           2047         865        1182
```

---

## 7. Infrastructure Teardown via Terraform

Upon successful deployment and validation, all provisioned infrastructure resources were destroyed using Terraform.

### 7.1 Terraform Destroy Log

```bash
$ terraform -chdir=task-17/terraform destroy -auto-approve

Plan: 0 to add, 0 to change, 3 to destroy.

aws_instance.twenty_crm: Destroying... [id=i-02a532c4b04515450]
aws_instance.twenty_crm: Still destroying... [id=i-02a532c4b04515450, 10s elapsed]
aws_instance.twenty_crm: Still destroying... [id=i-02a532c4b04515450, 20s elapsed]
aws_instance.twenty_crm: Still destroying... [id=i-02a532c4b04515450, 30s elapsed]
aws_instance.twenty_crm: Destruction complete after 32s
aws_key_pair.task17_key: Destroying... [id=mohit-task17-key]
aws_security_group.twenty_crm_sg: Destroying... [id=sg-06de0f7638ecd9946]
aws_key_pair.task17_key: Destruction complete after 0s
aws_security_group.twenty_crm_sg: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.
```

### 7.2 Cloud State Confirmation

```bash
$ aws ec2 describe-instances --instance-ids i-02a532c4b04515450 --region us-east-1 --query "Reservations[0].Instances[0].State.Name"
"terminated"
```

---

## 8. Conclusion

All requirements for Task 17 were completed:
- An EC2 instance was provisioned via Terraform with the specified AMI, instance type, and networking.
- The public IP was mapped into the Ansible inventory.
- An Ansible playbook configured the instance, Docker daemon, dependencies, swap space, and application environment, deploying Twenty CRM with the restart policy and health checks.
- Application status and logs were verified with HTTP 200 responses confirmed.
- All AWS infrastructure was destroyed via Terraform, and all code and documentation were saved to branch `mohit-task17`.
