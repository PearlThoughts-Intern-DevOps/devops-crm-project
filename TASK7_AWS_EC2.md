# Task 7 – Deploy Twenty CRM on AWS EC2

## Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance using Docker and Docker Compose, configure secure SSH access, and verify the application through a web browser.

## AWS EC2 Configuration

- AWS Region: us-east-1 (N. Virginia)
- Instance Type: t3.small
- Operating System: Amazon Linux 2023
- Instance ID: i-098b47809c016c5da
- Public IPv4: 98.81.163.110
- Application Port: 3000
- SSH Port: 22

## Security Group Configuration

The EC2 instance was configured with the following inbound rules:

| Type | Protocol | Port | Source | Purpose |
|---|---|---|---|---|
| SSH | TCP | 22 | My IP | Secure SSH access |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 | Access Twenty CRM from browser |

SSH access was restricted to the required source IP, while port 3000 was opened for accessing the CRM application.

## SSH Connection

The EC2 instance was accessed from the local Windows machine using the .pem private key.

Command used:

ssh -i "crm-kaushal-task7-key.pem" ec2-user@98.81.163.110

The SSH connection was successfully established.

EC2 Instance Connect was not used.

## Docker Installation

Docker was installed on the Amazon Linux 2023 EC2 instance.

Docker installation was verified using:

docker --version

Docker was successfully installed and available for running containers.

## Docker Compose Installation

The Docker Compose plugin was installed manually because the docker-compose-plugin package was not available through the default Amazon Linux repository.

Docker Compose was verified using:

docker compose version

Installed version:

Docker Compose version v5.5.0

## Twenty CRM Directory Setup

A dedicated directory was created for the Twenty CRM deployment:

mkdir -p ~/twenty
cd ~/twenty

Working directory:

/home/ec2-user/twenty

## Twenty Docker Compose Configuration

The official Twenty CRM Docker Compose configuration was downloaded using:

curl -L https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml -o docker-compose.yml

The environment template was downloaded using:

curl -L https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/.env.example -o .env

The .env file was configured with the EC2 public IP:

SERVER_URL=http://98.81.163.110:3000

Secure values were generated for the encryption key and PostgreSQL database password.

The actual secret values were not included in this documentation for security reasons.

## Docker Compose Configuration Validation

Before starting the application, the Docker Compose configuration was validated using:

docker compose config --quiet

The command returned warnings for optional environment variables but no configuration errors.

Therefore, the Docker Compose configuration was valid.

## Pulling Twenty CRM Images

The required Docker images were downloaded using:

docker compose pull

The required images were successfully pulled, including:

- twentycrm/twenty:latest
- postgres:16
- redis

## Starting Twenty CRM

The Twenty CRM stack was started in detached mode using:

docker compose up -d

Docker Compose created the required network, volumes, and application containers.

## Container Verification

Container status was checked using:

docker compose ps

The final deployment showed:

- PostgreSQL: Up and Healthy
- Redis: Up and Healthy
- Twenty Server: Up and Healthy

The Twenty server was exposed through:

0.0.0.0:3000 -> 3000

## Twenty Server Health Check

The Twenty CRM health endpoint was tested from inside the EC2 instance:

curl -f http://localhost:3000/healthz

The response was:

{"status":"ok","info":{},"error":{},"details":{}}

This confirmed that the Twenty CRM server was healthy and responding successfully.

## Server Logs Verification

The Twenty server logs were checked using:

docker compose logs --tail=100 server

The logs showed:

Nest application successfully started

This confirmed that the application server completed its startup process successfully.

## Browser Verification

The deployed Twenty CRM application was accessed from the local browser using:

http://98.81.163.110:3000

The Twenty CRM application opened successfully in the browser.

The initial setup was completed and the Twenty CRM dashboard was successfully displayed.

This confirmed that:

1. EC2 networking was working.
2. Security Group port 3000 was correctly configured.
3. Docker port mapping was working.
4. Twenty CRM was running successfully.
5. The application was accessible externally through the EC2 public IP.

## Architecture

The deployment architecture was:

Local Windows Machine
        |
        | SSH using .pem key
        v
AWS EC2 - Amazon Linux 2023
        |
        | Docker Compose
        |
        +----------------------+
        |                      |
        v                      v
Twenty CRM Server          Twenty Worker
        |
        +----------+-----------+
                   |
             Docker Network
             /            \
            v              v
       PostgreSQL         Redis

## Issues Encountered

During the task, an earlier EC2 instance experienced SSH connectivity issues.

Instead of continuing with the problematic instance, a new EC2 instance was launched and configured.

The new instance was successfully accessed through SSH, Docker and Docker Compose were configured, and the Twenty CRM application was deployed successfully.

Another minor issue occurred during Docker Compose validation where some optional environment variables were reported as unset. These were warnings rather than errors and did not prevent the application from running.

## Final Result

Twenty CRM was successfully deployed on AWS EC2 using Docker Compose.

The final deployment was verified through:

- Successful SSH connection
- Successful Docker installation
- Successful Docker Compose installation
- Successful Docker image pull
- Healthy PostgreSQL container
- Healthy Redis container
- Healthy Twenty server
- Successful /healthz response
- Successful browser access
- Successfully opened Twenty CRM dashboard

Therefore, the AWS EC2 deployment of Twenty CRM was completed successfully.

## Cleanup

After completing the demonstration and submission, AWS resources should be stopped or terminated when they are no longer required to avoid unnecessary AWS charges.

The EC2 instance, associated storage, and other AWS resources should be checked and cleaned up according to the task requirements.