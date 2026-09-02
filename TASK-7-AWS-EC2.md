# Task 7 – AWS EC2 Deployment

**Name:** Vasundara Nadar  
**Branch:** vasundara-task7  
**Date:** 02 September 2026

## Objective

The objective of this task was to launch an AWS EC2 instance, connect to it securely using SSH, configure the server environment, and deploy the Twenty CRM application.

## 1. EC2 Instance Configuration

The EC2 instance was created with the following configuration:

- Cloud Provider: AWS
- Region: US East (N. Virginia) – us-east-1
- AMI: Ubuntu 24.04 LTS
- Instance Type: t3.small
- vCPUs: 2
- Storage: 20 GiB
- Key Pair: vasundara-crm-task7
- Security Group: vasundara-task7-sg
- Instance Name: vasundara-task7

## 2. Basic EC2 Concepts

### AMI

An Amazon Machine Image (AMI) is a template used to create an EC2 instance. It contains the operating system and required configuration.

### Instance Type

The instance type determines the compute resources available to the server, including CPU and memory.

The t3.small instance provides 2 vCPUs and approximately 2 GiB of memory.

### Key Pair

A key pair is used for secure SSH authentication. The private .pem key was stored securely on the local machine and was not shared.

### Security Group

A security group acts as a virtual firewall for the EC2 instance. It controls inbound and outbound network traffic.

## 3. SSH Connection

The EC2 instance was connected from the local WSL terminal using the .pem key.

The key was copied to the local SSH directory and its permissions were restricted:

    cp /mnt/c/Users/Appu/Downloads/vasundara-crm-task7.pem ~/.ssh/
    chmod 400 ~/.ssh/vasundara-crm-task7.pem

SSH connection:

    ssh -i ~/.ssh/vasundara-crm-task7.pem ubuntu@98.93.133.6

The SSH connection was successful.

## 4. Server Setup

The Ubuntu package list was updated and system packages were upgraded:

    sudo apt update
    sudo apt upgrade -y

Installed and verified tools:

    docker --version
    docker compose version
    git --version

Docker was tested using:

    sudo docker run hello-world

The Docker test completed successfully.

## 5. Docker Permission Configuration

Initially, Docker required elevated privileges for the Ubuntu user.

The user was added to the Docker group:

    sudo usermod -aG docker $USER

The new group membership was activated:

    newgrp docker

Docker could then be used without sudo.

## 6. Clone the Project

The internship repository was cloned:

    git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
    cd devops-crm-project

## 7. Node.js and Yarn Setup

The project requires Node.js and Yarn.

The project specifies Node.js version 24.5.0 in the .nvmrc file.

NVM was installed and Node.js 24.5.0 was configured.

Corepack was enabled and Yarn was verified:

    corepack enable
    yarn --version

Project dependencies were installed using:

    yarn install

The installation completed successfully with peer-dependency warnings.

## 8. Twenty CRM Deployment

Twenty CRM was started using the project command:

    yarn twenty docker:start

The Docker container was created and the PostgreSQL database initialization and migration process started.

The container status was checked using:

    docker ps -a

The Twenty CRM container was:

    twenty-app-dev

The application port was mapped as:

    0.0.0.0:2020 -> 2020/tcp

## 9. Deployment Issue – Out of Memory

During the Twenty CRM startup, the application did not remain available.

The Docker container was investigated using:

    docker inspect --format='Status={{.State.Status}} ExitCode={{.State.ExitCode}} OOMKilled={{.State.OOMKilled}} RestartCount={{.RestartCount}} Error={{.State.Error}}' twenty-app-dev

The result showed:

    Status=running
    ExitCode=0
    OOMKilled=true
    RestartCount=0

The server memory was checked using:

    free -h

The result showed approximately:

    Memory: 1.9 GiB
    Available: approximately 18 MiB
    Swap: 0 B

## 10. Root Cause

The t3.small EC2 instance has limited memory.

Twenty CRM requires significant memory during startup. The EC2 instance had almost no available RAM and had no configured swap memory.

As a result, the operating system killed the Twenty CRM process because of memory pressure.

The OOMKilled=true status confirmed the memory-related issue.

## 11. Solution

A 2 GB swap file can be configured on the EC2 instance to provide additional virtual memory:

    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

Swap can then be verified with:

    free -h

After configuring swap, the Twenty CRM container can be restarted and tested again.

## 12. Security Practices

- The private .pem key must never be committed to Git.
- AWS credentials must never be stored in source code.
- SSH access should preferably be restricted to trusted IP addresses.
- Only required ports should be opened in the security group.
- Unused AWS resources should be stopped or terminated.

## 13. Resource Cleanup

After completing the testing, the EC2 instance was terminated as part of resource cleanup.

Termination permanently removes the EC2 instance.

## Conclusion

In this task, I launched and configured an AWS EC2 instance using Ubuntu 24.04, t3.small instance type, 20 GiB storage, a key pair, and a security group.

I connected to the EC2 instance from my local WSL environment using SSH and the .pem key.

I configured Docker, Node.js, Yarn, and the project environment and attempted to deploy Twenty CRM.

During deployment, the application encountered a memory limitation. Docker inspection showed OOMKilled=true, while the Linux memory check showed approximately 1.9 GiB RAM with only around 18 MiB available and no swap.

The issue was identified as insufficient memory. The EC2 instance was subsequently terminated as part of resource cleanup.
