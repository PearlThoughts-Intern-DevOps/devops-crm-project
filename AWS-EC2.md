# AWS EC2 Deployment Documentation

## 1. Overview
This document details the process of provisioning an AWS EC2 instance and deploying the containerized Twenty CRM application. The goal was to set up a secure, scalable, and cost-effective cloud environment to host the application using Docker Compose.

## 2. EC2 Instance Configuration
To ensure the application runs smoothly without resource bottlenecks, the EC2 instance was configured with the following specifications:
- **Instance Type:** `t3.small` (Selected to provide adequate RAM for the full-stack application and prevent Out-Of-Memory crashes).
- **AMI:** Ubuntu Server 22.04 LTS (Chosen for stability and native Docker compatibility).
- **Storage:** 20 GB gp3 EBS volume (To accommodate the OS, Docker images, and database growth).
- **Security Group (Inbound Rules):**
  - **Port 22 (SSH):** Allowed from Anywhere for secure remote administration.
  - **Port 2020 (Custom TCP):** Allowed from Anywhere to expose the Twenty CRM web interface to the internet.

## 3. Deployment Process
The deployment followed a structured, automated approach:
1. **Connection:** Secured the `.pem` key pair permissions and established an SSH connection to the instance.
2. **Environment Setup:** Updated the package manager and installed Docker and Docker Compose. Added the `ubuntu` user to the `docker` group to avoid permission errors.
3. **Application Deployment:** Cloned the repository and executed `docker-compose up -d` to spin up the App, PostgreSQL, and Redis containers in the background.
4. **Configuration Fix:** Updated the `SERVER_URL` and `FRONTEND_URL` environment variables in the `docker-compose.yml` file to point to the EC2 Public IP, preventing the app from redirecting to `localhost`.

## 4. Issues Faced and Solutions
- **Browser Redirecting to Localhost:** 
  - *Issue:* Accessing the public IP redirected the browser to `localhost:2020`, causing a connection drop.
  - *Solution:* Updated the environment variables in the Docker Compose file to reflect the actual EC2 Public IP (`13.233.122.7`) and restarted the containers.
- **Docker Permission Denied:** 
  - *Issue:* Running Docker commands without `sudo` failed.
  - *Solution:* Added the user to the Docker group (`sudo usermod -aG docker ubuntu`) and refreshed the SSH session.

## 5. Cost Management & Resource Cleanup
To prevent unnecessary AWS billing after verifying the deployment:
- Navigated to the EC2 Dashboard in the AWS Management Console.
- Selected the instance and changed the **Instance State** to **Stop**. 
- *Note:* Stopping the instance halts compute billing while preserving the EBS volume and configuration for future use.

## 6. Conclusion
This task successfully demonstrated the practical application of AWS EC2 for hosting a containerized application. By leveraging Docker Compose for orchestration, properly configuring Security Groups, and managing environment variables, a production-like environment was established efficiently. Understanding how to balance instance sizing, security rules, and cost management is a fundamental skill for any DevOps engineer.
