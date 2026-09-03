# Task 7 – AWS EC2 Deployment

**Name:** Vasundara Nadar  
**Branch:** vasundara-task7  
**Date:** 03 September 2026

## Objective

The objective of this task was to launch and configure an AWS EC2 instance, connect to it using SSH, install the required tools, deploy Twenty CRM, verify the application, and document the complete process.

## 1. EC2 Instance Configuration

- Cloud Provider: AWS
- Region: US East (N. Virginia) – `us-east-1`
- AMI: Ubuntu 26.04 LTS
- Instance Type: `t3.small`
- vCPUs: 2
- Memory: Approximately 2 GiB
- Storage: 20 GiB
- Key Pair: `vasundara-task7-key`
- Security Group: `launch-wizard-8`
- Instance Name: `vasundara-task7`
- Public IPv4: `100.53.126.254`
- Private IPv4: `172.31.28.148`

## 2. Basic EC2 Concepts

### AMI

An Amazon Machine Image (AMI) is a template used to create an EC2 instance. It contains the operating system and other required configuration used during instance launch.

### Instance Type

The instance type determines the compute resources available to the EC2 instance.

The `t3.small` instance provides 2 vCPUs and approximately 2 GiB of memory.

### Key Pair

A key pair is used for secure SSH authentication. The private `.pem` key is stored securely on the local machine and was used to connect to the EC2 instance.

### Security Group

A security group acts as a virtual firewall for the EC2 instance. The required inbound rules were configured for SSH, HTTP, HTTPS, and Twenty CRM on TCP port `2020`.

## 3. Connecting to EC2 Using SSH

The instance was accessed from the local WSL terminal using the `.pem` key:

```bash
ssh -i ~/.ssh/vasundara-task7-key.pem ubuntu@100.53.126.254
4. System Update
sudo apt update && sudo apt upgrade -y
5. Docker Installation

Docker was installed and enabled as a system service.

sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo docker --version

Docker version:

Docker version 29.1.3

The user was added to the Docker group:

sudo usermod -aG docker $USER
newgrp docker

Docker was verified using:

docker ps
6. Git Installation
sudo apt install git -y
git --version

Git version:

git version 2.53.0
7. Node.js and Yarn Setup

NVM was installed using:

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc

NVM version:

0.40.3

Node.js 24.5.0 was installed:

nvm install 24.5.0

Versions:

Node.js: v24.5.0
npm: 11.5.1

Yarn 4.13.0 was activated:

corepack enable
corepack prepare yarn@4.13.0 --activate
8. Clone the Project
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
9. Install Dependencies
yarn install

The installation completed successfully with warnings.

10. Memory Optimization

The t3.small instance has approximately 2 GiB of RAM. A 2 GiB swap file was created to reduce the risk of memory exhaustion during deployment.

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

Verification:

free -h

The server showed:

Swap: 2.0Gi
11. Twenty CRM Deployment

Twenty CRM was started using:

yarn twenty docker:start

The initial health check reported:

Twenty server did not become healthy in time.

The Docker logs were checked:

yarn twenty docker:logs

The logs confirmed that the NestJS server was running and processing background jobs.

The container was verified:

docker ps

Output confirmed:

twenty-app-dev
Up
0.0.0.0:2020->2020/tcp
12. Application Verification

The application was tested locally on the EC2 server:

curl -I http://localhost:2020

Response:

HTTP/1.1 200 OK

This confirmed that Twenty CRM was running successfully.

13. Security Group Configuration

The Security Group initially contained rules for SSH, HTTP, and HTTPS.

A custom TCP rule was added:

Type: Custom TCP
Port: 2020
Source: 0.0.0.0/0
Description: Twenty CRM

After adding port 2020, the application became accessible externally.

Twenty CRM was successfully opened at:

http://100.53.126.254:2020

The Companies page loaded successfully.

14. Issues and Solutions
Issue 1 – Twenty CRM Health Check Timeout

The deployment command initially reported:

Twenty server did not become healthy in time.

Solution: Docker logs were checked using:

yarn twenty docker:logs

The logs confirmed that the application continued running successfully.

Issue 2 – Limited Memory

The EC2 t3.small instance had approximately 2 GiB RAM and no swap.

Solution: A 2 GiB swap file was created and activated.

Issue 3 – Application Not Accessible Externally

Twenty CRM returned HTTP/1.1 200 OK locally but could not initially be accessed from the browser.

Solution: TCP port 2020 was added to the Security Group inbound rules.

15. EC2 Cleanup

The EC2 instance should be stopped or terminated after the required demonstration and verification are complete to avoid unnecessary AWS charges.

16. Final Result

The AWS EC2 instance was successfully launched and accessed using SSH.

Docker, Git, Node.js, NVM, and Yarn were configured successfully.

Twenty CRM was successfully deployed using Docker.

The application returned HTTP/1.1 200 OK and was successfully accessed externally through port 2020.

17. Conclusion

This task provided practical experience with AWS EC2 provisioning, SSH authentication, Security Groups, Docker deployment, Linux administration, memory management, troubleshooting, and application verification.
