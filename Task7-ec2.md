# Task 7 – AWS EC2 Deployment of Twenty CRM

## Overview

This task involved launching and configuring an AWS EC2 instance, connecting to it through SSH, preparing the environment, deploying the Twenty CRM application, resolving resource limitations, and terminating the AWS resources after completion.

The main objectives were:

- Launch an EC2 instance in the provided AWS account.
- Configure the instance with the required AMI, instance type, key pair, and security group.
- Connect to the instance using SSH.
- Install the required development and containerization tools.
- Clone and run the Twenty CRM application.
- Understand the basic AWS EC2 configuration used during deployment.
- Resolve deployment issues encountered during setup.
- Terminate the AWS resources after completing the task.
- Document the complete process, commands, issues, and solutions.

---

# 1. AWS Console Login

I logged into the AWS Management Console using the AWS credentials provided for the task.

### Login Status

- AWS Console login: **Successful**
- Credential issues: **None**
- AWS Region used: **US East (N. Virginia) – `us-east-1`**

---

# 2. EC2 Instance Configuration

I launched an EC2 instance with the following configuration:

| Configuration    | Value                   |
| ---------------- | ----------------------- |
| AWS Region       | `us-east-1`             |
| AMI ID           | `ami-0b6d9d3d33ba97d99` |
| Instance Type    | `t3.small`              |
| Operating System | Ubuntu                  |
| Key Pair         | `mohit-singh.pem`       |
| Security Group   | `task7-sg`              |
| Inbound Port     | `22`                    |
| Application Port | `2020`                  |

### Security Group Configuration

The security group was configured to allow:

- **Port 22** – SSH access
- **Port 2020** – Twenty CRM application access

For testing the application, port `2020` was configured with the required inbound access.

---

# 3. Connecting to the EC2 Instance

I connected to the EC2 instance using SSH from my local Windows machine.

### SSH Command

```bash
ssh -i .\mohit-singh.pem ubuntu@54.90.226.31
```

The connection was successful and I was able to access the Ubuntu EC2 instance.

---

# 4. Server Environment Setup

After connecting to the EC2 instance, I prepared the environment required to run Twenty CRM.

## 4.1 Install NVM

I installed NVM (Node Version Manager) using the official installation script:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
```

Then reloaded the shell configuration:

```bash
source ~/.bashrc
```

## 4.2 Install Node.js LTS

I installed the latest LTS version of Node.js:

```bash
nvm install --lts
```

## 4.3 Enable Corepack

Corepack was enabled to manage the Yarn package manager:

```bash
corepack enable
```

## 4.4 Configure Yarn

I configured Yarn to use the stable version:

```bash
yarn set version stable
```

Then verified the installed Yarn version:

```bash
yarn --version
```

---

# 5. Docker Installation

Twenty CRM uses Docker as part of its development environment, so Docker was installed on the EC2 instance.

First, I updated the package index and installed the required dependencies:

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg
```

Created the Docker keyring directory:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Downloaded and installed Docker's GPG key:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Set the appropriate permissions:

```bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Added the Docker repository:

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Updated the package index again:

```bash
sudo apt update
```

Verified the Docker package information:

```bash
apt-cache policy docker-ce
```

Installed Docker and the required plugins:

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Checked the Docker service:

```bash
sudo systemctl status docker
```

Finally, I added the current user to the Docker group:

```bash
sudo usermod -aG docker ${USER}
```

---

# 6. Clone the Project Repository

I cloned the project repository from GitHub:

```bash
git clone https://github.com/moechadSayshi/mohitsingh-pre-internship-repo.git
```

The repository was cloned successfully.

The project was worked on from the `main` branch.

---

# 7. Twenty CRM Setup

After cloning the repository, I followed the project setup instructions and ran the required Yarn commands.

### Install Dependencies

```bash
yarn install
```

### Start Docker Services

```bash
yarn twenty docker:start
```

### Start Twenty CRM

```bash
yarn twenty dev
```

The Twenty CRM development server was started and configured to use port `2020`.

---

# 8. Issue Faced – Limited Memory on EC2

## Problem

While running the Twenty CRM environment, I encountered resource limitations on the `t3.small` EC2 instance.

Running Docker and Yarn together required more memory than was comfortably available on the instance.

The issue was related to the available RAM and caused the environment to become resource constrained.

## Solution

I checked the available memory:

```bash
free -h
```

To provide additional memory for the deployment, I created a **4 GB swap file**.

### Create the Swap File

```bash
sudo fallocate -l 4G /swapfile
```

Set the correct permissions:

```bash
sudo chmod 600 /swapfile
```

Set up the swap file:

```bash
sudo mkswap /swapfile
```

Enabled the swap:

```bash
sudo swapon /swapfile
```

Configured the swap to persist after reboot:

```bash
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

After adding swap space, the EC2 instance had additional virtual memory available, which allowed the Twenty CRM environment to run more reliably.

---

# 9. Twenty CRM Application Access

The Twenty CRM development server was configured to run on port:

```text
2020
```

The EC2 security group was configured to allow inbound traffic to port `2020`.

The application could then be accessed using the EC2 instance's public IP address and port:

```text
http://<EC2-PUBLIC-IP>:2020
```

Example:

```text
http://54.90.226.31:2020
```

---

# 10. Basic EC2 Concepts Used

During this task, I worked with the following AWS EC2 concepts:

### AMI

An Amazon Machine Image (AMI) provides the base operating system and configuration used to create an EC2 instance.

The AMI used for this task was:

```text
ami-0b6d9d3d33ba97d99
```

### Instance Type

The instance type determines the available CPU, memory, networking, and other resources.

The selected instance type was:

```text
t3.small
```

The instance provided enough resources for the task after adding swap space.

### Key Pair

The EC2 key pair was used for secure SSH authentication.

Key pair:

```text
mohit-singh.pem
```

The private key was stored securely and used when connecting through SSH.

### Security Group

A security group acts as a virtual firewall for the EC2 instance.

The security group used in this task was:

```text
task7-sg
```

The required ports were:

- `22` – SSH
- `2020` – Twenty CRM application

### Swap Memory

Because the EC2 instance had limited RAM for running Docker and Yarn simultaneously, a 4 GB swap file was created to provide additional virtual memory.

---

# 11. AWS Resource Cleanup

After completing the deployment and documentation work, I terminated the EC2 instance through the AWS Management Console.

This was done to prevent unnecessary AWS charges after the task was completed.

---

# 12. Final Result

The AWS EC2 deployment was completed successfully.

The main workflow was:

```text
AWS Console
    ↓
Launch EC2 Instance
    ↓
Configure Ubuntu + t3.small
    ↓
Configure Security Group
    ↓
SSH into EC2
    ↓
Install NVM + Node.js + Yarn
    ↓
Install Docker
    ↓
Clone Twenty CRM Project
    ↓
yarn install
    ↓
yarn twenty docker:start
    ↓
yarn twenty dev
    ↓
Resolve memory limitation with 4 GB swap
    ↓
Access Twenty CRM on port 2020
    ↓
Terminate EC2 Instance
```

## Conclusion

This task provided practical experience with AWS EC2 provisioning, SSH-based server access, security-group configuration, Linux environment setup, Docker installation, memory management, and deployment of the Twenty CRM application.

The main technical challenge was the limited memory available on the `t3.small` instance while running Docker and Yarn. Creating and enabling a 4 GB swap file provided additional virtual memory and allowed the application environment to run successfully.

After completing the deployment and verification, the EC2 instance was terminated to avoid unnecessary AWS costs.
