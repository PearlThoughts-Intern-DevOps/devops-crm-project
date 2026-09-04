Task 9: Automate Twenty CRM with Ansible

Name: Barani Krishnan G  
Date: 04 September 2026  
Domain: Infrastructure as Code and DevOps Automation  
Environment: Ubuntu / KodeKloud Playground

---

1. Objective

The objective of this task is to automate the setup, configuration, and deployment of Twenty CRM using Ansible.

The Ansible playbook automates the following activities:

- Installation of required system dependencies
- Docker repository configuration
- Docker Engine installation
- Docker Compose plugin installation
- Docker service enablement and management
- Dedicated application user creation
- Application directory creation
- Ownership and permission configuration
- Twenty CRM source repository cloning
- Docker Compose configuration generation
- Multi-container application deployment
- Application readiness verification
- HTTP health checking

---

2. Tools and Technologies Used

Operating System

Ubuntu Linux

Infrastructure as Code

Ansible

Container Runtime

Docker Engine

Container Orchestration

Docker Compose

Core Application

Twenty CRM

Database

PostgreSQL 16

Caching and Queue Service

Redis 7 Alpine

Version Control

Git

Templating Engine

Jinja2

Execution Environment

KodeKloud Ubuntu Playground

---

3. Project Structure

The project files and directories are organized as follows:

```text
task-9/
├── group_vars/
│   └── all.yml
├── screenshots/
│   ├── all.yml.png
│   ├── all_files.png
│   ├── curl_success.png
│   ├── docker-compose.yml.2.png
│   ├── docker_compose_ps.png
│   ├── inventory-pong.png
│   └── site.yml.png
├── templates/
│   └── docker-compose.yml.j2
├── inventory
├── site.yml
└── Task-9.md
```

File and Directory Descriptions

group_vars/all.yml

Contains the centralized application, database, repository, and port configuration.

screenshots/

Contains screenshots showing the project structure, configuration files, playbook execution, container status, and application verification.

templates/docker-compose.yml.j2

Jinja2 template used to dynamically generate the Docker Compose configuration.

inventory

Defines the target host used by Ansible.

site.yml

Master Ansible playbook that performs the complete deployment workflow.

Task-9.md

Technical documentation containing the implementation details, commands, configuration, and validation results.

---

4. Task Requirements

The Ansible playbook performs the following operations:

1. Creates an inventory defining the target deployment host.
2. Updates the system package cache.
3. Installs the required system dependencies.
4. Configures the official Docker GPG key.
5. Adds the official Docker repository.
6. Installs Docker Engine and Docker Compose.
7. Ensures that the Docker service is enabled and running.
8. Creates a dedicated application user named twenty.
9. Adds the application user to the Docker group.
10. Creates the application directory structure under /opt/twenty.
11. Applies the required ownership and permissions.
12. Clones the Twenty CRM source repository.
13. Generates the Docker Compose file using a Jinja2 template.
14. Deploys the application using Docker Compose.
15. Waits for the application to become available.
16. Verifies application availability using an HTTP request.

---

5. Inventory Configuration

The inventory file specifies the target host used by Ansible.

A local connection is used because the playbook runs directly inside the Ubuntu KodeKloud playground.

File

```text
inventory
```

Configuration

```ini
[twenty]
localhost ansible_connection=local
```

Connectivity Verification

Run the following command:

```bash
ansible -i inventory twenty -m ping
```

Expected Output

```text
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

The pong response confirms that Ansible can successfully connect to the target host.

---

6. Application Configuration

All application parameters, repository details, port mappings, and database settings are managed centrally in the variables file.

File

```text
group_vars/all.yml
```

Configuration

```yaml
---
app_user: twenty

app_dir: /opt/twenty

repo_url: https://github.com/twentyhq/twenty.git
repo_version: main

app_port: 2020

postgres_db: twenty
postgres_user: twenty
postgres_password: twenty_password
postgres_port: 5432

redis_port: 6379

encryption_key: "task9-demo-encryption-key-change-this-32chars"
```

Configuration Details

Application user

```text
twenty
```

Application directory

```text
/opt/twenty
```

Source directory

```text
/opt/twenty/source
```

Repository

```text
https://github.com/twentyhq/twenty.git
```

Repository branch

```text
main
```

Host application port

```text
2020
```

Container application port

```text
3000
```

Application URL

```text
http://127.0.0.1:2020
```

PostgreSQL database name

```text
twenty
```

PostgreSQL database user

```text
twenty
```

PostgreSQL database password

```text
twenty_password
```

PostgreSQL port

```text
5432
```

Redis port

```text
6379
```

---

7. Ansible Playbook Specification

The site.yml playbook orchestrates the complete setup and deployment workflow.

File

```text
site.yml
```

Playbook

```yaml
---
- name: Automate Twenty CRM deployment
  hosts: twenty
  become: true
  gather_facts: true

  tasks:
    - name: Update apt package cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install required dependencies
      ansible.builtin.apt:
        name:
          - ca-certificates
          - curl
          - git
          - gnupg
          - lsb-release
          - python3
          - python3-pip
        state: present

    - name: Create Docker keyring directory
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: "0755"

    - name: Download Docker GPG key
      ansible.builtin.get_url:
        url: https://download.docker.com/linux/ubuntu/gpg
        dest: /etc/apt/keyrings/docker.asc
        mode: "0644"
        force: true

    - name: Add Docker repository
      ansible.builtin.apt_repository:
        repo: >-
          deb [arch={{ ansible_architecture | replace('x86_64', 'amd64') }}
          signed-by=/etc/apt/keyrings/docker.asc]
          https://download.docker.com/linux/ubuntu
          {{ ansible_distribution_release }} stable
        filename: docker
        state: present

    - name: Install Docker and Compose plugin
      ansible.builtin.apt:
        update_cache: true
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present

    - name: Ensure Docker service is enabled and running
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true

    - name: Create dedicated application user
      ansible.builtin.user:
        name: "{{ app_user }}"
        shell: /bin/bash
        create_home: true
        groups: docker
        append: true
        state: present

    - name: Create application directory
      ansible.builtin.file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: "0755"

    - name: Create source directory
      ansible.builtin.file:
        path: "{{ app_dir }}/source"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: "0755"

    - name: Clone Twenty CRM repository
      ansible.builtin.git:
        repo: "{{ repo_url }}"
        dest: "{{ app_dir }}/source"
        version: "{{ repo_version }}"
        update: true
        force: false
      become_user: "{{ app_user }}"

    - name: Create Docker Compose file
      ansible.builtin.template:
        src: docker-compose.yml.j2
        dest: "{{ app_dir }}/docker-compose.yml"
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: "0644"

    - name: Start Twenty CRM using Docker Compose
      ansible.builtin.command:
        cmd: docker compose up -d
        chdir: "{{ app_dir }}"
      register: compose_result
      changed_when: >
        'Started' in compose_result.stdout or
        'Created' in compose_result.stdout or
        'Recreated' in compose_result.stdout or
        'Pulling' in compose_result.stdout

    - name: Wait for Twenty CRM to become available
      ansible.builtin.uri:
        url: "http://127.0.0.1:{{ app_port }}"
        method: GET
        status_code:
          - 200
          - 301
          - 302
        return_content: false
      register: twenty_health
      retries: 12
      delay: 10
      until: twenty_health.status in [200, 301, 302]

    - name: Display Twenty CRM status
      ansible.builtin.debug:
        msg:
          - "Twenty CRM is running successfully."
          - "Application URL: http://127.0.0.1:{{ app_port }}"
          - "HTTP status: {{ twenty_health.status }}"
```

---

8. Docker Compose Services Configuration

The Docker Compose template defines the multi-container architecture for Twenty CRM.

The deployment contains the following services:

- Twenty CRM
- PostgreSQL
- Redis

File

```text
templates/docker-compose.yml.j2
```

Docker Compose Template

```yaml
services:
  postgres:
    image: postgres:16
    restart: unless-stopped

    environment:
      POSTGRES_USER: "{{ postgres_user }}"
      POSTGRES_PASSWORD: "{{ postgres_password }}"
      POSTGRES_DB: "{{ postgres_db }}"

    volumes:
      - postgres_data:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U {{ postgres_user }}"]
      interval: 10s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7-alpine
    restart: unless-stopped

    volumes:
      - redis_data:/data

  twenty:
    image: twentycrm/twenty:latest
    restart: unless-stopped

    ports:
      - "{{ app_port }}:3000"

    environment:
      NODE_PORT: 3000
      PORT: 3000

      SERVER_URL: "{{ app_url }}"
      FRONT_BASE_URL: "{{ app_url }}"

      PG_DATABASE_URL: "postgresql://{{ postgres_user }}:{{ postgres_password }}@postgres:5432/{{ postgres_db }}"

      REDIS_URL: "redis://redis:6379"

      ENABLE_DB_MIGRATIONS: "true"

      ENCRYPTION_KEY: "{{ encryption_key }}"
      APP_SECRET: "{{ encryption_key }}"

    depends_on:
      postgres:
        condition: service_healthy

      redis:
        condition: service_started

volumes:
  postgres_data:
  redis_data:
```

Twenty CRM Service

Image

```text
twentycrm/twenty:latest
```

Container port

```text
3000
```

Host port

```text
2020
```

Restart policy

```text
unless-stopped
```

Database dependency

The service starts after PostgreSQL becomes healthy.

Redis dependency

The service starts after Redis is started.

Database migrations

Automatic database migrations are enabled using:

```text
ENABLE_DB_MIGRATIONS=true
```

PostgreSQL Service

Image

```text
postgres:16
```

Database name

```text
twenty
```

Database user

```text
twenty
```

Port

```text
5432
```

Restart policy

```text
unless-stopped
```

Health check

The PostgreSQL service uses pg_isready to verify database readiness.

Persistent volume

```text
postgres_data
```

Redis Service

Image

```text
redis:7-alpine
```

Port

```text
6379
```

Restart policy

```text
unless-stopped
```

Persistent volume

```text
redis_data
```

---

9. Running the Ansible Playbook

Follow these steps to run the playbook on the Ubuntu host.

Step 1: Navigate to the project directory

```bash
cd ~/task9-ansible/task-9
```

Step 2: Run the syntax check

```bash
ansible-playbook -i inventory site.yml --syntax-check
```

Expected Output

```text
playbook: site.yml
```

Step 3: Execute the playbook

```bash
ansible-playbook -i inventory site.yml
```

Step 4: Verify the play recap

The playbook should complete with zero failed tasks and zero unreachable hosts.

```text
failed=0
unreachable=0
```

The successful play recap confirms that the deployment workflow completed correctly.

---

10. Container Verification

After the playbook execution completes, verify the running containers.

Command

```bash
docker ps
```

Expected Services

```text
twenty-twenty-1
twenty-postgres-1
twenty-redis-1
```

Expected Twenty CRM Port Mapping

```text
0.0.0.0:2020->3000/tcp
```

Expected PostgreSQL Status

```text
Up (healthy)
```

Actual Deployment Result

The deployed containers were:

```text
twenty-twenty-1
twenty-postgres-1
twenty-redis-1
```

The Twenty CRM application was running on host port 2020, PostgreSQL was healthy, and Redis was running successfully.

---

11. Application Verification

Verify that Twenty CRM is responding on host port 2020.

Command

```bash
curl -I http://127.0.0.1:2020
```

Expected Response

```text
HTTP/1.1 200 OK
```

Actual Response

```text
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
```

The HTTP 200 OK response confirms that the Twenty CRM application server is responding successfully.

---

12. Deployment Validation Summary

The following validations were completed successfully.

Ansible Syntax

The site.yml file passed the Ansible syntax check.

Playbook Execution

The playbook completed with:

```text
failed=0
unreachable=0
```

Docker Service

Docker was installed, enabled, and running.

Application User

The dedicated application user twenty was created and added to the Docker group.

Application Directory

The application directory was created at:

```text
/opt/twenty
```

Source Repository

The Twenty CRM repository was cloned into:

```text
/opt/twenty/source
```

PostgreSQL Container

The PostgreSQL container was running with healthy status.

Redis Container

The Redis container was running successfully.

Twenty CRM Container

The Twenty CRM container was running with the following port mapping:

```text
2020 -> 3000
```

Application Health

The application returned:

```text
HTTP/1.1 200 OK
```

---

13. Accessing Twenty CRM in KodeKloud

To access Twenty CRM through the KodeKloud environment:

1. Open the KodeKloud Ubuntu playground.
2. Open the Port Preview option.
3. Select port 2020.
4. Open the generated preview URL in a browser.

The application can also be verified directly from the terminal:

```bash
curl -I http://127.0.0.1:2020
```

Note on Gateway Rate Limiting

If the KodeKloud public preview displays:

```text
429 Too Many Requests
```

it indicates temporary rate limiting by the sandbox preview gateway.

The application itself can still be verified locally using:

```bash
curl -I http://127.0.0.1:2020
```

A response of:

```text
HTTP/1.1 200 OK
```

confirms that the application is running successfully.

---

14. Screenshots and Implementation Evidence

The screenshots directory contains visual evidence of the implementation and deployment.

all_files.png

Shows the complete Task 9 project directory structure and files.

all.yml.png

Shows the application variables configured in group_vars/all.yml.

inventory-pong.png

Shows the Ansible inventory connectivity check and successful pong response.

site.yml.png

Shows the Ansible playbook and deployment workflow.

docker-compose.yml.2.png

Shows the Docker Compose template used for the multi-container deployment.

docker_compose_ps.png

Shows the running Twenty CRM, PostgreSQL, and Redis containers.

curl_success.png

Shows the successful HTTP 200 OK response from Twenty CRM on port 2020.

---

15. Conclusion

Twenty CRM was successfully automated and deployed using Ansible on Ubuntu.

The playbook automated the complete deployment process by:

- Installing the required dependencies
- Configuring Docker
- Installing Docker Compose
- Creating a dedicated application user
- Creating the application directories
- Applying the required permissions
- Cloning the Twenty CRM repository
- Generating the Docker Compose configuration
- Deploying the application containers
- Verifying PostgreSQL health
- Verifying application availability

The deployment completed with zero failed tasks and zero unreachable hosts.

The Twenty CRM application was successfully exposed on port 2020, and the application endpoint returned:

```text
HTTP/1.1 200 OK
```

This confirms that the automated deployment was completed successfully.