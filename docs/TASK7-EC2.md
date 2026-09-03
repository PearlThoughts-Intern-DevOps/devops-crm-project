# Task 7 – AWS EC2 Deployment

## Objective
Set up the DevOps CRM project on AWS EC2 and run Twenty CRM using Docker.

## EC2 Configuration
- Instance type: t3.micro
- OS: Amazon Linux 2023
- CPU: 2 vCPUs
- RAM: approximately 1 GiB

## Setup Completed
- Connected to EC2 using SSH.
- Verified Git.
- Installed Node.js v24.20.0.
- Installed Yarn 4.13.0.
- Installed and configured Docker.
- Cloned the DevOps CRM repository.
- Created the Ekta-task7 branch.
- Successfully completed yarn install.
- Added 2 GB swap because of limited memory.

## Twenty CRM Deployment
Started Twenty CRM using:

yarn twenty docker:start

The Docker image was downloaded successfully.
Database migrations and cache flushing completed successfully.

## Resource Limitation
During workspace data seeding, the Twenty container exited with code 137.

Exit code 137 indicated memory/resource pressure.

The t3.micro instance has approximately 1 GiB RAM. Therefore, it was insufficient to complete Twenty CRM startup reliably.

## Conclusion
The EC2 environment, Docker configuration, repository setup, dependency installation, and Twenty CRM initialization were completed. A larger-memory EC2 instance is required for reliable Twenty CRM deployment.
