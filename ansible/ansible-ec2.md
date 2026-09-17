# Ansible and AWS EC2 Deployment

## Infrastructure Setup with Terraform

I started by creating an AWS EC2 instance using Terraform. I configured the deployment in the `us-east-1` region and used a `t3.small` instance with the required Amazon Linux AMI. I used the default VPC and its default subnet instead of creating new networking resources. I also configured a security group to allow SSH access from my IP and application traffic through port 2020.

After running the Terraform configuration, I successfully created the EC2 instance and obtained its public IP address. This IP was then used for the Ansible inventory.

## Configuring Ansible Connectivity

I used Ansible from WSL Ubuntu because Ansible was not available directly in my Windows PowerShell environment. I created an inventory file containing the EC2 public IP, the `ec2-user`, and the SSH private key.

Initially, the Windows-mounted SSH key had permission issues inside WSL. To avoid spending unnecessary time on Windows mount permissions, I copied the key into my WSL home directory and changed its permissions to `600`. After that, I tested the connection using the Ansible ping module and received a successful `pong` response.

This confirmed that Ansible could communicate with the EC2 instance correctly.

## Preparing the EC2 Server

Once connectivity was working, I created an Ansible playbook to prepare the server. The playbook updated the installed packages and installed the required packages for the deployment, including Docker, Git, and Wget.

During package installation, I encountered a conflict between Amazon Linux's existing `curl-minimal` package and the full `curl` package. I removed `curl` from the Ansible package list because it was not necessary for the deployment.

I then started Docker, enabled it to start automatically when the EC2 instance boots, and added `ec2-user` to the Docker group. I also verified the Docker installation and confirmed Docker version `25.0.14`.

## Installing Docker Compose

Next, I configured Docker Compose through Ansible. I created the Docker CLI plugins directory and installed Docker Compose there. The installation was successful, and I verified Docker Compose version `v5.5.1`.

At this point, the EC2 server was fully prepared to run the application.

## Configuring Twenty CRM

I created `/opt/twenty` as the deployment directory on the EC2 instance and created a data directory inside it. I then prepared a single `docker-compose.yml` containing PostgreSQL, Redis, and the Twenty CRM server.

The Compose configuration included restart policies and health checks for the containers. PostgreSQL and Redis were configured as dependencies for the Twenty server, so the application would wait for them to become healthy before starting.

I also created a `.env` file for environment variables such as the PostgreSQL password, application secret, and server URL. Both the Compose file and `.env` were copied to the EC2 instance using Ansible.

## Deployment and Troubleshooting

Before starting the application, I validated the Compose configuration and pulled the required Docker images. When I started the stack, PostgreSQL and Redis became healthy, but the Twenty server initially kept restarting.

The first problem was caused by special characters in the PostgreSQL password being used inside the database connection URL. After changing the password, PostgreSQL still rejected authentication because the database volume had already been initialized with the previous password. Since this was a fresh deployment, I removed the Docker volumes and recreated the containers.

After that, the database connection worked, migrations completed successfully, and the Twenty CRM server became healthy.

## Verification and Recovery Testing

Finally, I verified that all three containers were healthy and that the application was accessible through port 2020. I also checked the server logs to confirm successful startup.

The deployment was therefore completed using Terraform for infrastructure, Ansible for server configuration and deployment, and Docker Compose for running Twenty CRM and its supporting services. The next part of the process is testing automatic container recovery and EC2 reboot recovery.
