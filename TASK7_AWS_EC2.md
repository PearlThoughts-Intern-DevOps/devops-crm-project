# Task 7: AWS EC2 – Twenty CRM Deployment

**Name:** Harish  
**Date:** September 2, 2026  
**Task:** Deploy and run the Twenty CRM application on an AWS EC2 instance.

---

## 1. Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance using Ubuntu Server, Docker, Docker Compose, and Git.

The application was successfully built, started, verified through Docker health checks and HTTP requests, and accessed through a web browser.

---

## 2. EC2 Instance Configuration

| Setting | Value |
|---|---|
| Instance Name | `harish-twenty-crm` |
| AMI | Ubuntu Server 26.04 LTS |
| Instance Type | `t3.small` |
| vCPUs | 2 |
| RAM | 2 GiB |
| Key Pair | `harish-ec2-key` |
| Key Format | RSA `.pem` |
| Storage | 20 GiB gp3 |
| Security Group | `harish-twenty-crm-sg` |

### Security Group Inbound Rules

| Type | Port | Source | Purpose |
|---|---:|---|---|
| SSH | 22 | `0.0.0.0/0` | Remote SSH access |
| Custom TCP | 3000 | `0.0.0.0/0` | Twenty CRM web access |

> **Security Note:** For production environments, SSH access should preferably be restricted to a trusted IP address instead of allowing `0.0.0.0/0`.

---

## 3. EC2 Connection & Initial Server Setup

### Step 1: Secure the SSH Key

The SSH private key permissions were restricted to prevent the `Permissions are too open` error.

```bash
chmod 400 harish-ec2-key.pem

Step 2: Connect to the EC2 Instance
ssh -i "harish-ec2-key.pem" ubuntu@<EC2_PUBLIC_IP>

Step 3: Update the System
sudo apt update && sudo apt upgrade -y

Step 4: Install Docker, Docker Compose, and Git
sudo apt install -y docker.io docker-compose-v2 git

Step 5: Add User to Docker Group
sudo usermod -aG docker $USER
newgrp docker

Step 6: Verify Docker Installation
docker --version
docker compose version

###

4. Application Deployment
Step 1: Clone the Repository
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project

Step 2: Checkout the Task Branch
git checkout harish-task5

Step 3: Configure Environment Variables
Create the .env file from the example:

cp .env.example .env

Generate a secure random string for the application secret:

openssl rand -base64 32

Edit the environment file:

nano .env

The generated value was configured as APP_SECRET, and SERVER_URL was updated appropriately.

Note: The actual secret value is not included in this documentation for security reasons.

Step 4: Build and Start the Application
docker compose up --build -d

This built the Docker images and started the required application services.

###

5. AWS EC2 Concepts Understood

AMI – Amazon Machine Image
An AMI is a pre-configured template used to launch an EC2 instance.

The Ubuntu Server 26.04 LTS AMI provided the operating system and the basic environment required to boot the server.

Instance Type – t3.small
The EC2 instance type determines the available hardware resources, including CPU, RAM, and network performance.

The t3.small instance was selected to provide a lightweight environment suitable for running the Dockerized application stack.

Security Groups
Security groups act as virtual firewalls for EC2 instances.

In this deployment:

Port 22 was opened for SSH administration.
Port 3000 was opened for external access to Twenty CRM.
Key Pairs
AWS EC2 uses public-key authentication for SSH access.

The .pem file contains the private key used by the SSH client to authenticate against the public key configured for the EC2 instance.

EBS – Elastic Block Store
EBS provides persistent block storage for EC2 instances.

The 20 GiB gp3 volume was used to store:

Ubuntu operating system files
Docker images
Docker containers
Application-related data

####

6. Issues Faced & Solutions
Issue 1: SSH Connection Permission Error
Problem
The SSH connection initially failed because the private key file had permissions that were too permissive.

Solution
The private key permissions were restricted using:

chmod 400 harish-ec2-key.pem

This allowed SSH to securely use the private key.

Issue 2: Docker Build Failed on Missing .yarn Directory
Problem
During the initial docker compose up --build, the build failed during the builder stage because the Dockerfile contained:

COPY .yarn ./.yarn

However, the fresh repository clone did not contain the expected .yarn directory in the Docker build context.

Solution
The Dockerfile was inspected and the problematic .yarn copy instruction was removed.

The application was then rebuilt:

docker compose up --build -d

The Docker build completed successfully after this change.

Issue 3: twenty-server Container Became Unhealthy
Problem
The database and Redis containers started successfully, but the twenty-server container initially became unhealthy.

The logs showed that the database migrations completed successfully, but the application required additional time to fully initialize.

The default Docker Compose health-check startup period was not sufficient for the NestJS application to start on the constrained t3.small instance with 2 GiB RAM.

This resulted in connection failures when accessing port 3000.

Solution
The Docker Compose health-check configuration was reviewed.

The default:

start_period: 60s

was increased to provide the application with additional startup time.

After modifying the health-check configuration, the application was rebuilt:

docker compose up --build -d

The twenty-server container subsequently completed initialization and successfully passed its health check.

####

7. Deployment Verification
Check Docker Container Status
docker compose ps

Result
All required containers were running and reported healthy status.

The deployed services included:

Database
Redis
Twenty Server
Application
Check Application Logs
docker compose logs twenty-server --tail 50

The logs confirmed successful application startup and database initialization.

Local Curl Test
The application was tested directly from the EC2 instance:

curl -I http://localhost:3000

Result
The application returned:

HTTP/1.1 200 OK

This confirmed that the application was successfully responding on port 3000.

Browser Test
The application was opened in a local browser using:

http://<EC2_PUBLIC_IP>:3000

The Twenty CRM setup screen loaded successfully.

####

8. Final Deployment Architecture

                    Internet
                       |
                       |
                  TCP Port 3000
                       |
                       v
              +------------------+
              |     AWS EC2      |
              | Ubuntu 26.04 LTS |
              +------------------+
                       |
                       v
                Docker Engine
                       |
                       v
                Docker Compose
                       |
          +------------+------------+
          |            |            |
          v            v            v
      Database       Redis      Twenty Server
                                      |
                                      v
                                 Application

9. Final Container State
The final Docker Compose deployment consisted of the following services:

Service	Status
Database	Up / Healthy
Redis	Up / Healthy
Twenty Server	Up / Healthy
Application	Up / Healthy

The application successfully responded to HTTP requests on port 3000.

####

10. Cleanup & Termination

After successfully verifying the deployment and recording the Loom video, the temporary AWS resources were removed to avoid unnecessary charges.

The following cleanup actions were performed:

The harish-twenty-crm EC2 instance was terminated.
The harish-twenty-crm-sg security group was deleted.
The harish-ec2-key key pair was deleted.

####

11. Commands Summary

Task	Command
Secure SSH key	chmod 400 harish-ec2-key.pem
Connect to EC2	ssh -i "harish-ec2-key.pem" ubuntu@<PUBLIC_IP>
Update system	sudo apt update && sudo apt upgrade -y
Install Docker/Git	sudo apt install -y docker.io docker-compose-v2 git
Add user to Docker group	sudo usermod -aG docker $USER
Apply Docker group	newgrp docker
Clone repository	git clone <repo-url>
Enter repository	cd devops-crm-project
Checkout branch	git checkout harish-task5
Create environment file	cp .env.example .env
Generate secret	openssl rand -base64 32
Edit environment	nano .env
Build and run	docker compose up --build -d
Check containers	docker compose ps
View logs	docker compose logs twenty-server --tail 50
Test application	curl -I http://localhost:3000
Start services	docker compose up -d

###

12. Technical Learnings
Through this task, I gained practical experience with:

AWS EC2 instance provisioning
Ubuntu Server administration
SSH key-based authentication
Linux file permissions
AWS Security Groups
EBS storage
Docker installation
Docker Compose
Git repository management
Git branch management
Environment variable configuration
Docker image troubleshooting
Docker health checks
Container log analysis
HTTP-based application verification
AWS resource cleanup
13. Conclusion
The Twenty CRM application was successfully deployed on an AWS EC2 instance running Ubuntu Server 24.04 LTS.

Docker and Docker Compose were used to build and run the application stack.

During deployment, three major issues were identified and resolved:

SSH private key permission errors
Docker build failure caused by the missing .yarn directory
twenty-server health-check failure caused by insufficient application startup time
After applying the fixes:

All required Docker containers were running.
All containers reached a healthy state.
The application returned HTTP 200 OK.
The Twenty CRM setup screen was successfully accessed through the EC2 public IP.
The EC2 instance and temporary AWS resources were terminated after verification.
This task provided practical experience in deploying a containerized application on AWS EC2 and troubleshooting Docker-based environments.

###

14. Loom Video
Loom Video: [https://www.loom.com/share/78512cf70a3241108ea51924ec13e613]


