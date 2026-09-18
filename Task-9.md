# Task 9: Ansible Automation for Twenty CRM

**Name:** Mujtaba Shaikh
**Task:** Task 9 – Ansible Automation
**Branch:** `Mujtaba-Task-9-PT`
**Date:** 4 September 2026
**Operating System:** Ubuntu 26.04 LTS
**Automation Tool:** Ansible 2.20.1
**Application:** Twenty CRM
**Container Platform:** Docker & Docker Compose

---

## 1. Objective

The objective of this task was to automate the complete setup and deployment of Twenty CRM using Ansible.

The Ansible playbook was created to:

* Install the required dependencies.
* Install and configure Docker.
* Create a dedicated application user and group.
* Create the application directory.
* Clone the Twenty CRM project repository.
* Configure the application using Ansible variables.
* Use a Jinja2 template for environment configuration.
* Start Twenty CRM using Docker Compose.
* Use an Ansible handler to restart the application when configuration changes.
* Verify that Twenty CRM is running.
* Test the playbook for idempotency.

---

## 2. Environment

The complete setup and testing were performed on an Ubuntu Linux playground server.

| Component        | Version / Details |
| ---------------- | ----------------- |
| Operating System | Ubuntu 26.04 LTS  |
| Git              | 2.53.0            |
| Ansible          | 2.20.1            |
| Python           | 3.14.4            |
| Docker           | 29.1.3            |
| Docker Compose   | 2.40.3            |
| Application      | Twenty CRM        |
| Application Port | 2020              |

---

## 3. Project Structure

The Ansible implementation was created inside the project repository:

```text
devops-crm-project/
│
├── docker-compose.yml
├── Dockerfile
├── Task-8.md
├── Task-9.md
│
└── ansible-mujtaba/
    │
    ├── site.yml
    │
    ├── inventory/
    │   └── hosts.ini
    │
    ├── group_vars/
    │   └── all.yml
    │
    ├── templates/
    │   └── twenty.env.j2
    │
    └── handlers/
        └── main.yml
```

---

## 4. Inventory Configuration

The inventory file defines the target host for the Ansible playbook.

File:

```text
ansible-mujtaba/inventory/hosts.ini
```

Configuration:

```ini
[twenty_crm]
localhost ansible_connection=local
```

The local connection was used because the Ansible playbook was tested directly on the assigned Linux playground server.

---

## 5. Ansible Variables

Application configuration was kept in a separate variables file.

File:

```text
ansible-mujtaba/group_vars/all.yml
```

Important variables include:

```yaml
app_name: twenty-crm
app_user: twenty
app_group: twenty
app_dir: /opt/twenty-crm
app_port: 2020

repo_url: https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
repo_branch: Mujtaba-Task-8-PT

twenty_image: twentycrm/twenty:latest
postgres_image: postgres:16
redis_image: redis:7-alpine

postgres_db: default
postgres_user: twenty
postgres_password: twenty
```

Using variables makes the playbook easier to understand and maintain.

---

## 6. Installing Dependencies

The playbook installs the required packages using Ansible's `apt` module.

The following packages were installed:

```yaml
- git
- curl
- docker.io
- docker-compose-v2
```

The Docker service was then started and enabled so that it starts automatically.

---

## 7. Dedicated Application User

A dedicated user and group were created for the application.

The playbook creates:

```text
User: twenty
Group: twenty
```

The `twenty` user was also added to the Docker group so that it can work with Docker without requiring Docker commands to be run as root.

---

## 8. Application Directory

The application directory was created at:

```text
/opt/twenty-crm
```

Ownership was configured for the dedicated application user:

```text
Owner: twenty
Group: twenty
Permissions: 0755
```

The repository source was stored under:

```text
/opt/twenty-crm/source
```

---

## 9. Repository Deployment

Ansible's `git` module was used to clone the project repository.

The repository contains the existing Twenty CRM Docker Compose configuration and Dockerfile.

The playbook deploys the selected repository branch:

```text
Mujtaba-Task-8-PT
```

This branch was used because the Task 9 branch was being created for the Ansible implementation itself.

---

## 10. Jinja2 Template

A Jinja2 template was created for environment configuration.

File:

```text
ansible-mujtaba/templates/twenty.env.j2
```

Template:

```jinja2
POSTGRES_DB={{ postgres_db }}
POSTGRES_USER={{ postgres_user }}
POSTGRES_PASSWORD={{ postgres_password }}
```

Ansible creates the environment file at:

```text
/opt/twenty-crm/.env
```

The configuration is generated from variables defined in `group_vars/all.yml`.

---

## 11. Docker Compose Deployment

The existing project `docker-compose.yml` was used instead of creating a duplicate Compose file inside the Ansible directory.

The Compose setup contains the following services:

```text
twenty
postgres
redis
app
```

The Twenty CRM service is exposed on:

```text
2020
```

The deployment was started using:

```bash
docker compose up -d
```

---

## 12. Ansible Handler

An Ansible handler was created to restart the application when configuration changes.

File:

```text
ansible-mujtaba/handlers/main.yml
```

Handler:

```yaml
---
- name: Restart Twenty CRM
  ansible.builtin.command:
    cmd: docker compose up -d
    chdir: "{{ app_dir }}"
```

Tasks such as configuration changes notify this handler.

The handler runs only when a notified task reports a change.

This demonstrates how Ansible handlers can be used to manage application restarts after configuration changes.

---

## 13. Dockerfile Handling

During deployment, the Docker build initially reported that the `.yarn` directory referenced by the Dockerfile was not available in the repository.

The Ansible playbook therefore removes the unnecessary `.yarn` copy instructions before the Docker image is built.

The Docker Compose build context was also configured to use:

```text
./source
```

This allowed the existing project Dockerfile and application source to be used for the build.

---

## 14. Ansible Playbook Execution

Before executing the playbook, its syntax was checked using:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --syntax-check
```

The syntax check completed successfully:

```text
playbook: site.yml
```

The complete deployment was then executed using:

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

The first successful deployment completed with:

```text
PLAY RECAP
localhost : ok=19 changed=5 unreachable=0 failed=0 skipped=0
```

The Ansible handler was also executed successfully:

```text
RUNNING HANDLER [Restart Twenty CRM]
changed: [localhost]
```

---

## 15. Docker Verification

After the playbook completed successfully, the Docker Compose services were checked using:

```bash
docker compose ps
```

The deployed services were running:

```text
twenty-app
twenty-crm
twenty-postgres
twenty-redis
```

The PostgreSQL and Redis services reported healthy status.

The Twenty CRM service was exposed on:

```text
0.0.0.0:2020 -> 3000
```

---

## 16. Application Verification

Twenty CRM was tested locally from the Linux playground server using:

```bash
curl -I http://localhost:2020
```

The application returned:

```text
HTTP/1.1 200 OK
```

This confirmed that the Twenty CRM application was responding successfully.

---

## 17. Idempotency

Ansible playbooks should be idempotent, meaning running the same playbook multiple times should not unnecessarily recreate or modify resources that are already in the desired state.

The playbook was tested by running it again after the initial successful deployment:

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

The second execution was used to verify that the existing configuration and application deployment remained stable.

---

## 18. Issues Encountered and Fixes

### Issue 1: Docker was not installed

Initially, Docker was not available on the playground server.

**Fix:** Docker and Docker Compose were added to the Ansible package installation task.

---

### Issue 2: Ubuntu package mirror problem

The default regional Ubuntu mirror was not responding correctly during `apt update`.

**Fix:** The Ubuntu repository configuration was changed to use the standard Ubuntu archive mirror.

After this change, package installation completed successfully.

---

### Issue 3: Dockerfile was not available in the deployment directory

Docker Compose initially expected the Dockerfile in `/opt/twenty-crm`.

**Fix:** The Ansible deployment was adjusted to use the repository Dockerfile and source directory correctly.

---

### Issue 4: Incorrect Docker build context

The Docker build initially attempted to use:

```text
/opt/twenty-crm/source/source
```

which did not exist.

**Fix:** The Docker Compose build context was corrected to:

```text
./source
```

---

### Issue 5: Missing `.yarn` directory

The Dockerfile referenced a `.yarn` directory that was not present in the repository.

**Fix:** Ansible removes the unnecessary `.yarn` copy instructions before the Docker build.

---

### Issue 6: Git detected local modifications

Ansible modified the deployed Dockerfile after cloning, which caused Git to detect local changes during subsequent deployment.

**Fix:** The Git task was configured with:

```yaml
force: true
```

so the repository could be synchronized correctly during deployment.

---

## 19. Final Result

The Twenty CRM environment was successfully automated using Ansible.

The implementation successfully demonstrated:

* Ansible inventory configuration.
* Package installation.
* Docker installation and service management.
* Dedicated application user creation.
* Application directory management.
* Git repository deployment.
* Ansible variables.
* Jinja2 templating.
* Docker Compose deployment.
* Ansible handlers.
* Application verification.
* Idempotency testing.

The final Docker Compose environment successfully started the required services and Twenty CRM responded with HTTP `200 OK`.

---

## 20. What I Learned

Through this task, I learned how Ansible can be used to automate an application's complete server setup instead of performing each step manually.

I learned how to:

1. Create an Ansible inventory.
2. Write an Ansible playbook.
3. Use Ansible variables.
4. Use Jinja2 templates.
5. Install packages using Ansible.
6. Manage Linux users and groups.
7. Manage Docker using Ansible.
8. Deploy source code using the Git module.
9. Use handlers for application changes.
10. Deploy applications using Docker Compose.
11. Verify services after deployment.
12. Test playbook idempotency.
13. Troubleshoot Docker build and deployment issues.

This task helped me understand how configuration management tools such as Ansible are used in real DevOps workflows to make deployments repeatable and easier to maintain.

---

## 21. Conclusion

Task 9 successfully automated the deployment of Twenty CRM using Ansible.

The playbook handles the required dependencies, Docker setup, application user, directories, repository deployment, configuration, Docker Compose startup, handler-based restart, and application verification.

This automation reduces manual deployment steps and provides a repeatable approach for deploying Twenty CRM on a Linux server.

