# Task 9: Ansible Playbook – Twenty CRM

## Objective

Automate the setup and deployment of Twenty CRM using Ansible on a Linux environment.

## Implementation

The Ansible automation is located in the `ansible/` directory.

### Files

- `ansible/playbook.yml` – Main Ansible playbook.
- `ansible/inventory.ini` – Inventory containing the target host.
- `ansible/group_vars/all.yml` – Application and deployment variables.
- `ansible/templates/docker-compose.yml.j2` – Jinja2 Docker Compose template.
- `ansible/templates/.env.j2` – Jinja2 environment-file template.

## What the Playbook Automates

The playbook:

1. Installs required dependencies, including Git, Docker and Docker Compose.
2. Ensures the Docker service is enabled and running.
3. Creates a dedicated `twenty` application group and user.
4. Creates the application directory with appropriate ownership and permissions.
5. Creates an Ansible temporary directory for the application user.
6. Clones the Twenty CRM repository.
7. Generates the `.env` configuration using an Ansible/Jinja2 template.
8. Generates the Docker Compose configuration using an Ansible/Jinja2 template.
9. Starts Twenty CRM using Docker Compose.
10. Waits for the application HTTP endpoint to become available.
11. Runs the application deployer when required.
12. Creates a deployment marker after successful deployment.
13. Uses an Ansible handler to restart/recreate the application when configuration changes.
14. Verifies the running Docker container and HTTP endpoint.
15. Keeps subsequent executions idempotent by avoiding unnecessary deployment changes.

## Configuration and Variables

Deployment variables are defined in:

    ansible/group_vars/all.yml

The configuration includes:

- Application user and group
- Application directory
- Git repository URL and branch
- Twenty CRM Docker image
- Application port
- Container names
- API key lookup

Jinja2 templates are used to generate the Docker Compose configuration and environment file dynamically.

## Secret Handling

The Twenty CRM API key is supplied through the `TWENTY_API_KEY` environment variable.

The actual API key is **not stored in the repository**.

Set the API key before running the playbook:

    export TWENTY_API_KEY="YOUR_TWENTY_API_KEY"

The generated `.env` file is protected with restricted permissions, and the task that creates it uses Ansible `no_log` to prevent the API key from appearing in task output.

## Running the Playbook

From the repository root, run:

    ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

A syntax check can be performed with:

    ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --syntax-check

## Verification Environment

The complete setup was tested in a KodeKloud Ubuntu playground.

The playground was configured with:

- Ubuntu 24.04
- Ansible 2.16.3
- Docker 29.1.3
- Docker Compose 2.40.3
- Git 2.43.0

The local host was used as the Ansible target through the inventory configuration.

## Initial Deployment Verification

The first successful playbook execution verified:

- Twenty CRM HTTP status: `200`
- Twenty CRM container running successfully
- Port `2020` mapped to the application
- `failed=0`
- `unreachable=0`

Example verification:

    Twenty CRM HTTP status: 200
    twenty-crm-task9
    twentycrm/twenty-app-dev:latest
    Up
    0.0.0.0:2020->2020/tcp

## Idempotency Verification

The playbook was executed again without changing the configuration.

The final execution produced:

    PLAY RECAP
    localhost : ok=17 changed=0 unreachable=0 failed=0 skipped=2 rescued=0 ignored=0

The HTTP verification continued to report:

    Twenty CRM HTTP status: 200

This confirms that the subsequent execution made **zero changes** while Twenty CRM remained successfully available.

## Handler Verification

The playbook includes an Ansible handler named:

    Restart Twenty CRM application

The handler is notified when the generated configuration changes.

It recreates/restarts the Twenty CRM service using Docker Compose so that configuration changes are applied automatically.

## Result

Twenty CRM was successfully deployed and verified using Ansible in the KodeKloud Linux playground.

The implementation satisfies the required automation workflow and demonstrates:

- Idempotent execution
- Configuration management through Jinja2 templates
- Docker Compose deployment
- Application verification
- Handler-based application restart
- Secure API key handling

