# Task 9 – Ansible Playbook for Twenty CRM

## Objective

Automate the deployment of Twenty CRM using Ansible in a Linux playground environment.

The playbook installs required dependencies, configures Docker, creates a dedicated application user, clones the repository, generates configuration using Jinja2 templates, starts Twenty CRM using Docker Compose, verifies the application, and maintains idempotency.

## Environment

- Playground: Killercoda
- Operating System: Ubuntu 24.04 LTS
- Ansible
- Docker
- Docker Compose
- Git
- Python 3

## Project Structure

ansible/
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── all.yml
├── templates/
│   ├── docker-compose.yml.j2
│   └── .env.j2
└── site.yml

TASK9_ANSIBLE.md

## Ansible Inventory

The inventory defines the target host for the deployment.

[twenty]
localhost ansible_connection=local

Since Killercoda provides a local Linux environment, Ansible connects to the local machine.

## Variables

The variables are maintained in ansible/group_vars/all.yml.

Important variables include:

- Application user and group
- Application directory
- Repository URL and version
- Twenty CRM Docker image version
- Application and host ports
- PostgreSQL configuration
- Redis URL
- Application secret

Using variables makes the playbook reusable and avoids hard-coding configuration values throughout the playbook.

## Jinja2 Templates

### docker-compose.yml.j2

The Docker Compose configuration is generated dynamically using Ansible variables.

The deployment contains four services:

1. Twenty CRM server
2. Twenty CRM worker
3. PostgreSQL
4. Redis

Named Docker volumes are used for persistent application, database, and Redis data.

### .env.j2

The environment template generates application configuration from Ansible variables.

The generated .env file is stored with restricted permissions.

## Ansible Playbook

The main playbook is:

ansible/site.yml

The playbook performs the following operations:

1. Gather system facts.
2. Install required system dependencies.
3. Install Docker and Docker Compose.
4. Ensure the Docker service is running and enabled.
5. Create the dedicated twenty application group.
6. Create the dedicated twenty application user.
7. Add the application user to the Docker group.
8. Create /opt/twenty.
9. Clone the repository.
10. Generate the .env configuration using a Jinja2 template.
11. Generate the Docker Compose configuration using a Jinja2 template.
12. Start Twenty CRM using Docker Compose.
13. Wait for the HTTP endpoint.
14. Display the deployment verification result.

## Handler

A handler named Restart Twenty CRM is configured.

It is notified when configuration files change.

This prevents unnecessary restarts and ensures that configuration changes can be applied automatically.

## Docker Compose Architecture

Twenty CRM
    |
    +----------------+----------------+
    |                |                |
  Server           Worker           Redis
    |
 PostgreSQL

The Twenty server is exposed on:

http://localhost:3000

The server and database containers use health checks to ensure the required services are ready.

## Verification

After deployment, the following containers were verified:

- twenty-server
- twenty-worker
- twenty-db
- twenty-redis

The Twenty server was reported as healthy and the PostgreSQL and Redis containers were also healthy.

The Ansible playbook successfully verified the HTTP endpoint:

Twenty CRM is running successfully on http://localhost:3000

## Idempotency

The playbook was executed twice.

The second execution returned:

ok=13
changed=0
failed=0

This confirms that running the playbook repeatedly does not make unnecessary changes when the system is already in the desired state.

## Result

Twenty CRM was successfully deployed using Ansible on the Killercoda Ubuntu environment.

The implementation demonstrates:

- Ansible inventory management
- Variables
- Jinja2 templating
- Ansible handlers
- Docker automation
- Docker Compose
- Dedicated application users
- Service verification
- Idempotent infrastructure automation
