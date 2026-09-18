\# Task 17 – Terraform + Ansible Twenty CRM Deployment



\## Objective



Deploy and configure Twenty CRM using Terraform and Ansible, including Docker installation, application configuration, restart policy, health check, verification, and cleanup.



\## Environment



Practical Ansible testing was performed in a Killercoda Ubuntu 24.04 playground.



Docker:

\- Docker 29.1.3

\- Docker Compose 2.40.3



Ansible:

\- Ansible Core 2.16.3



\## Ansible Configuration



The Ansible playbook performs the following:



\- Installs Docker and Docker Compose.

\- Ensures Docker service is running.

\- Creates a dedicated `twenty` application user.

\- Creates `/opt/twenty`.

\- Deploys Twenty CRM environment configuration.

\- Deploys Docker Compose configuration.

\- Configures PostgreSQL and Redis.

\- Configures `restart: unless-stopped`.

\- Configures a Twenty CRM Docker health check.

\- Starts the application.

\- Verifies HTTP availability.

\- Displays Docker Compose status.

\- Uses a handler to restart the application when configuration changes.



\## Verification



The deployed Twenty CRM application was verified using:



```bash

docker compose ps

```

The Twenty CRM container reached:



Status=running

Health=healthy

RestartPolicy=unless-stopped



The application responded successfully:



HTTP/1.1 200 OK



Application logs were also checked and showed successful Nest application startup.



Failure Testing



The container was intentionally stopped using:



docker kill twenty



The container entered:



Exited (137)



Automatic restart was monitored in Killercoda. The container did not automatically restart in the available playground environment, so it was manually recovered using:



docker start twenty



After recovery, the container returned to a healthy state and HTTP access returned 200 OK.



EC2 Limitation



The assignment requires Terraform to create an AWS EC2 instance and Ansible to configure that instance.



The available AWS environment has previously returned explicit IAM permission denies for EC2 resource creation. Therefore, EC2 creation and EC2 stop/start validation could not be completed in the available environment.



The Ansible implementation and application deployment were instead validated in Killercoda.



No unverified EC2 success is claimed.



Conclusion



The Ansible automation for Twenty CRM, Docker deployment, restart policy, health check, application verification, failure simulation, recovery, and idempotency testing were completed in the available Killercoda environment.

