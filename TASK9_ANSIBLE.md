# Task 9: Ansible Automation – Twenty CRM Deployment

**Name:** Harish 
**Date:** 4 September 2026 
**Task:** Automate the deployment and configuration of Twenty CRM using Ansible and Docker Compose.

## 1. Objective

The objective of this task was to automate the complete deployment of Twenty CRM using Ansible.

The automation includes:

- Installing required system dependencies.
- Installing and configuring Docker.
- Creating a dedicated application user.
- Creating required application directories.
- Cloning the official Twenty CRM repository.
- Managing application configuration through Ansible variables.
- Generating the `.env` file using Jinja2.
- Starting Twenty CRM using Docker Compose.
- Implementing a handler for configuration-based restarts.
- Verifying application availability.
- Testing idempotency.

---

## 2. Key Ansible Concepts Learned

### Inventory

Defines the managed hosts where Ansible executes tasks.

### Playbook

A YAML file that describes the desired configuration and deployment steps.

### Tasks

Individual actions performed by Ansible, such as installing packages, creating users, cloning repositories, and starting services.

### Modules

Reusable Ansible components used to perform operations such as `apt`, `user`, `file`, `git`, `template`, and Docker modules.

### Variables

Used to store configurable values such as application user, directories, ports, repository URL, and application settings.

### Jinja2 Templates

Used to dynamically generate the Twenty CRM `.env` configuration file from Ansible variables.

### Handlers

Special tasks triggered only when a configuration change occurs. The Twenty CRM Docker Compose stack is restarted when the `.env` configuration changes.

### Become

Used to execute privileged operations with elevated permissions.

### Idempotency

Ensures that running the same playbook multiple times does not unnecessarily recreate or modify resources that are already in the desired state.

### Facts

Ansible can gather information about the managed system, such as operating system, hostname, network, and hardware details.

### Collections

Ansible Collections provide additional modules and plugins. The `community.docker` collection was used for Docker Compose management.

### Register and Conditions

Task results can be registered and used for verification, retries, and conditional execution.

---

## 3. Work Completed

- Created an Ansible project for Twenty CRM deployment.
- Configured an Ansible inventory.
- Created the main deployment playbook.
- Added centralized Ansible variables.
- Configured Docker installation and service management.
- Created a dedicated `twentyapp` application user and group.
- Added the application user to the Docker group.
- Created the application directory structure.
- Cloned the official Twenty CRM repository.
- Configured Twenty CRM using Jinja2 templating.
- Added Docker Compose deployment using the `community.docker` collection.
- Added an Ansible handler to restart the application when configuration changes.
- Added application health verification.
- Tested repeated playbook execution for idempotency.

---

## 4. Ansible Project Structure

```text
ansible/
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── group_vars/
│   └── all.yml
└── templates/
    └── env.j2
```

### Purpose of Each File

| **File** | **Purpose** |
|---|---|
| `ansible.cfg` | Ansible configuration settings |
| `inventory.ini` | Defines the target host(s) |
| `playbook.yml` | Main automation workflow |
| `group_vars/all.yml` | Centralized deployment variables |
| `templates/env.j2` | Jinja2 template for application configuration |

---

## 5. Deployment Process

### Step 1: Prepare the Environment

Ansible and required base tools were installed on the Linux playground environment.

### Step 2: Configure Inventory

The target Linux system was added to the Ansible inventory file.

### Step 3: Install Dependencies

Ansible installed Git, curl, certificates, GnuPG, Docker, Docker Compose, and the Python Docker SDK.

### Step 4: Configure Docker

The official Docker repository was configured, and the Docker service was enabled and started.

### Step 5: Create Application User

A dedicated `twentyapp` user and group were created to run the Twenty CRM application securely.

### Step 6: Prepare Application Directory

The `/opt/twenty-crm` directory was created with appropriate ownership and permissions.

### Step 7: Clone Twenty CRM

The official Twenty CRM repository was cloned using Ansible's `git` module.

### Step 8: Configure Environment

Ansible variables were processed with a Jinja2 template to generate the Twenty CRM `.env` configuration file.

### Step 9: Start Docker Compose

The Twenty CRM Docker Compose stack was launched using the Ansible `community.docker` collection.

### Step 10: Verify Application

Ansible waited for Twenty CRM to become available and verified its HTTP response.

---

## 6. Commands Used

### 6.1 Environment Setup & Execution

Update system packages and install prerequisites:

```
sudo apt update && sudo apt install -y ansible git

```

Clone the project repository:
```
sudo apt update && sudo apt install -y ansible git
```
Execute the playbook:

```
ansible-playbook -i inventory.ini playbook.yml
```
### 6.2 Error Handling and Troubleshooting

Check Docker container logs if Twenty CRM fails to start:

```
sudo docker logs twenty-server-1
```
Recreate the application stack from the Docker Compose directory when manual reset is required:

```
cd /opt/twenty-crm/twenty/packages/twenty-docker
sudo docker compose down
sudo docker compose up -d --force-recreate
```
Return to the Ansible project directory:

```
cd ~/devops-crm-project/ansible
```
### 6.3 Application Verification
Verify running containers and service response:

```
sudo docker ps
curl -I http://localhost:3000
```
### 6.4 Idempotency Testing
Run the playbook again to confirm no unnecessary changes occur:

```
ansible-playbook -i inventory.ini playbook.yml
```
---

## 7. Troubleshooting and Issues Faced

### Docker Package Installation Issue
- **Issue:** The initial Docker package installation encountered package availability and repository issues.
- **Resolution:** Configured the official Docker repository and installed `docker-ce`, `docker-compose-plugin`, and the required dependencies directly.

### Python Docker SDK Issue
- **Issue:** The Docker Ansible module required the Python Docker SDK, but `pip` installation was blocked by the PEP 668 externally-managed-environment restriction.
- **Resolution:** Installed the OS distribution package `python3-docker` via `apt`.

### Ansible Privilege Escalation Issue
- **Issue:** Ansible encountered temporary file permission and ACL issues while switching to the non-root application user (`twentyapp`).
- **Resolution:** Adjusted the `ansible.cfg` configuration to allow the required temporary-file behavior and configured the appropriate `become` settings.

### Disk Space Issue
- **Issue:** The Twenty CRM repository and Docker build process consumed significant disk space.
- **Resolution:** Implemented a shallow Git clone using `depth: 1` and configured Docker Compose to use prebuilt images instead of building locally.

### Twenty CRM Container Failure
- **Issue:** The Twenty CRM server container initially failed health checks because required environment variables were missing or did not meet minimum secret length requirements.
- **Resolution:** Defined the required application secrets and variables inside `group_vars/all.yml` and rendered them using the `env.j2` template.

### Repository Configuration Issue
- **Issue:** The repository URL specified was incorrect.
- **Resolution:** Updated the configuration variable to point to the correct official Twenty CRM repository.

---

## 8. Application Verification

The deployment was verified using Docker and HTTP checks.

**Verification Confirmed:**
- Docker service was running and active.
- Twenty CRM containers were successfully created.
- Twenty CRM server container passed health checks.
- Port `3000` was open and accessible.
- HTTP requests to the application returned a successful status (`HTTP/1.1 200 OK`).
- Twenty CRM was accessible through the configured server URL.

---

## 9. Handler Verification

Ansible handlers were implemented to restart Twenty CRM **only** when the application configuration changed.

The `.env` file is managed through the Jinja2 template:
- **When the template changes:** Ansible detects the configuration change, marks the task as `changed`, and triggers the handler. Docker Compose then restarts the stack.
- **When the template is unchanged:** The task returns `ok`, and the handler is skipped.

---

## 10. Idempotency Verification

The playbook was executed multiple times to verify idempotency.

During subsequent executions, Ansible checked the system state instead of recreating existing resources:
- Existing packages remained installed.
- Existing user and group remained unchanged.
- Application directories remained intact.
- Git repository was not re-cloned unnecessarily.
- Configuration `.env` remained unchanged.
- Docker Compose did not restart unchanged containers.
- Handlers did not execute unless triggered by a configuration change.

This verified the declarative and idempotent behavior of the Ansible playbook.

---

## 11. Security Considerations

- **Non-Root Execution:** A dedicated `twentyapp` application user was created rather than running services as `root`.
- **File Permissions:** The `.env` configuration file was created with restricted permissions (`0600` / `0640`) and owned by `twentyapp`.
- **Group Isolation:** Docker socket access was granted specifically to the dedicated application user group.
- **Secret Management:** Application secrets were abstracted out of playbook tasks into variables. For production deployments, sensitive values in `group_vars` should be encrypted using **Ansible Vault**.