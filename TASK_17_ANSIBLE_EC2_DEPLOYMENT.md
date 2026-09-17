# Task 17 — Ansible and AWS EC2 Deployment

## Objective

Deploy Twenty CRM on an AWS EC2 instance using Terraform and Ansible.

The deployment includes:

* AWS EC2 instance provisioning using Terraform
* Twenty CRM Docker container
* PostgreSQL database container
* Redis container
* Docker networking
* Application environment configuration
* Ansible-based server configuration and deployment
* Application health check
* Docker container status verification
* Application log verification
* Terraform resource cleanup

---

## 1. AWS Infrastructure Provisioning

Terraform was used to provision the EC2 infrastructure.

### Configuration

* AWS Region: `us-east-1`
* Instance Type: `t3.small`
* AMI: `ami-0b6d9d3d33ba97d99`
* VPC: Default VPC
* Subnet: Default VPC subnet
* Root Volume: 20 GB GP3
* SSH Key Pair: `tannu-task16-key`

A security group was created with:

* Port `22` for SSH/Ansible access
* Port `3000` for Twenty CRM
* Outbound traffic allowed

Terraform configuration was validated before deployment using:

```bash
terraform fmt -recursive
terraform validate
```

The infrastructure was then created using:

```bash
terraform apply
```

Terraform provisioned the EC2 instance successfully.

---

## 2. EC2 Instance

The EC2 instance was created successfully in `us-east-1`.

The instance was configured with:

```text
Instance Type: t3.small
AMI: ami-0b6d9d3d33ba97d99
```

The public IP generated for the deployment was used as the Ansible target.

---

## 3. Ansible Setup

Ansible was installed and configured inside Ubuntu WSL.

The installed version was verified using:

```bash
ansible --version
```

Ansible inventory was created at:

```text
ansible/inventory.ini
```

The inventory configured the EC2 host as:

```ini
[twenty_crm]
twenty-server ansible_host=<EC2_PUBLIC_IP>

[twenty_crm:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/tannu/.ssh/tannu-task16-key.pem
```

SSH connectivity was verified before running the deployment.

Ansible ping was used to confirm connectivity:

```bash
ansible -i inventory.ini twenty_crm -m ping
```

The host responded successfully with:

```text
"ping": "pong"
```

---

## 4. Ansible Playbook

The deployment playbook was created at:

```text
ansible/playbook.yml
```

The playbook performs the following operations.

### Server Package Update

The EC2 server packages are updated using Ansible:

```yaml
apt:
  update_cache: true
  upgrade: dist
```

### Required Packages

Docker and required utilities are installed:

```text
docker.io
curl
ca-certificates
```

### Docker Service

Docker is started and configured to start automatically:

```yaml
systemd:
  name: docker
  state: started
  enabled: true
```

The Ubuntu user is also added to the Docker group.

---

## 5. Application Directory

An application directory was created:

```text
/opt/twenty-crm
```

This directory is used for the Twenty CRM environment configuration.

---

## 6. Docker Images

The following Docker images were pulled:

```text
twentycrm/twenty:latest
postgres:16
redis:latest
```

A dedicated Docker network was also created:

```text
twenty-network
```

This allows Twenty CRM to communicate with PostgreSQL and Redis using their container names.

---

## 7. PostgreSQL Deployment

PostgreSQL was deployed as a Docker container:

```text
Container: twenty-postgres
Image: postgres:16
```

The database configuration used:

```text
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=default
```

A persistent Docker volume was configured for PostgreSQL data:

```text
twenty-postgres-data
```

The playbook waits for the PostgreSQL container to be running before starting Twenty CRM.

---

## 8. Redis Deployment

Redis was deployed as:

```text
Container: twenty-redis
Image: redis:latest
```

Redis was configured with:

```text
--maxmemory-policy noeviction
```

A persistent Docker volume was configured:

```text
twenty-redis-data
```

The playbook verifies that Redis is running before starting Twenty CRM.

---

## 9. Twenty CRM Environment Configuration

The Twenty CRM environment was configured with:

```text
NODE_PORT=3000
SERVER_URL=http://<EC2_PUBLIC_IP>:3000
PG_DATABASE_URL=postgres://postgres:postgres@twenty-postgres:5432/default
REDIS_URL=redis://twenty-redis:6379
STORAGE_TYPE=local
ENCRYPTION_KEY=<configured-encryption-key>
```

The PostgreSQL and Redis container names are used in the connection URLs because all containers are connected to the same Docker network.

---

## 10. Twenty CRM Deployment

Twenty CRM was started using the Docker image:

```text
twentycrm/twenty:latest
```

The container was named:

```text
twenty-crm
```

Port mapping:

```text
3000:3000
```

A Docker restart policy was configured:

```text
unless-stopped
```

This allows the container to automatically restart unless it has been explicitly stopped.

---

## 11. Health Check

After starting Twenty CRM, the Ansible playbook checks the application health endpoint:

```text
http://127.0.0.1:3000/healthz
```

The playbook retries the health check until the application becomes available.

The health check eventually completed successfully.

---

## 12. Deployment Verification

Docker container status was displayed using:

```bash
docker ps -a
```

The final deployment showed the following containers running:

```text
twenty-crm
twenty-redis
twenty-postgres
```

Twenty CRM was running with port mapping:

```text
0.0.0.0:3000->3000/tcp
```

The application logs were also collected using:

```bash
docker logs --tail 50 twenty-crm
```

The logs showed successful application startup:

```text
Nest application successfully started
```

The Ansible playbook also confirmed:

```text
Twenty CRM is running successfully on http://<EC2_PUBLIC_IP>:3000
```

The final Ansible recap showed:

```text
failed=0
unreachable=0
```

---

## 13. Browser Verification

Twenty CRM was accessed through the EC2 public IP:

```text
http://<EC2_PUBLIC_IP>:3000
```

The Twenty CRM application successfully opened in the browser, confirming that the deployment was accessible externally.

---

## 14. Infrastructure Cleanup

After completing the deployment verification, the AWS resources were removed as required.

Terraform destroy was executed using:

```bash
terraform destroy
```

The final Terraform output confirmed:

```text
Destroy complete! Resources: 2 destroyed.
```

This removed the Task 17 EC2 instance and its associated security group.

---

## 15. Project Structure

The Task 17 implementation contains:

```text
ansible/
├── inventory.ini
├── playbook.yml
└── group_vars/

terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── alb.tf
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Result

Twenty CRM was successfully deployed on an AWS EC2 instance using Terraform and Ansible.

The deployment included:

* EC2 provisioning
* Docker installation
* PostgreSQL
* Redis
* Twenty CRM
* Docker networking
* Environment configuration
* Restart policy
* Health check
* Container verification
* Application log verification
* Browser verification
* Terraform cleanup
