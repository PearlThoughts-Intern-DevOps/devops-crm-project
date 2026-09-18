Task 17: Ansible and AWS EC2 Deployment
Objective

Deploy the Twenty CRM application on an AWS EC2 instance using Terraform and Ansible.

Infrastructure

The EC2 instance was provisioned using Terraform with the following configuration:

AWS Region: us-east-1
Instance Type: t3.small
AMI: ami-0b6d9d3d33ba97d99 / ami-081b0a6eac00b4f53
VPC: Default VPC
Subnet: Default VPC subnet
Deployment Tool: Terraform
Configuration Management: Ansible
Application: Twenty CRM

The EC2 public IP was added to the Ansible inventory.

Ansible Configuration

Ansible was used to configure the EC2 instance and deploy the application.

The playbook performs the following tasks:

Updates server packages.
Installs Docker.
Installs required Docker dependencies.
Adds the required user to the Docker group.
Creates the application directory.
Copies the Twenty CRM Docker Compose configuration.
Pulls the required Docker images.
Starts the Twenty CRM application.
Waits for the application containers to initialize.
Displays Docker container status.
Inspects the Twenty CRM container.
Displays the container health status.
Verifies the application response on port 3000.
Displays Twenty CRM application logs.
Twenty CRM Docker Configuration

Twenty CRM was deployed using Docker Compose.

The application container uses:

Image: twentycrm/twenty:v2.35.0
Container: twenty_crm_app
Port: 3000
Restart Policy: unless-stopped
Health Check: Configured using an HTTP check against port 3000

The supporting containers are:

twenty_crm_db — PostgreSQL
twenty_crm_cache — Redis

All containers use the crm-network Docker network.

Environment Variables

The Twenty CRM deployment was configured with the required environment variables, including:

PG_DATABASE_URL
REDIS_URL
SERVER_URL
PORT
NODE_PORT
APP_SECRET
ENCRYPTION_KEY
STORAGE_TYPE
DISABLE_CRON_JOBS_REGISTRATION
DISABLE_DB_MIGRATIONS
Deployment Verification

The Ansible playbook completed successfully with:

ok=18
changed=3
unreachable=0
failed=0
skipped=0
rescued=0
ignored=0

The Twenty CRM application was verified as running and healthy.

Example verification:

Status=running
Health=healthy
RestartCount=0

The Docker container status showed the Twenty CRM application and its supporting PostgreSQL and Redis containers running successfully.

Restart Policy Verification

The Twenty CRM application container was inspected to verify the configured restart policy:

Container=/twenty_crm_app
RestartPolicy=unless-stopped

The Docker Compose configuration also contains:

restart: unless-stopped

for the Twenty CRM application and supporting services.

Health Check Verification

The Twenty CRM application has a Docker health check configured to verify the application endpoint on port 3000.

The final application verification showed:

Status=running
Health=healthy
Failure and Recovery Test

A container failure test was performed by stopping the Twenty CRM application container using:

docker kill twenty_crm_app

The container exited with:

ExitCode=137
Status=exited

The container was subsequently started again and verified successfully.

Final verification:

Status=running
Health=healthy

The restart policy was also verified as:

RestartPolicy=unless-stopped
Application Logs

Twenty CRM application logs were inspected using:

docker logs --tail 50 twenty_crm_app

The logs showed successful application initialization, including:

Nest application successfully started

This confirmed that the Twenty CRM application started successfully.

Final Verification

The following items were verified during deployment:

EC2 instance provisioned using Terraform.
EC2 public IP configured in Ansible inventory.
Docker installed and configured.
Twenty CRM deployed using Docker Compose.
PostgreSQL and Redis containers running.
Twenty CRM application running on port 3000.
Docker restart policy configured as unless-stopped.
Docker health check configured.
Application health verified as healthy.
Application logs verified.
Ansible playbook completed without failures.
Git Branch

The Task 17 work was completed on:

Ekta-Task-17
Cleanup

After completing the required verification, documentation, screenshots, Loom recording, and Pull Request, the EC2 infrastructure will be destroyed using Terraform:

terraform destroy

This ensures that the temporary AWS infrastructure created for Task 17 is removed after completion.
