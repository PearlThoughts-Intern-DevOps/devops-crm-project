Task 9 - Ansible Playbook for Twenty CRM
Objective

Automate the deployment of Twenty CRM using Ansible inside a Linux playground.

Requirements Implemented

The Ansible playbook performs the following tasks:

Creates an inventory containing the target host.
Installs required dependencies including Git, Docker, and Docker Compose.
Ensures the Docker service is running and enabled.
Creates a dedicated twenty application user.
Creates the required application directories with appropriate ownership and permissions.
Clones the Twenty CRM repository from GitHub.
Creates the Docker Compose deployment directory.
Copies the Twenty CRM Docker Compose configuration.
Configures Twenty CRM using Ansible variables and a Jinja2 template.
Starts Twenty CRM using Docker Compose.
Uses an Ansible handler to restart/redeploy the application when configuration changes.
Verifies that Twenty CRM responds successfully.
Uses Ansible modules and conditional changes to support idempotent execution.
Project Structure
task9-ansible/
├── inventory.ini
├── site.yml
├── README.md
└── templates/
    └── twenty.env.j2

Inventory

The inventory.ini file defines the target host:

[twenty]
localhost ansible_connection=local

Ansible Playbook

The main playbook is site.yml.

Run the playbook with:

ansible-playbook -i inventory.ini site.yml


The playbook installs dependencies, creates the application user and directories, clones Twenty CRM, configures the application, starts Docker Compose, and verifies the application.

Configuration

The file templates/twenty.env.j2 is a Jinja2 template used to generate the Twenty CRM environment configuration.

Variables such as the server URL, encryption key, and PostgreSQL password are defined through Ansible variables.

The environment file is created with restricted permissions.

The credentials used in this playground deployment are demonstration values only. Production deployments should use Ansible Vault or another secure secret-management solution.

Docker Compose

The playbook copies the Twenty CRM Docker Compose configuration into:

/opt/twenty/compose/


Twenty CRM is started using:

docker compose up -d

Handler

An Ansible handler named Restart Twenty is triggered when configuration files change.

This ensures that configuration changes cause the application to be redeployed/restarted when required.

Verification

The playbook verifies the application using Ansible's uri module.

It checks:

http://localhost:3000


The playbook retries the check until the application returns HTTP status 200.

Additional verification can be performed using:

docker ps


and:

docker compose ps

Idempotency

The playbook is designed to be idempotent. Ansible modules such as apt, user, file, git, copy, and template maintain the desired state without making unnecessary changes.

Running the playbook again after the deployment is already configured should result in few or no changes.

What I Learned

Through this task I learned how to:

Write an Ansible inventory and playbook.
Automate Docker installation and configuration.
Create and manage application users with Ansible.
Use Jinja2 templates for application configuration.
Use Ansible handlers to respond to configuration changes.
Deploy an application using Docker Compose through Ansible.
Verify application availability automatically.
Design an Ansible playbook to be idempotent.
GitHub Submission

Branch:

ambu-task9


Latest implementation commit:

ab711b8 - Add Task 9 Ansible Twenty CRM deployment


Pull Request:

Task 9 Ansible Twenty CRM deployment (#195)
