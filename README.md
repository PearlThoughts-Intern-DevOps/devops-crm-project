# Task 7 — AWS EC2 Deployment (Twenty CRM)

## Overview
This task covers launching an AWS EC2 instance and deploying the **Twenty CRM** application on it using Docker, based on the Docker configuration created in Task 5.

## Environment Summary
| Component | Configuration |
|---|---|
| Operating System (AMI) | Ubuntu Server 22.04 LTS |
| Instance Type | t3.small |
| Connection Method | SSH via Git Bash |
| Container Runtime | Docker |
| Application Deployed | Twenty CRM (open-source CRM) |
| Deployment Method | Cloned repo containing Dockerfile / Docker Compose config |

## Steps Performed
1. **Launch EC2 Instance** — Launched a `t3.small` Ubuntu 22.04 LTS instance via the AWS Console, created a key pair, and configured a security group allowing inbound traffic on port 22 (SSH) and the Twenty CRM application port.
2. **Connect to Instance** — Connected via SSH using Git Bash with the downloaded `.pem` key.
3. **Install Docker** — Installed `docker.io` and `docker-compose-plugin`, enabled the Docker service, and added the user to the `docker` group.
4. **Clone Repository** — Cloned the `devops-crm-project` repository (Task 5 branch containing the Dockerfile) onto the instance.
5. **Deploy Application** — Ran `docker compose up -d` to build and start the containers, and verified they were running with `docker ps`.
6. **Access Application** — Accessed the Twenty CRM application using the EC2 instance's public IP and configured port.

## Key AWS EC2 Concepts Used
- **AMI (Amazon Machine Image)** — Ubuntu 22.04 template used to launch the instance
- **Instance Type** — Determines compute, memory, and network capacity
- **Key Pair** — Public/private key used for secure SSH authentication
- **Security Group** — Virtual firewall controlling inbound/outbound traffic
- **Public IP** — Used to access the instance and running application externally

## Outcome
The EC2 instance was successfully launched, connected to via SSH, and configured with Docker. The Twenty CRM repository was cloned and deployed using its Docker configuration, and the application ran successfully on the instance.

## Branch Info
- Branch: `fiza-task7`
- Base: `main`
