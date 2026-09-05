# Task 9: Ansible Playbook – Twenty CRM Automation

## Objective

Automate the deployment of Twenty CRM using Ansible on a Linux environment.

## Tools Used

- Ansible 2.16.3
- Docker 29.1.3
- Docker Compose 2.40.3
- Git
- Ubuntu 24.04
- Twenty CRM

## Project Structure

```text
ansible/
├── inventory
├── site.yml
└── templates/
    └── docker-compose.yml.j2
What the Playbook Does

The Ansible playbook automates the complete Twenty CRM setup:

Installs required dependencies.
Installs and starts Docker.
Creates a dedicated twenty application user.
Adds the application user to the Docker group.
Creates /opt/twenty.
Clones the Twenty CRM repository.
Uses Ansible variables for configuration.
Uses a Jinja2 template to generate Docker Compose configuration.
Starts Twenty CRM, PostgreSQL, and Redis using Docker Compose.
Uses an Ansible handler to restart Twenty CRM when the configuration changes.
Verifies the running containers.
Configuration Variables

The playbook uses variables including:

app_user
app_dir
repo_url
repo_version
compose_file
twenty_port
encryption_key

This makes the deployment configurable without modifying the main tasks.

Jinja2 Template

docker-compose.yml.j2 dynamically generates the Docker Compose configuration using Ansible variables.

The application is exposed on port 3001.

Verification

Twenty CRM was verified using:

curl -I http://localhost:3001

Result:

HTTP/1.1 200 OK

The running containers were:

twenty
twenty-postgres
twenty-redis
Idempotence Test

The playbook was executed a second time without changing the configuration.

Result:

localhost : ok=11 changed=0 unreachable=0 failed=0

changed=0 confirms that the second execution made no unnecessary changes.

Learning

Through this task I learned:

Ansible inventory and playbooks
Ansible variables
Jinja2 templates
Ansible handlers
Docker automation with Ansible
Idempotent infrastructure automation
Application verification
Automating repeatable server configuration
