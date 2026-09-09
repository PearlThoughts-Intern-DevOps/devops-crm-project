# Task 7 Twenty CRM -- EC2 Deployment 

## 1. Clone Repository to EC2

The project repository was cloned directly into the EC2 instance.

```bash
cd /home/ubuntu/task_7
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd /home/ubuntu/task_7/devops-crm-project
```

* * * * *

2\. Install Requirements
------------------------

The required tools and software were installed on the EC2 instance:

-   Git
-   Node.js 24.5.0
-   npm
-   NVM
-   Yarn 4.13.0
-   Docker
-   Docker Compose

Versions were verified after installation:

```
node --version
npm --version
git --version
yarn --version
docker --version
docker compose version
```

* * * * *

3\. Setup Dependencies
----------------------

NVM was configured to use Node.js version `24.5.0`.

Yarn `4.13.0` was enabled using Corepack.

Docker was installed and configured to start as a system service.

A 2 GB swap file was also configured to provide additional memory capacity for the application.

* * * * *

4\. Install Project Dependencies
--------------------------------

Inside the project directory, the project dependencies were installed using Yarn:

```
yarn install
```

The installation completed successfully with some peer-dependency warnings. These warnings did not prevent the installation from completing.

* * * * *

5\. Start Twenty CRM with Docker
--------------------------------

Twenty CRM was started using the project's Yarn command:

```
yarn twenty docker:start
```

The command successfully completed the following steps:

-   PostgreSQL startup
-   Initial database setup
-   Database migrations
-   Cache flushing
-   Database upgrade
-   Workspace data seeding
-   Database readiness check
-   Cron job registration

The final output confirmed:

```
Server running on http://localhost:2020
```

Twenty CRM was therefore successfully deployed and running on the EC2 instance.

* * * * *

Issues Faced and Solutions
==========================

Issue 1: IAM Permissions Were Not Allowed
-----------------------------------------

### Problem

Initially, the provided AWS account did not have the required IAM permissions to launch and manage an EC2 instance.

### Solution

The required permissions could not be changed from the user account. After discussing the issue, the deployment was continued using an AWS account with the required permissions.

* * * * *

Issue 2: EC2 Instance Was Automatically Terminated
--------------------------------------------------

### Problem

The EC2 instance that was previously launched was automatically terminated by the provider. As a result, the installed software, configuration, and project files on that instance were lost.

### Solution

A new EC2 instance was launched and the complete setup process was performed again from the beginning.

The new instance was configured with sufficient resources for the Twenty CRM deployment.

* * * * *

Issue 3: Unable to Connect to the EC2 Instance
----------------------------------------------

### Problem

After launching an EC2 instance, connecting through the available connection method was unsuccessful.

### Solution

The EC2 instance was accessed using PowerShell and SSH with the EC2 key pair:

```
ssh -i <key-file>.pem ubuntu@<PUBLIC-IP>
```

After successfully connecting, the required environment and project setup was completed.

* * * * *

Final Deployment Status
=======================

Twenty CRM was successfully deployed on the EC2 instance using Docker.

The application was confirmed to be running at:

```
http://instance_public_ip:2020
```
