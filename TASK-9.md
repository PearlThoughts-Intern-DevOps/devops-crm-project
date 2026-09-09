# Task 9 - Automate Twenty CRM Setup Using Ansible

## Objective

Automate the deployment of Twenty CRM using Ansible and Docker Compose in a Linux playground environment.

## Environment

- OS: Ubuntu 24.04.1 LTS
- Ansible: 2.16.3
- Docker: 29.1.3
- Docker Compose: 2.40.3
- Git: 2.43.0
- Playground: KodeKloud

## Implementation

The Ansible playbook performs the following:

1. Uses an Ansible inventory with the target host.
2. Installs Git, curl, CA certificates, Docker and Docker Compose.
3. Ensures the Docker service is running and enabled.
4. Creates a dedicated `twenty` application user and group.
5. Creates `/opt/twenty` with appropriate ownership and permissions.
6. Clones the Twenty CRM repository.
7. Uses Ansible variables from `vars/main.yml`.
8. Uses a Jinja2 template to generate the Docker Compose configuration.
9. Starts Twenty CRM, PostgreSQL and Redis using Docker Compose.
10. Uses an Ansible handler to restart the Twenty CRM container when the Compose configuration changes.
11. Verifies the application health endpoint.
12. Displays the final Docker Compose container status.

## Configuration

Application configuration is maintained in:

- `vars/main.yml`
- `templates/docker-compose.yml.j2`

The Jinja2 template uses variables for the application port, server URL, database configuration and encryption key.

## Handler

The playbook includes a handler named `Restart Twenty CRM`.

The handler runs:

`docker compose up -d --force-recreate twenty`

when the generated Docker Compose configuration changes.

## Verification

The deployment was tested successfully in the KodeKloud Ubuntu playground.

The Twenty CRM container was reported as healthy and exposed on port `2020`.

The PostgreSQL container was also reported as healthy, and Redis was running successfully.

## Idempotency Test

The playbook was executed twice.

First execution completed successfully with:

- `failed=0`

The second execution completed with:

- `changed=0`
- `failed=0`

This confirms that the playbook is idempotent when the system is already in the desired state.

## Useful Commands

Check inventory:

`ansible-inventory -i inventory.ini --list`

Run the playbook:

`ansible-playbook -i inventory.ini playbook.yml`

Check Docker Compose status:

`docker compose -f /opt/twenty/docker-compose.yml ps`

Check application health:

`curl http://localhost:2020/healthz`

## Learning

This task provided practical experience with Ansible inventories, variables, Jinja2 templates, handlers, Docker automation, Docker Compose, service verification and idempotent infrastructure automation.

> Note: The database credentials and encryption key used in this task are demo values for the playground environment and are not production credentials.
