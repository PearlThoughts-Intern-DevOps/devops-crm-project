# Ansible Automation - Twenty CRM Deployment

## Overview
This document details the Ansible automation for deploying the Twenty CRM application. The playbook automates the entire setup process, ensuring a consistent, idempotent, and scalable deployment.

## Project Structure
- `ansible.cfg`: Ansible configuration to disable host key checking.
- `inventory.ini`: Defines the target host for deployment.
- `playbook.yml`: The main automation script containing all tasks and handlers.
- `templates/docker-compose.yml.j2`: Jinja2 template for dynamic Docker Compose configuration.
- `vars/main.yml`: Centralized variables for easy customization.

## Key Features Implemented
1. **Dedicated User & Permissions:** Creates a `twenty_user` and assigns appropriate directory permissions.
2. **Jinja2 Templating:** Dynamically injects server URLs and secrets into the `docker-compose.yml` file.
3. **Handlers:** Includes a handler to restart the application automatically if the configuration template changes.
4. **Idempotency:** The playbook can be run multiple times without altering the system state if no changes are required.
5. **Verification:** Uses the `uri` module to verify the application is responding on port 2020.

## How to Run
```bash
ansible-playbook playbook.yml
