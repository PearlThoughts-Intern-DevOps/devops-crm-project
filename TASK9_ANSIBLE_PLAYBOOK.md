# Task 9 — Ansible Playbook: Twenty CRM Deployment

## 1. Task Overview
This task automates the deployment of Twenty CRM using Ansible inside a Linux playground environment. The implementation was developed and tested in a KodeKloud Ubuntu Playground.

The playbook provisions dependencies, creates a dedicated application user, prepares directories, clones Twenty CRM, generates Docker Compose configuration from a Jinja2 template, starts the application, uses a handler for configuration changes, verifies health, and demonstrates idempotency.

## 2. Task Requirements
The assignment requires the Ansible implementation to:
- Create an inventory with the target host.
- Install required dependencies and Docker.
- Create a dedicated application user.
- Create required directories and set appropriate permissions.
- Clone the Twenty CRM repository.
- Configure the application using Ansible variables and Jinja2 templates.
- Start Twenty CRM using Docker Compose.
- Use an Ansible handler to restart the application when configuration changes.
- Verify that Twenty CRM is running successfully.
- Ensure the playbook is idempotent.

## 3. Playground Used
The implementation was tested in KodeKloud Linux Playground — Ubuntu.

```text
OS: Ubuntu 24.04.1 LTS
User: root
Hostname: ubuntu-host
Python: 3.12.3
Ansible Core: 2.16.3
Docker: 29.8.0
Docker Compose: 5.5.1
```

## 4. Why KodeKloud Was Selected
KodeKloud was selected because the assignment explicitly permits it and it provides a temporary Linux environment suitable for testing Ansible, Docker, and application deployment.

## 5. Initial Environment Verification
Commands used:

```bash
whoami
hostname
lsb_release -a
python3 --version
ansible --version
docker --version
docker compose version
```

## 6. Project Directory
A dedicated directory was created:

```bash
mkdir -p ~/twenty-ansible
cd ~/twenty-ansible
```

## 7. Final Project Structure
```text
twenty-ansible/
├── site.yml
├── inventory/
│   └── hosts.ini
├── templates/
│   └── docker-compose.yml.j2
└── group_vars/
    ├── twenty.yml
    └── vault.yml
```

## 8. Inventory Design
Because the KodeKloud playground is a single machine and the Ansible controller and target are the same host, a local Ansible connection was used.

## 9. Inventory File
File: `inventory/hosts.ini`

```ini
[twenty]
localhost ansible_connection=local
```

## 10. Inventory Explanation
The `[twenty]` group identifies the target host. `localhost` is the target machine and `ansible_connection=local` tells Ansible to execute the playbook locally instead of using SSH.

## 11. Testing Inventory
```bash
ansible -i inventory/hosts.ini twenty -m ping
```

Expected result:

```text
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## 12. Application Variables
Application configuration was separated from the playbook and stored in `group_vars/twenty.yml`.

## 13. Variables File
```yaml
---
app_user: twenty
app_group: twenty

app_dir: /opt/twenty
twenty_repo: https://github.com/twentyhq/twenty.git

twenty_port: 3001
twenty_tag: latest

postgres_db: twenty
postgres_user: twenty

redis_image: redis:7-alpine
postgres_image: postgres:16
```

## 14. Dedicated Application User
The playbook creates a dedicated Linux user named `twenty`, assigns it to the `twenty` group, and adds it to the Docker group.

## 15. Application Directory
The application directory is `/opt/twenty` with owner `twenty`, group `twenty`, and mode `0755`.

## 16. Required Dependencies
The playbook installs:

```text
ca-certificates
curl
git
```

## 17. Docker Detection
The KodeKloud environment already contained Docker CE, so the playbook checks Docker before attempting installation.

```yaml
- name: Check whether Docker is installed
  ansible.builtin.command:
    cmd: docker --version
  register: docker_check
  changed_when: false
  failed_when: false
```

## 18. Conditional Docker Installation
Docker is installed only when the Docker check fails.

```yaml
- name: Install Docker when it is missing
  ansible.builtin.apt:
    name:
      - docker.io
      - docker-compose-v2
    state: present
    update_cache: true
  when: docker_check.rc != 0
```

## 19. Docker Installation Issue
The first test attempted to install `docker.io` unconditionally and encountered a package conflict because the playground already had Docker CE/containerd.io. Conditional Docker detection resolved the issue.

## 20. Docker Service
```yaml
- name: Ensure Docker service is enabled and running
  ansible.builtin.service:
    name: docker
    state: started
    enabled: true
```

## 21. Application Group
```yaml
- name: Create application group
  ansible.builtin.group:
    name: "{{ app_group }}"
    state: present
```

## 22. Application User Creation
```yaml
- name: Create dedicated application user
  ansible.builtin.user:
    name: "{{ app_user }}"
    group: "{{ app_group }}"
    groups: docker
    append: true
    shell: /bin/bash
    create_home: true
    state: present
```

## 23. Application Directory Creation
```yaml
- name: Create application directory
  ansible.builtin.file:
    path: "{{ app_dir }}"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0755"
```

## 24. Repository
The Twenty CRM repository is:

```text
https://github.com/twentyhq/twenty.git
```

It is cloned into `/opt/twenty/twenty`.

## 25. Repository Clone Task
```yaml
- name: Clone Twenty CRM repository
  ansible.builtin.git:
    repo: "{{ twenty_repo }}"
    dest: "{{ app_dir }}/twenty"
    version: main
    update: false
  become_user: "{{ app_user }}"
```

## 26. Why Ansible Git Module Was Used
`ansible.builtin.git` manages repository state declaratively and supports idempotent automation better than a raw shell `git clone`.

## 27. Jinja2 Template
Docker Compose is generated from `templates/docker-compose.yml.j2`.

## 28. Docker Compose Services
The template contains:

```text
postgres
redis
twenty
```

## 29. PostgreSQL Service
```yaml
image: {{ postgres_image }}
container_name: twenty-postgres
restart: unless-stopped
```

## 30. PostgreSQL Environment
```yaml
environment:
  POSTGRES_DB: {{ postgres_db }}
  POSTGRES_USER: {{ postgres_user }}
  POSTGRES_PASSWORD: {{ postgres_password }}
```

The actual password is stored in Ansible Vault and is not included here.

## 31. PostgreSQL Health Check
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U {{ postgres_user }} -d {{ postgres_db }}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

## 32. Redis Service
```yaml
image: {{ redis_image }}
container_name: twenty-redis
restart: unless-stopped
volumes:
  - redis-data:/data
```

## 33. Twenty CRM Service
```yaml
image: twentycrm/twenty:{{ twenty_tag }}
container_name: twenty-crm
restart: unless-stopped
```

## 34. Application Port
The container listens on port `3000`; the host exposes it on `3001`:

```yaml
ports:
  - "{{ twenty_port }}:3000"
```

## 35. Port Conflict
Port `3000` was already occupied by another Twenty deployment in the playground, so `twenty_port` was changed to `3001` without disturbing the existing deployment.

## 36. PostgreSQL Connection
```yaml
PG_DATABASE_URL: postgresql://{{ postgres_user }}:{{ postgres_password }}@postgres:5432/{{ postgres_db }}
```

## 37. Redis Connection
```yaml
REDIS_URL: redis://redis:6379
```

## 38. Encryption Key
Twenty CRM requires an encryption key:

```yaml
ENCRYPTION_KEY: {{ twenty_encryption_key }}
```

The actual value is stored in Ansible Vault and is intentionally excluded.

## 39. Server URL
```yaml
SERVER_URL: http://localhost:{{ twenty_port }}
```

For this deployment, the resulting URL is `http://localhost:3001`.

## 40. Service Dependencies
```yaml
depends_on:
  postgres:
    condition: service_healthy
  redis:
    condition: service_started
```

## 41. Twenty Health Check
```yaml
healthcheck:
  test: ["CMD", "curl", "--fail", "http://localhost:3000/healthz"]
  interval: 10s
  timeout: 5s
  retries: 10
  start_period: 30s
```

## 42. Docker Volumes
```yaml
volumes:
  postgres-data:
  redis-data:
```

## 43. Complete Docker Compose Template
```yaml
services:
  postgres:
    image: {{ postgres_image }}
    container_name: twenty-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: {{ postgres_db }}
      POSTGRES_USER: {{ postgres_user }}
      POSTGRES_PASSWORD: {{ postgres_password }}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U {{ postgres_user }} -d {{ postgres_db }}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: {{ redis_image }}
    container_name: twenty-redis
    restart: unless-stopped
    volumes:
      - redis-data:/data

  twenty:
    image: twentycrm/twenty:{{ twenty_tag }}
    container_name: twenty-crm
    restart: unless-stopped
    ports:
      - "{{ twenty_port }}:3000"
    environment:
      PG_DATABASE_URL: postgresql://{{ postgres_user }}:{{ postgres_password }}@postgres:5432/{{ postgres_db }}
      REDIS_URL: redis://redis:6379
      ENCRYPTION_KEY: {{ twenty_encryption_key }}
      SERVER_URL: http://localhost:{{ twenty_port }}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:3000/healthz"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  postgres-data:
  redis-data:
```

## 44. Ansible Vault
Sensitive values are stored in the encrypted file `group_vars/vault.yml`.

It contains sensitive variables including:
- `postgres_password`
- `twenty_encryption_key`

Actual secret values are intentionally excluded.

## 45. Vault Security
Passwords, encryption keys, API keys, and other secrets must not be committed to GitHub in plaintext. The Vault password must also remain outside the repository.

## 46. Loading Vault Variables
The main playbook explicitly loads:

```yaml
vars_files:
  - group_vars/vault.yml
```

## 47. Main Playbook
The main playbook is `site.yml` and contains the complete deployment workflow.

## 48. Playbook Target
```yaml
hosts: twenty
become: true
gather_facts: true
```

## 49. Handler Requirement
The assignment requires a handler to restart the application when configuration changes.

## 50. Restart Handler
```yaml
- name: Restart Twenty CRM
  ansible.builtin.command:
    cmd: docker compose up -d
    chdir: "{{ app_dir }}"
  become_user: "{{ app_user }}"
```

## 51. Why a Handler Is Used
Handlers execute only when notified by a changed task. Therefore, an unchanged Compose template does not trigger an application restart, while a changed configuration does.

## 52. Template Deployment Task
```yaml
- name: Deploy Docker Compose configuration
  ansible.builtin.template:
    src: docker-compose.yml.j2
    dest: "{{ app_dir }}/docker-compose.yml"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0644"
  notify: Restart Twenty CRM
```

## 53. Handler Flush
```yaml
- name: Apply pending configuration changes
  ansible.builtin.meta: flush_handlers
```

## 54. Starting Twenty CRM
```yaml
- name: Start Twenty CRM with Docker Compose
  ansible.builtin.command:
    cmd: docker compose up -d
    chdir: "{{ app_dir }}"
  become_user: "{{ app_user }}"
```

## 55. Change Detection for Compose Start
The task registers the result and reports a change only when Compose starts, creates, or recreates services:

```yaml
register: compose_result
changed_when: "'Started' in compose_result.stdout or 'Created' in compose_result.stdout or 'Recreated' in compose_result.stdout"
```

## 56. Health Verification
```yaml
- name: Wait for Twenty CRM to become healthy
  ansible.builtin.uri:
    url: "http://127.0.0.1:{{ twenty_port }}/healthz"
    method: GET
    status_code: 200
  register: health_check
  retries: 30
  delay: 10
  until: health_check.status == 200
```

## 57. Health Check Retry Logic
The application can require time to initialize. The playbook retries the health endpoint up to 30 times with a 10-second delay.

## 58. Verification Message
```yaml
- name: Display Twenty CRM verification result
  ansible.builtin.debug:
    msg: "Twenty CRM is running successfully on port {{ twenty_port }}"
```

## 59. Complete Playbook
```yaml
---
- name: Deploy Twenty CRM with Ansible
  hosts: twenty
  become: true
  gather_facts: true

  vars_files:
    - group_vars/vault.yml

  handlers:
    - name: Restart Twenty CRM
      ansible.builtin.command:
        cmd: docker compose up -d
        chdir: "{{ app_dir }}"
      become_user: "{{ app_user }}"

  tasks:
    - name: Install required system dependencies
      ansible.builtin.apt:
        name:
          - ca-certificates
          - curl
          - git
        state: present
        update_cache: true

    - name: Check whether Docker is installed
      ansible.builtin.command:
        cmd: docker --version
      register: docker_check
      changed_when: false
      failed_when: false

    - name: Install Docker when it is missing
      ansible.builtin.apt:
        name:
          - docker.io
          - docker-compose-v2
        state: present
        update_cache: true
      when: docker_check.rc != 0

    - name: Ensure Docker service is enabled and running
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true

    - name: Create application group
      ansible.builtin.group:
        name: "{{ app_group }}"
        state: present

    - name: Create dedicated application user
      ansible.builtin.user:
        name: "{{ app_user }}"
        group: "{{ app_group }}"
        groups: docker
        append: true
        shell: /bin/bash
        create_home: true
        state: present

    - name: Create application directory
      ansible.builtin.file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: "0755"

    - name: Clone Twenty CRM repository
      ansible.builtin.git:
        repo: "{{ twenty_repo }}"
        dest: "{{ app_dir }}/twenty"
        version: main
        update: false
      become_user: "{{ app_user }}"

    - name: Deploy Docker Compose configuration
      ansible.builtin.template:
        src: docker-compose.yml.j2
        dest: "{{ app_dir }}/docker-compose.yml"
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: "0644"
      notify: Restart Twenty CRM

    - name: Apply pending configuration changes
      ansible.builtin.meta: flush_handlers

    - name: Start Twenty CRM with Docker Compose
      ansible.builtin.command:
        cmd: docker compose up -d
        chdir: "{{ app_dir }}"
      become_user: "{{ app_user }}"
      register: compose_result
      changed_when: "'Started' in compose_result.stdout or 'Created' in compose_result.stdout or 'Recreated' in compose_result.stdout"

    - name: Wait for Twenty CRM to become healthy
      ansible.builtin.uri:
        url: "http://127.0.0.1:{{ twenty_port }}/healthz"
        method: GET
        status_code: 200
      register: health_check
      retries: 30
      delay: 10
      until: health_check.status == 200

    - name: Display Twenty CRM verification result
      ansible.builtin.debug:
        msg: "Twenty CRM is running successfully on port {{ twenty_port }}"
```

## 60. First Playbook Test
The playbook was tested with:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --ask-vault-pass
```

The initial run exposed environment-specific issues that were subsequently corrected.

## 61. Docker Installation Issue
The first issue was the Docker package conflict caused by attempting to install `docker.io` on a machine that already had Docker CE. Docker detection and conditional installation resolved it.

## 62. Port 3000 Issue
Another Twenty deployment already occupied port `3000`. The deployment was therefore configured to use port `3001`.

## 63. Missing Encryption Key Issue
The first Twenty container attempt failed because `ENCRYPTION_KEY` was not configured. This was fixed by storing the key in Ansible Vault and referencing it from the Jinja2 template.

## 64. Secret Handling Correction
During troubleshooting, generated secret material was accidentally exposed during terminal experimentation. The exposed values were treated as compromised and were not reused. A new secret was generated and stored only in encrypted Ansible Vault. No secret values are included in this document.

## 65. Vault Verification
The encrypted Vault file was successfully used by the playbook. An attempt to use `ansible-vault view` encountered a missing `less` utility, which was only a viewer issue and did not prevent Ansible from loading the Vault.

## 66. Successful Deployment
After correcting Docker detection, the port conflict, and secret configuration, the playbook completed successfully:

```text
PLAY RECAP
localhost : ok=13 changed=2 unreachable=0 failed=0 skipped=1
```

## 67. Successful Handler Execution
The successful deployment showed:

```text
TASK [Deploy Docker Compose configuration] changed
TASK [Apply pending configuration changes]
RUNNING HANDLER [Restart Twenty CRM] changed
```

This demonstrates that the required handler mechanism works.

## 68. Successful Health Verification
The playbook successfully waited for the application:

```text
TASK [Wait for Twenty CRM to become healthy] ... ok
```

Final message:

```text
Twenty CRM is running successfully on port 3001
```

## 69. Idempotency Test
The playbook was executed a second time without configuration changes:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --ask-vault-pass
```

The second run showed the Compose configuration unchanged and the application already running.

## 70. Idempotency Result
The second run completed with:

```text
PLAY RECAP
localhost : ok=12 changed=0 unreachable=0 failed=0 skipped=1
```

The important result is:

```text
changed=0
failed=0
```

This demonstrates idempotency for the tested deployment state.

## 71. Docker Compose Verification
The runtime was checked with:

```bash
docker compose -f /opt/twenty/docker-compose.yml ps
```

The Ansible-managed Twenty container was shown as `twenty-crm` with:

```text
0.0.0.0:3001->3000/tcp
```

## 72. Container Health
The Twenty CRM container reported:

```text
Up ... (healthy)
```

PostgreSQL also reported a healthy status and Redis was running successfully.

## 73. Direct Health Endpoint Test
```bash
curl -I http://127.0.0.1:3001/healthz
```

Result:

```text
HTTP/1.1 200 OK
```

## 74. Runtime Container Summary
The verified Ansible-managed services were:

```text
twenty-crm
twenty-postgres
twenty-redis
```

Pre-existing Twenty services on port `3000` were left untouched.

## 75. Repository Implementation
For submission, the implementation was placed under:

```text
ansible/
├── site.yml
├── inventory/
│   └── hosts.ini
├── templates/
│   └── docker-compose.yml.j2
└── group_vars/
    ├── twenty.yml
    └── vault.yml
```

## 76. Git Branch
The Task 9 work was performed on:

```text
netaji-task9
```

## 77. Submission Requirements
The final submission should contain:
- Ansible implementation.
- Inventory.
- Jinja2 Docker Compose template.
- Variables.
- Encrypted Vault file if permitted by repository policy.
- Task 9 documentation.
- Relevant screenshots.
- Pull request from the Task 9 branch.
- Loom walkthrough explaining the implementation and learning.

## 78. Final Checklist
| Requirement | Status |
|---|---|
| Ansible inventory | Completed |
| Target host configured | Completed |
| Required dependencies | Completed |
| Docker availability | Completed |
| Dedicated application user | Completed |
| Application directory | Completed |
| Permissions | Completed |
| Twenty CRM repository clone | Completed |
| Ansible variables | Completed |
| Jinja2 template | Completed |
| Docker Compose deployment | Completed |
| Ansible handler | Completed |
| Configuration-triggered restart | Completed |
| Health verification | Completed |
| Idempotency test | Completed |
| KodeKloud playground testing | Completed |
| Documentation | Completed |
| Git branch | Completed |
| PR preparation | Completed |
| Loom preparation | Completed |

## 79. Conclusion
The Twenty CRM deployment was successfully automated using Ansible and tested inside a KodeKloud Ubuntu playground.

The final implementation demonstrates inventory-based deployment, dependency management, Docker availability checks, dedicated user creation, directory and permission management, repository management through Ansible Git, variable-driven configuration, Jinja2 templating, Ansible Vault, Docker Compose deployment, handler-based configuration application, health-check verification, and idempotent execution.

The final deployment exposed Twenty CRM on port `3001`, returned `HTTP/1.1 200 OK` from `/healthz`, and the second playbook execution completed with `changed=0` and `failed=0`.

**Security note:** No actual passwords, encryption keys, API keys, or other secret values are included in this documentation.
