# Task 17: AWS EC2 Deployment using Terraform and Ansible  
**Name:** P. Harish
**Date:** 17 September 2026
**PR link:** [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/409]
**Loom link:** [https://drive.google.com/file/d/1DCjpVtYtD6vKZ89j6ZEx9NmH-TN9AUi3/view?usp=drive_link]
## Objective

- Create an AWS EC2 instance using Terraform.
- Configure the EC2 server using Ansible.
- Deploy Twenty CRM using Docker.
- Configure restart policy and health checks.
- Verify the application, containers, and logs.

## AWS Configuration

- Region: `us-east-1`
- Instance Type: `t3.small`
- AMI: `ami-0b6d9d3d33ba97d99`
- VPC: Default VPC
- Subnet: Default VPC subnet
- Root Volume: 20 GB gp3

## Terraform

Terraform was used to create the EC2 infrastructure.

Created resources:

- EC2 instance
- Security Group
- SSH Key Pair
- Generated PEM file
- Default VPC and subnet were used through data sources

Terraform commands used:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

EC2 public IP:

```
44.211.96.185
```

## Ansible

Ansible was used to configure the EC2 instance and deploy Twenty CRM.

Inventory:

```
[twenty]
44.211.96.185 ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/twenty-crm-task17.pem
```

The playbook performs the following:

- Updates APT packages
- Installs Docker
- Installs Docker dependencies
- Installs Git and curl
- Starts and enables Docker
- Creates `/opt/twenty`
- Clones the `harish-task17` branch
- Creates the Twenty CRM `.env` file
- Deploys the Docker Compose services
- Waits for the application health check
- Displays Docker container status
- Displays Twenty CRM logs
- Verifies the application is running

## Docker Deployment

The deployment contains:

- Twenty CRM server
- PostgreSQL 16
- Redis 7

The application is exposed on:

```
Port: 3000
```

Docker services were verified using:

```bash
sudo docker compose ps
```

PostgreSQL and Redis were healthy, and Twenty CRM was running with its health check.

## Restart Policy

Twenty CRM uses:

```
restart: unless-stopped
```

The restart policy was verified with:

```bash
sudo docker inspect twenty-twenty-server-1 --format '{{.HostConfig.RestartPolicy.Name}}'
```

Output:

```
unless-stopped
```

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}}' twenty-twenty-server-1
```
The restart count increased after the failure test.

Example:

>>running RestartCount=1

The restart behavior was tested by sending SIGTERM to the main process:

```bash
sudo docker exec twenty-twenty-server-1 sh -c 'kill -TERM 1'
```

The container automatically started again.

## Health Check

Twenty CRM has a Docker health check configured for:

```
http://localhost:3000/healthz
```

The container was observed returning to:

```
Up (health: starting)
```

and then becoming healthy after startup.

## Application Verification

The application was tested on the EC2 instance using:

```bash
curl -I http://localhost:3000
```

The application returned:

```
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was responding successfully.


##Logs verification

Application logs were displayed using:

```bash
sudo docker compose logs --tail=50

or

sudo docker compose logs --tail=50 twenty-server
```

The logs showed that the Twenty CRM server started successfully.


## Conclusion

Task 17 demonstrated infrastructure creation with Terraform and server configuration and application deployment using Ansible and Docker. Twenty CRM was successfully started on the EC2 instance, its restart policy and health check were tested, and the application responded successfully with HTTP 200.