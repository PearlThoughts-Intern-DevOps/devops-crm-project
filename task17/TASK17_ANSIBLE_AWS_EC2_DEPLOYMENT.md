# Task 17: Ansible and AWS EC2 Deployment

## 1. Objective

The objective of this task was to create an AWS EC2 instance using Terraform and deploy Twenty CRM using Ansible and Docker.

The complete flow was:

**Terraform → EC2 → Ansible → Docker → Twenty CRM → Health Check → Verification**

## 2. AWS Configuration

| Configuration | Details |
|---|---|
| Region | us-east-1 |
| AMI | ami-0b6d9d3d33ba97d99 |
| Instance Type | t3.small |
| VPC | Default VPC |
| Subnet | Default VPC subnet |
| Instance ID | i-09b67f467e3b83972 |
| Public IP | 98.80.184.179 |
| SSH Port | 22 |
| Application Port | 2020 |

## 3. Project Structure

```text
task17/
├── main.tf
├── terraform.tfstate
└── ansible/
    ├── inventory.ini
    ├── playbook.yml
    ├── .gitignore
    └── group_vars/
        └── twenty_secrets.yml

File Description
main.tf – Creates the AWS infrastructure using Terraform.
terraform.tfstate – Stores Terraform state information.
inventory.ini – Contains the EC2 host information for Ansible.
playbook.yml – Automates server configuration and Twenty CRM deployment.
.gitignore – Prevents sensitive files from being committed.
twenty_secrets.yml – Stores the Twenty CRM encryption key locally.
4. Terraform Configuration

Terraform was used to create the EC2 infrastructure.

The configuration uses:

AWS region us-east-1
Default VPC
Default VPC subnet
t3.small EC2 instance
Required AMI
EC2 key pair
Security group
Public IP address

The security group allows:

Port 22 for SSH access
Port 2020 for Twenty CRM
5. Ansible Configuration

After creating the EC2 instance, the public IP address was added to the Ansible inventory.

Ansible was then used to automate the complete server setup and application deployment.

The playbook performs the following tasks:

Updates the APT package cache.
Upgrades installed packages.
Installs Docker.
Installs Docker Compose.
Installs required dependencies.
Starts and enables Docker.
Creates the /opt/twenty application directory.
Creates the Twenty CRM environment configuration.
Creates the Docker Compose configuration.
Deploys Twenty CRM.
Configures the Docker restart policy.
Configures the application health check.
Waits for the application port.
Verifies the application.
Displays Docker container status.
Displays application logs.
6. Docker Deployment

Twenty CRM was deployed using Docker Compose.

The deployment contains three services:
# Task 17: Ansible and AWS EC2 Deployment

## Objective

The objective of this task was to create an AWS EC2 instance using Terraform and deploy Twenty CRM using Ansible and Docker.

Deployment flow:

Terraform → AWS EC2 → Ansible → Docker → Twenty CRM → Health Check → Verification

## AWS Configuration

Region: us-east-1
AMI: ami-0b6d9d3d33ba97d99
Instance Type: t3.small
VPC: Default VPC
Subnet: Default VPC subnet
Instance ID: i-09b67f467e3b83972
Public IP: 98.80.184.179
SSH Port: 22
Application Port: 2020

## Project Structure

task17/
├── main.tf
├── terraform.tfstate
└── ansible/
    ├── inventory.ini
    ├── playbook.yml
    ├── .gitignore
    └── group_vars/
        └── twenty_secrets.yml

## Terraform Configuration

Terraform was used to create the AWS EC2 infrastructure.

The configuration uses the default VPC and default subnet.

The security group allows:
- Port 22 for SSH access
- Port 2020 for Twenty CRM

The EC2 instance was created with:
- AMI: ami-0b6d9d3d33ba97d99
- Instance type: t3.small
- Key pair: ambu-task17-key
- Public IP enabled

## Ansible Configuration

The EC2 public IP was added to the Ansible inventory.

Ansible was used to automate the complete server setup and Twenty CRM deployment.

The playbook performs these tasks:

1. Update the APT package cache.
2. Upgrade installed packages.
3. Install Docker.
4. Install Docker Compose.
5. Install required dependencies.
6. Start and enable Docker.
7. Create the /opt/twenty directory.
8. Configure Twenty CRM environment variables.
9. Create the Docker Compose configuration.
10. Deploy Twenty CRM.
11. Configure the Docker restart policy.
12. Configure the Docker health check.
13. Wait for the application port.
14. Verify the application.
15. Display Docker container status.
16. Display application logs.

## Docker Configuration

Twenty CRM was deployed using Docker Compose.

Services:

- Twenty CRM
- PostgreSQL
- Redis

Twenty CRM image:

twentycrm/twenty:latest

Port mapping:

EC2 Port 2020 → Container Port 3000

Application URL:

http://98.80.184.179:2020

## Restart Policy

The containers use:

restart: unless-stopped

This allows Docker to restart the containers automatically if they stop unexpectedly or when Docker restarts.

## Health Check

A Docker health check was configured for the Twenty CRM application.

The health check verifies that the application is responding correctly inside the container.

Final health status:

healthy

## Verification

The final Ansible playbook execution completed successfully.

PLAY RECAP

98.80.184.179 : ok=15 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0

The important result is:

failed=0

The following were verified successfully:

- EC2 connectivity
- Docker installation
- Docker service
- Docker Compose
- Twenty CRM deployment
- PostgreSQL
- Redis
- Restart policy
- Docker health check
- Application access
- Docker container status
- Application logs

## Application Logs

The Twenty CRM application logs were checked after deployment.

The logs showed successful Nest application startup and normal application operations.

No startup errors were present during the final verification.

## Secret Management

The Twenty CRM encryption key is stored separately in:

ansible/group_vars/twenty_secrets.yml

The secret file is excluded using .gitignore.

The following sensitive files are not committed to Git:

twenty_secrets.yml
*.pem
.env
*.retry

The SSH private key is also kept outside the Git repository.

## Deployment Architecture
AWS EC2
    |
    v
Docker
    |
    +-- Twenty CRM
    |
    +-- PostgreSQL
    |
    +-- Redis
    |
    v
Health Check
    |
    v
Application Verification

## Complete Deployment Process
1. Terraform creates the EC2 instance.
2. Get the EC2 public IP.
3. Add the public IP to the Ansible inventory.
4. Ansible connects to the EC2 instance through SSH.
5. Install and configure Docker.
6. Create the Twenty CRM application directory.
7. Configure environment variables.
8. Create Docker Compose configuration.
9. Deploy Twenty CRM.
10. Configure restart policy.
11. Configure health check.
12. Verify the application.
13. Check Docker containers.
14. Check application logs.

## Verification Checklist
- Terraform infrastructure created
- Default VPC used
- Default subnet used
- EC2 t3.small created
- Security group configured
- SSH connection verified
- Ansible inventory configured
- Server packages updated
- Docker installed
- Docker Compose installed
- Docker service started
- Application directory created
- Environment variables configured
- Twenty CRM deployed
- PostgreSQL deployed
- Redis deployed
- Restart policy configured
- Health check configured
- Application verified
- Docker status verified
- Application logs verified
- Ansible completed with failed=0

## Cleanup
After completing the Loom recording and PR submission, the EC2 infrastructure will be destroyed using Terraform.

Command:
terraform destroy -auto-approve
Expected result:
Destroy complete!
## Conclusion

Task 17 was completed using Terraform and Ansible.

Terraform was used to create the AWS EC2 infrastructure, and Ansible was used to configure the server and deploy Twenty CRM using Docker Compose.

Twenty CRM was successfully deployed with PostgreSQL and Redis. The application was accessible through the EC2 public IP, the Docker health check returned healthy, the application logs were verified, and the Ansible playbook completed with zero failures.
