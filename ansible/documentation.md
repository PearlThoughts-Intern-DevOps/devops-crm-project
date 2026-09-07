# Task 9 -- Ansible Automation for Twenty CRM

## 1. Overview

This project automates the deployment of **Twenty CRM** using
**Ansible**.

The automation performs the following:

-   Defines the target host through an Ansible inventory.
-   Installs required dependencies.
-   Installs and starts Docker.
-   Creates a dedicated application user.
-   Creates the application directory.
-   Copies the Twenty CRM project source.
-   Generates environment configuration using a Jinja2 template.
-   Generates Docker Compose configuration using a Jinja2 template.
-   Starts Twenty CRM, PostgreSQL, and Redis using Docker Compose.
-   Uses an Ansible handler to restart Twenty CRM when configuration
    changes.
-   Verifies the running containers.
-   Supports repeated execution without unnecessary changes
    (idempotency).

------------------------------------------------------------------------

## 2. Environment

The implementation was tested in a Killercoda Ansible playground.

Environment used:

-   OS: Ubuntu 24.04.4 LTS
-   User: root
-   Ansible Core: 2.16.3
-   Docker: 29.1.3
-   Repository:
    `https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git`
-   Ansible branch: `karthikeyan-task9`
-   Twenty CRM application port: `2020`

> Note: The original configuration used port `3000`. It was changed to
> host port `2020`, mapped to the Twenty CRM container port `3000`.

------------------------------------------------------------------------

## 3. Project Structure

The Ansible implementation is organized as follows:

``` text
devops-crm-project/
└── ansible/
    ├── inventory.ini
    ├── site.yml
    ├── handlers/
    │   └── main.yml
    └── templates/
        ├── .env.j2
        └── docker-compose.yml.j2
```

### File descriptions

  File                                Purpose
  ----------------------------------- -------------------------------------------
  `inventory.ini`                     Defines the Ansible target host
  `site.yml`                          Main Ansible playbook
  `handlers/main.yml`                 Contains the restart handler
  `templates/.env.j2`                 Jinja2 environment configuration template
  `templates/docker-compose.yml.j2`   Jinja2 Docker Compose template

------------------------------------------------------------------------

# 4. Ansible Inventory

File:

``` text
ansible/inventory.ini
```

Content:

``` ini
[twenty]
localhost ansible_connection=local
```

The inventory defines a host group called `twenty`.

The target is `localhost`, and:

``` ini
ansible_connection=local
```

tells Ansible to execute the tasks locally on the Killercoda machine.

------------------------------------------------------------------------

# 5. Main Ansible Playbook

File:

``` text
ansible/site.yml
```

The playbook starts with:

``` yaml
---
- name: Deploy Twenty CRM
  hosts: twenty
  become: true
```

This means:

-   The play is named `Deploy Twenty CRM`.
-   Tasks run against hosts in the `twenty` inventory group.
-   Privilege escalation is enabled.

------------------------------------------------------------------------

## 5.1 Variables

The playbook defines:

``` yaml
vars:
  app_user: twenty
  app_dir: /opt/twenty
  twenty_repo: "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
  twenty_port: 2020
```

### Variable purposes

  Variable        Value               Purpose
  --------------- ------------------- -------------------------------------
  `app_user`      `twenty`            Dedicated application user
  `app_dir`       `/opt/twenty`       Application deployment directory
  `twenty_repo`   GitHub repository   Repository reference
  `twenty_port`   `2020`              Host port used to access Twenty CRM

------------------------------------------------------------------------

# 6. Installing Dependencies

The playbook installs:

``` yaml
- name: Install required dependencies
  ansible.builtin.apt:
    name:
      - git
      - curl
      - ca-certificates
      - docker.io
      - docker-compose-v2
    state: present
    update_cache: true
```

The dependencies are:

-   Git
-   curl
-   CA certificates
-   Docker
-   Docker Compose v2

Using:

``` yaml
state: present
```

makes the task idempotent because already-installed packages do not need
to be installed again.

------------------------------------------------------------------------

# 7. Docker Service

The Docker service is enabled and started:

``` yaml
- name: Ensure Docker service is running
  ansible.builtin.service:
    name: docker
    state: started
    enabled: true
```

This ensures Docker:

1.  Is running.
2.  Starts automatically with the system.

------------------------------------------------------------------------

# 8. Dedicated Application User

The playbook creates a dedicated system user:

``` yaml
- name: Create dedicated application user
  ansible.builtin.user:
    name: "{{ app_user }}"
    system: true
    shell: /bin/bash
    create_home: true
    groups: docker
    append: true
```

The user is:

``` text
twenty
```

The user is also added to the Docker group so Docker Compose commands
can be executed as the application user.

------------------------------------------------------------------------

# 9. Application Directory

The deployment directory is created at:

``` text
/opt/twenty
```

Configuration:

``` yaml
- name: Create application directory
  ansible.builtin.file:
    path: "{{ app_dir }}"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_user }}"
    mode: "0755"
```

The directory is owned by the dedicated `twenty` user and group.

------------------------------------------------------------------------

# 10. Application Source

The project source is copied into:

``` text
/opt/twenty/source/
```

The task uses Ansible's copy module:

``` yaml
- name: Copy Twenty CRM repository
  ansible.builtin.copy:
    src: "{{ playbook_dir }}/../"
    dest: "{{ app_dir }}/source/"
    owner: "{{ app_user }}"
    group: "{{ app_user }}"
    mode: preserve
  notify: Restart Twenty CRM
```

### Killercoda networking note

During the implementation, a direct GitHub clone from the Killercoda
environment timed out while connecting to GitHub over port 443.

Because of that playground networking limitation, the already-cloned
project source was copied locally into the deployment directory instead.

The repository URL is retained as the `twenty_repo` variable for
documentation and deployment configuration reference.

------------------------------------------------------------------------

# 11. Environment Configuration with Jinja2

File:

``` text
ansible/templates/.env.j2
```

The environment file is generated using Ansible's `template` module:

``` yaml
- name: Deploy environment configuration
  ansible.builtin.template:
    src: .env.j2
    dest: "{{ app_dir }}/.env"
    owner: "{{ app_user }}"
    group: "{{ app_user }}"
    mode: "0600"
  notify: Restart Twenty CRM
```

Important values include:

``` text
NODE_PORT={{ twenty_port }}
SERVER_URL=http://localhost:{{ twenty_port }}
PG_DATABASE_URL=postgresql://twenty:twenty_password@postgres:5432/twenty
REDIS_URL=redis://redis:6379
ENCRYPTION_KEY=<secret>
```

The `twenty_port` variable controls the exposed application port.

The generated `.env` file uses permission:

``` text
0600
```

so only the owner has read/write access.

### Security note

The encryption key is a secret and should **not** be committed to a
public Git repository.

Before publishing the project to GitHub, the hard-coded secret should be
replaced with a secure approach such as:

-   An Ansible Vault variable.
-   An environment variable supplied securely at runtime.
-   A CI/CD secret.
-   Another secret-management mechanism.

------------------------------------------------------------------------

# 12. Docker Compose Configuration

File:

``` text
ansible/templates/docker-compose.yml.j2
```

The template defines three services:

``` text
twenty
postgres
redis
```

------------------------------------------------------------------------

## 12.1 PostgreSQL

The PostgreSQL service uses:

``` yaml
image: postgres:16
```

It creates:

``` text
POSTGRES_USER: twenty
POSTGRES_PASSWORD: twenty_password
POSTGRES_DB: twenty
```

A persistent Docker volume is used:

``` text
postgres_data
```

A health check verifies that PostgreSQL is ready:

``` yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U twenty -d twenty"]
  interval: 5s
  timeout: 5s
  retries: 10
```

------------------------------------------------------------------------

## 12.2 Redis

Redis uses:

``` yaml
image: redis:7-alpine
```

It provides the Redis service required by Twenty CRM.

------------------------------------------------------------------------

## 12.3 Twenty CRM

Twenty CRM uses:

``` yaml
image: twentycrm/twenty:latest
```

The host port is mapped to the container's port 3000:

``` yaml
ports:
  - "2020:3000"
```

Therefore:

``` text
Killercoda host port 2020
        |
        v
Twenty CRM container port 3000
```

The service loads the generated environment file:

``` yaml
env_file:
  - .env
```

It also receives:

``` yaml
PG_DATABASE_URL: postgresql://twenty:twenty_password@postgres:5432/twenty
REDIS_URL: redis://redis:6379
```

Twenty CRM depends on PostgreSQL being healthy and Redis being started.

------------------------------------------------------------------------

# 13. Ansible Handler

A handler is used to restart the application when configuration changes.

Handler:

``` yaml
- name: Restart Twenty CRM
  ansible.builtin.command:
    cmd: docker compose up -d
    chdir: "{{ app_dir }}"
  become_user: "{{ app_user }}"
```

The environment configuration and Docker Compose configuration notify
this handler.

For example:

``` yaml
notify: Restart Twenty CRM
```

This means the handler is triggered only when the notifying task reports
a change.

This avoids restarting the application unnecessarily on every playbook
run.

------------------------------------------------------------------------

# 14. Starting Twenty CRM

The playbook starts the Docker Compose stack:

``` yaml
- name: Start Twenty CRM
  ansible.builtin.command:
    cmd: docker compose up -d
    chdir: "{{ app_dir }}"
  become_user: "{{ app_user }}"
```

The application user runs the Compose command from:

``` text
/opt/twenty
```

------------------------------------------------------------------------

# 15. Verification

The playbook checks the Compose status:

``` yaml
- name: Verify Twenty CRM container
  ansible.builtin.command:
    cmd: docker compose ps
    chdir: "{{ app_dir }}"
  become_user: "{{ app_user }}"
  register: compose_status
  changed_when: false
```

The result is then displayed:

``` yaml
- name: Display Twenty CRM status
  ansible.builtin.debug:
    var: compose_status.stdout
```

------------------------------------------------------------------------

# 16. Syntax Validation

Before executing the playbook, syntax was checked using:

``` bash
cd ~/devops-crm-project/ansible

ansible-playbook -i inventory.ini site.yml --syntax-check
```

A successful syntax check confirms that the YAML and Ansible playbook
structure can be parsed.

------------------------------------------------------------------------

# 17. Deployment

The complete playbook is executed using:

``` bash
ansible-playbook -i inventory.ini site.yml
```

The successful deployment produced:

``` text
PLAY RECAP
localhost : ok=12 changed=4 unreachable=0 failed=0 skipped=0
```

After configuration changes, the handler was also executed successfully.

------------------------------------------------------------------------

# 18. Docker Verification

The running containers can be checked with:

``` bash
docker ps
```

The expected deployment contains:

``` text
twenty
twenty-postgres
twenty-redis
```

The Twenty CRM port mapping is:

``` text
0.0.0.0:2020->3000/tcp
```

PostgreSQL should show:

``` text
healthy
```

and Redis should show:

``` text
Up
```

------------------------------------------------------------------------

# 19. Application Verification

The application can be tested from the Killercoda machine using:

``` bash
curl -I http://localhost:2020
```

A successful response should contain:

``` text
HTTP/1.1 200 OK
```

The application HTML can also be checked using:

``` bash
curl -s http://localhost:2020 | head -20
```

The Twenty CRM page contains the application metadata, including:

``` text
A modern open-source CRM
```

------------------------------------------------------------------------

# 20. Browser Access

The Twenty CRM container is running inside the Killercoda environment.

Therefore:

``` text
http://localhost:2020
```

from the **Killercoda environment** refers to the Killercoda machine.

It does not automatically mean:

``` text
http://localhost:2020
```

from the user's Windows computer.

For browser access through Killercoda, the platform's port
forwarding/network feature should be used for port `2020`.

------------------------------------------------------------------------

# 21. Idempotency

Idempotency means that running the same Ansible playbook repeatedly
should not make unnecessary changes.

The playbook was run a second time:

``` bash
ansible-playbook -i inventory.ini site.yml
```

The clean second run produced:

``` text
PLAY RECAP
localhost : ok=11 changed=0 unreachable=0 failed=0 skipped=0
```

The important result is:

``` text
changed=0
failed=0
```

This demonstrates that the deployment is idempotent in the tested
environment.

------------------------------------------------------------------------

# 22. Handler Verification

The handler can be demonstrated by changing a configuration value
managed by the template.

For example:

``` bash
cd ~/devops-crm-project/ansible
nano templates/.env.j2
```

After making a configuration change, run:

``` bash
ansible-playbook -i inventory.ini site.yml
```

The playbook should show:

``` text
RUNNING HANDLER [Restart Twenty CRM]
```

This demonstrates that a configuration change triggers the application
restart handler.

------------------------------------------------------------------------

# 23. Useful Verification Commands

### Check Docker containers

``` bash
docker ps
```

### Check Twenty CRM logs

``` bash
docker logs --tail 30 twenty
```

### Check Compose status

``` bash
docker compose -f /opt/twenty/docker-compose.yml ps
```

### Check application HTTP response

``` bash
curl -I http://localhost:2020
```

### Check application HTML

``` bash
curl -s http://localhost:2020 | head -20
```

### Run Ansible syntax check

``` bash
cd ~/devops-crm-project/ansible
ansible-playbook -i inventory.ini site.yml --syntax-check
```

### Run deployment

``` bash
ansible-playbook -i inventory.ini site.yml
```

------------------------------------------------------------------------

# 24. Evidence / Screenshot Checklist

The following screenshots can be used as Task 9 evidence.

## Screenshot 1 -- Ansible project structure

``` bash
cd ~/devops-crm-project
find ansible -maxdepth 2 -type f -print
```

## Screenshot 2 -- Inventory

``` bash
cd ~/devops-crm-project/ansible
cat inventory.ini
```

## Screenshot 3 -- Templates

``` bash
sed 's/^ENCRYPTION_KEY=.*/ENCRYPTION_KEY=***REDACTED***/' templates/.env.j2
cat templates/docker-compose.yml.j2
```

Do not expose the real encryption key in screenshots.

## Screenshot 4 -- Syntax check

``` bash
ansible-playbook -i inventory.ini site.yml --syntax-check
```

## Screenshot 5 -- Deployment and handler

``` bash
ansible-playbook -i inventory.ini site.yml
```

The screenshot should show successful tasks and, when a configuration
change was made:

``` text
RUNNING HANDLER [Restart Twenty CRM]
```

## Screenshot 6 -- Docker containers

``` bash
docker ps
```

## Screenshot 7 -- Application verification

``` bash
curl -I http://localhost:2020
```

Expected:

``` text
HTTP/1.1 200 OK
```

## Screenshot 8 -- Idempotency

``` bash
ansible-playbook -i inventory.ini site.yml
```

Expected:

``` text
changed=0
failed=0
```

------------------------------------------------------------------------

# 25. Local Backup

The Ansible directory was backed up from Killercoda into:

``` text
task9-ansible.tar.gz
```

The archive was then extracted on Windows.

The local Ansible files are available under:

``` text
D:\Project\devops-crm-project\ansible
```

with the structure:

``` text
ansible/
├── inventory.ini
├── site.yml
├── handlers/
│   └── main.yml
└── templates/
    ├── .env.j2
    └── docker-compose.yml.j2
```

------------------------------------------------------------------------

# 26. GitHub / PR Preparation

Before pushing the implementation to GitHub:

1.  Review the Ansible files.
2.  Remove or securely manage the encryption secret.
3.  Verify that no credentials or secrets are committed.
4.  Review the port configuration (`2020`).
5.  Review the README/documentation.
6.  Commit the Task 9 implementation to the branch:

``` text
karthikeyan-task9
```

7.  Push the branch to the repository.
8.  Create a Pull Request.
9.  Add screenshots/evidence as required by the assignment.
10. Record the Loom walkthrough with face visible if required.

------------------------------------------------------------------------

# 27. Task 9 Completion Summary

The implementation satisfies the main automation requirements:

-   [x] Ansible inventory created.
-   [x] Required dependencies installed.
-   [x] Docker service enabled and started.
-   [x] Dedicated application user created.
-   [x] Application directory created with ownership and permissions.
-   [x] Twenty CRM source deployed.
-   [x] Environment configuration managed through Jinja2.
-   [x] Docker Compose configuration managed through Jinja2.
-   [x] PostgreSQL configured.
-   [x] Redis configured.
-   [x] Twenty CRM configured.
-   [x] Ansible handler configured.
-   [x] Twenty CRM started using Docker Compose.
-   [x] Docker containers verified.
-   [x] HTTP application response verified.
-   [x] Idempotency verified with a second playbook run.
-   [x] Ansible implementation backed up locally.

------------------------------------------------------------------------

# 28. Final Verification Commands

For a final demonstration, run:

``` bash
cd ~/devops-crm-project/ansible
```

Then:

``` bash
ansible-playbook -i inventory.ini site.yml --syntax-check
```

Then:

``` bash
ansible-playbook -i inventory.ini site.yml
```

Then:

``` bash
docker ps
```

Finally:

``` bash
curl -I http://localhost:2020
```

A successful final state should show:

``` text
Syntax OK
failed=0
Twenty CRM container running
PostgreSQL healthy
Redis running
HTTP/1.1 200 OK
```

------------------------------------------------------------------------

## Conclusion

This Task 9 implementation demonstrates an Ansible-based deployment of
Twenty CRM with Docker Compose, PostgreSQL, and Redis.

The deployment is parameterized using Ansible variables, configuration
is generated using Jinja2 templates, configuration changes trigger an
Ansible handler, and repeated playbook execution was verified to be
idempotent.
