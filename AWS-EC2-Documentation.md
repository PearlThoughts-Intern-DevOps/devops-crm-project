# Task 7: AWS EC2

## Objective

The objective of this task was to launch and configure an AWS EC2 instance, connect to it using SSH, perform the required server setup, deploy Twenty CRM using Docker Compose, verify the deployment, and document the complete process.

---

## 1. AWS Console Login

- Logged in to the provided AWS account using the credentials shared through email.
- Verified that I was able to access the AWS Management Console.
- Selected the AWS region:

`us-east-1 (N. Virginia)`

---

## 2. Launching the EC2 Instance

Steps followed:

1. Opened AWS Console.
2. Searched for and opened **EC2**.
3. From the EC2 dashboard, selected **Instances**.
4. Clicked **Launch instance**.
5. Instance name: `tannu-task-7`

### AMI

Selected:

`Amazon Linux 2023 AMI`

### Instance Type

Initially attempted to use `t3.micro`, but the launch failed because the account did not have permission for the required EC2 RunInstances operation.

As instructed by the support team, I changed the instance type to:

`t3.small`

The instance then launched successfully.

### Key Pair

Created a new key pair:

- Key pair name: `tannu-task-7-key`
- Key pair type: RSA
- Private key file format: `.pem`

The `.pem` private key was downloaded and kept securely for SSH access.

### Network Configuration

- Auto-assign Public IP: Enabled
- Existing Security Group: `launch-wizard-19`

### Storage

Used the default storage configuration.

The EC2 instance was launched successfully.

---

## 3. EC2 Instance Details

The launched instance had the following configuration:

- Instance Name: `tannu-task-7`
- Instance Type: `t3.small`
- Operating System: Amazon Linux 2023
- Region: `us-east-1`
- Key Pair: `tannu-task-7-key`
- Public IPv4: `100.52.234.118`
- Security Group: `launch-wizard-19`

---
## 4. Connecting to EC2 Using SSH

The downloaded `.pem` key was copied into the WSL home directory.

The key permissions were restricted using:

```bash
chmod 400 ~/tannu-task-7-key.pem
```

The EC2 instance was accessed using:

```bash
ssh -i ~/tannu-task-7-key.pem ec2-user@100.52.234.118
```

After accepting the host authenticity prompt, the SSH connection was established successfully.

The EC2 shell was:

```text
[ec2-user@ip-172-31-20-207 ~]$
```

## 5. Verifying EC2 Resources

### Operating System and Kernel

```bash
uname -a
```

This was used to verify the operating system, kernel version, architecture, and EC2 host information.

### CPU

```bash
lscpu | grep -E 'CPU\(s\)|Model name'
```

This was used to verify the CPU configuration.

The instance provided 2 CPUs.

### RAM

```bash
free -h
```

This was used to check the available memory.

### Disk

```bash
df -h
```

This was used to check the available disk space.

## 6. Installing Docker

Docker was not initially installed on the EC2 instance.

Verified using:

```bash
docker --version
```

Docker was installed using:

```bash
sudo dnf install -y docker
```

The Docker service was enabled and started using:

```bash
sudo systemctl enable --now docker
```

To allow the ec2-user to use Docker:

```bash
sudo usermod -aG docker ec2-user
```

The updated group permission was applied using:

```bash
newgrp docker
```

Docker was then verified using:

```bash
docker ps
```

Docker was working successfully.

## 7. Installing Git

Git was not initially installed on the EC2 instance.

Installed Git using:

```bash
sudo dnf install -y git
```

Verified the installation using:

```bash
git --version
```

## 8. Getting the Project Repository

The shared devops-crm-project repository was cloned from the PearlThoughts GitHub repository.

The required Task 7 branch was created and checked out:

```text
tannu-task-7
```

The branch contains the previous project work required for the deployment.

## 9. Installing Docker Compose

Docker Compose standalone binary was installed using:

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
```

Docker Compose was then used for the Twenty CRM deployment.

## 10. Twenty CRM Self-Hosted Deployment

A separate directory was created for the official Twenty CRM self-hosted deployment so that the existing project Docker Compose configuration was not modified.

Directory:

```text
~/twenty-self-hosted
```

The official Twenty CRM environment file was downloaded:

```bash
curl -o .env https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/.env.example
```

### Encryption Key

A random encryption key was generated and saved in .env:

```bash
KEY=$(openssl rand -base64 32) && sed -i "s|^# ENCRYPTION_KEY=.*|ENCRYPTION_KEY=$KEY|" .env
```

### PostgreSQL Password

A random PostgreSQL password was generated and saved in .env:

```bash
PGPASS=$(openssl rand -hex 16) && sed -i "s|^#PG_DATABASE_PASSWORD=.*|PG_DATABASE_PASSWORD=$PGPASS|" .env
```

The required PostgreSQL configuration was enabled:

```bash
sed -i 's/^#PG_DATABASE_USER=/PG_DATABASE_USER=/' .env
sed -i 's/^#PG_DATABASE_HOST=/PG_DATABASE_HOST=/' .env
sed -i 's/^#PG_DATABASE_PORT=/PG_DATABASE_PORT=/' .env
sed -i 's/^#PG_DATABASE_NAME=/PG_DATABASE_NAME=/' .env
```

Redis configuration was enabled:

```bash
sed -i 's/^#REDIS_URL=/REDIS_URL=/' .env
```

The server URL was configured using the EC2 public IP:

```bash
sed -i 's|^SERVER_URL=.*|SERVER_URL=http://100.52.234.118:3000|' .env
```

## 11. Official Twenty Docker Compose Configuration

The official Twenty CRM Docker Compose file was downloaded:

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/docker-compose.yml
```

The existing devops-crm-project Docker Compose file was not modified.

The downloaded Compose configuration was validated using:

```bash
docker-compose config
```

The configuration included the main Twenty CRM server, worker, PostgreSQL database, Redis, persistent volumes, and required environment variables.

## 12. Starting Twenty CRM

Twenty CRM was started using:

```bash
docker-compose up -d
```

The first startup downloaded the required Docker images and created the required containers, network, and persistent volumes.

During the initial startup, the server temporarily appeared unhealthy and the worker did not remain started.

Server logs were checked using:

```bash
docker-compose logs --tail=50 server
```

The logs did not show a fatal application error.

The server health endpoint was checked using:

```bash
curl -i http://localhost:3000/healthz
```

The endpoint returned:

```text
HTTP/1.1 200 OK
```

This confirmed that the Twenty CRM server was healthy.

The services were started again using:

```bash
docker-compose up -d
```

After this, the worker also started successfully.

Final service status:



PostgreSQL: Healthy  
Redis: Healthy  
Twenty CRM Server: Healthy  
Twenty CRM Worker: Started  

## 13. Security Group Configuration

Initially, the Twenty CRM server was running on port 3000, but the application could not be accessed from the laptop browser.

The issue was resolved by allowing inbound TCP traffic on port 3000 in the EC2 Security Group.

AWS Console path:

```text
EC2
→ Instances
→ tannu-task-7
→ Security
→ Security Groups
→ launch-wizard-19
→ Inbound rules
→ Edit inbound rules
→ Add rule
```

Rule added:

```text
Type: Custom TCP
Port: 3000
Source: 0.0.0.0/0
Description: Twenty CRM
```

After saving the rule, Twenty CRM became accessible from the browser.

## 14. Accessing Twenty CRM

Twenty CRM was successfully accessed from the browser using:

```text
http://100.52.234.118:3000
```

A fresh Twenty CRM workspace was created and the application loaded successfully.

The browser showed a "Not secure" warning because the deployment was accessed using HTTP rather than HTTPS. This was a temporary setup for the internship task and should not be used for sensitive production data without proper HTTPS configuration.

## 15. Issues Faced and Solutions

### Issue 1: t3.micro launch failed

**Problem:**

The initial EC2 launch using t3.micro failed due to an EC2 RunInstances permission issue.

**Solution:**

Changed the instance type to t3.small as instructed by the support team. The instance launched successfully.

### Issue 2: Docker was not installed

**Problem:**

Running:

```bash
docker --version
```

showed that Docker was not available.

**Solution:**

Installed Docker using:

```bash
sudo dnf install -y docker
```

Then enabled and started the service.

### Issue 3: Docker permission for ec2-user

**Problem:**

The Docker command required appropriate permissions for the EC2 user.

**Solution:**

Added ec2-user to the Docker group:

```bash
sudo usermod -aG docker ec2-user
```

Then applied the group permission:

```bash
newgrp docker
```

### Issue 4: Git was not installed

**Problem:**

Git was initially unavailable on the EC2 instance.

**Solution:**

Installed Git:

```bash
sudo dnf install -y git
```

### Issue 5: Twenty CRM was initially inaccessible from browser

**Problem:**

Twenty CRM was running on port 3000, but accessing the EC2 public IP from the laptop resulted in a connection timeout.

**Solution:**

Added an inbound Custom TCP rule for port 3000 to the EC2 Security Group.

After saving the rule, the application became accessible.

### Issue 6: Twenty CRM server initially appeared unhealthy

**Problem:**

During the first `docker-compose up -d`, the server temporarily showed an unhealthy/dependency status.

**Solution:**

Checked the server logs and health endpoint:

```bash
docker-compose logs --tail=50 server
```

and:

```bash
curl -i http://localhost:3000/healthz
```

The health endpoint returned HTTP 200 OK, confirming that the server was functioning correctly.

Running:

```bash
docker-compose up -d
```

again started the remaining worker service successfully.

## 16. EC2 Concepts Learned

### EC2 Instance

An EC2 instance is a virtual server provided by AWS that can be configured with a selected operating system, CPU, memory, storage, and networking configuration.

### AMI

An Amazon Machine Image (AMI) provides the operating system and initial software configuration used when launching an EC2 instance.

### Instance Type

The instance type determines the compute resources available to the EC2 instance.

For this task:

```text
t3.small
```

was used.

### Key Pair

The key pair is used for secure SSH access to the EC2 instance.

The private .pem key must be kept secure.

### Security Group

A Security Group acts as a virtual firewall controlling inbound and outbound network traffic for the EC2 instance.

For this deployment, TCP port 3000 was allowed so that Twenty CRM could be accessed through the browser.

### Public IP

The EC2 public IPv4 address allows the instance to be accessed from the internet when the required network and security group rules permit the traffic.

### EBS Storage

The EC2 instance uses attached storage for the operating system, applications, Docker images, containers, and persistent data.

## 17. Final Deployment Result

The Twenty CRM application was successfully deployed on the AWS EC2 instance using Docker Compose.

Final architecture:

AWS EC2
│
├── Twenty CRM Server
├── Twenty CRM Worker
├── PostgreSQL
└── Redis

The application was successfully accessed through: http://100.52.234.118:3000

The EC2 instance, Docker environment, Twenty CRM services, and browser access were successfully verified.

## 18. Cleanup

After completing the task and documentation, the EC2 instance and associated resources should be stopped or terminated to avoid unnecessary AWS charges.

Before cleanup, all required screenshots, documentation, PR, and Loom recording should be completed.

## 19. Git Branch and Documentation

Task 7 branch: tannu-task-7

The documentation for this task is maintained in: AWS-EC2-Documentation.md

The documentation will be committed to the Task 7 branch and submitted through a Pull Request in: PearlThoughts-Intern-DevOps/devops-crm-project
