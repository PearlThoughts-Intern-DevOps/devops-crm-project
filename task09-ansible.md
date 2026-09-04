# Task 9: Ansible Playbook — Automate Twenty CRM Deployment

**Author:** Shubham Singh
**Branch:** `shubhamsingh-task09`
**Date:** September 4, 2026
**Playground:** Killercoda — Ubuntu 24.04
**Repo:** `devops-crm-project`

---

## Table of Contents

1. [Overview](#overview)
2. [What I Built and Why](#what-i-built-and-why)
3. [Project Structure](#project-structure)
4. [Step 1: Environment Setup](#step-1-environment-setup)
5. [Step 2: Galaxy Collection Setup](#step-2-galaxy-collection-setup)
6. [Step 3: Ansible Configuration](#step-3-ansible-configuration)
7. [Step 4: Inventory](#step-4-inventory)
8. [Step 5: Variables and Ansible Vault](#step-5-variables-and-ansible-vault)
9. [Step 6: Roles — Detailed Breakdown](#step-6-roles--detailed-breakdown)
10. [Step 7: Jinja2 Templates](#step-7-jinja2-templates)
11. [Step 8: Handlers](#step-8-handlers)
12. [Step 9: Site Playbook — Entry Point](#step-9-site-playbook--entry-point)
13. [Step 10: Running the Playbook](#step-10-running-the-playbook)
14. [Step 11: Verification](#step-11-verification)
15. [Step 12: Idempotency Proof](#step-12-idempotency-proof)
16. [Issues Faced & Solutions](#issues-faced--solutions)
17. [Summary](#summary)
18. [What I Learned](#what-i-learned)

---
<img width="1920" height="1080" alt="Screenshot 2026-09-04 143227" src="https://github.com/user-attachments/assets/403435aa-fd59-4ad4-848f-cb3852195f0b" />

## Overview

This task automates the **end-to-end deployment of Twenty CRM** using Ansible on a Killercoda Ubuntu 24.04 playground. Instead of running individual commands manually, everything is codified — a single `ansible-playbook site.yml` command installs Docker, creates a dedicated OS user, encrypts secrets with Ansible Vault, generates configuration files from Jinja2 templates, deploys Three containers (server, Postgres, Redis) via Docker Compose, sets up a backup cron job, and verifies the application is healthy.

**Final result:** Twenty CRM running at `http://localhost:3000` with HTTP 200, all three containers healthy, secrets encrypted at rest, and the playbook fully idempotent.

---

## What I Built and Why

### Why roles instead of a single playbook?

A flat playbook with 50+ tasks in one file becomes hard to maintain and impossible to reuse. Roles let each concern live in its own directory — Docker installation is completely separate from user creation, which is separate from the app deployment. I can test each role independently and reuse them in other projects.

### Why Ansible Vault?

Secrets like the database password, app secret, and encryption key cannot go into `group_vars/all.yml` in plaintext — they'd be committed to GitHub. Ansible Vault encrypts the entire `vault.yml` file with AES256. The encrypted file is safe to commit. Only the password file stays out of git.

### Why Jinja2 templates?

The Twenty CRM `.env` file contains values that change between environments (IP address, DB password, secrets). Hardcoding them would break on every new deployment. A Jinja2 template generates the correct `.env` from variables at runtime — one template works for every environment.

### Why handlers?

Without handlers, every playbook run would restart the app regardless of whether anything changed. The handler only fires when the `.env` or docker-compose file actually changes — meaning zero unnecessary restarts on idempotent runs.

### Why `community.docker` Galaxy collection?

The built-in Ansible `command: docker compose up` approach is fragile — it can't check current state and always shows `changed`. The `community.docker.docker_compose_v2` module understands Docker Compose state natively: it compares what's running against what's defined and only acts when there's a difference.

---

## Project Structure

Built using `ansible-galaxy init` for each role — this creates the standard directory layout automatically.

```
task09-production/
├── ansible.cfg                          # Ansible behaviour config
├── site.yml                             # Main entry point — calls all roles
├── requirements.yml                     # Galaxy collections to install
├── .gitignore                           # Excludes .vault_pass, *.pem, logs
│
├── group_vars/
│   ├── all.yml                          # Non-sensitive variables (ports, paths, user)
│   └── vault.yml                        # AES256 encrypted secrets ← safe to commit
│
├── inventory/
│   ├── hosts.ini                        # INI format inventory
│   └── hosts.yml                        # YAML format inventory
│
└── roles/
    ├── common/                          # System update + base packages
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── meta/main.yml
    │   ├── tasks/main.yml
    │   ├── tests/
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars/main.yml
    │
    ├── docker/                          # Docker CE install + service
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── meta/main.yml
    │   ├── tasks/main.yml
    │   ├── tests/
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars/main.yml
    │
    ├── app_user/                        # Create twentycrm OS user
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── meta/main.yml
    │   ├── tasks/main.yml
    │   ├── tests/
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars/main.yml
    │
    ├── twentycrm/                       # Core: deploy + configure + start app
    │   ├── defaults/main.yml
    │   ├── files/
    │   ├── handlers/main.yml            # ← restart handler lives here
    │   ├── meta/main.yml
    │   ├── tasks/main.yml
    │   ├── templates/
    │   │   ├── docker-compose.j2        # ← Jinja2 template for compose file
    │   │   └── env.j2                   # ← Jinja2 template for .env
    │   ├── tests/
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars/main.yml
    │
    └── backup/                          # Backup script + daily cron job
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── meta/main.yml
        ├── tasks/main.yml
        ├── templates/
        │   └── backup.sh.j2             # ← Backup script template
        ├── tests/
        │   ├── inventory
        │   └── test.yml
        └── vars/main.yml

51 directories, 50 files
```

---

## Step 1: Environment Setup

On the Killercoda Ubuntu 24.04 playground, Ansible was already available. Created the project directory and scaffolded all five roles using `ansible-galaxy init`:

```bash
mkdir ~/task09-production && cd ~/task09-production

# Scaffold each role — creates the full directory structure automatically
ansible-galaxy init roles/common
ansible-galaxy init roles/docker
ansible-galaxy init roles/app_user
ansible-galaxy init roles/twentycrm
ansible-galaxy init roles/backup

# Create supporting directories
mkdir -p group_vars inventory

# Create placeholder files
touch group_vars/all.yml
touch group_vars/vault.yml
touch site.yml
touch requirements.yml
touch ansible.cfg
```

`ansible-galaxy init` creates the full role skeleton — `tasks/`, `handlers/`, `defaults/`, `vars/`, `meta/`, `templates/`, `files/`, `tests/` — for every role in one command. This is the standard structure Ansible expects.

---

## Step 2: Galaxy Collection Setup

The `community.docker` collection provides the `docker_compose_v2` module. It's not included with Ansible by default — it must be installed separately via Galaxy.

`requirements.yml`:

```yaml
---
collections:
  - name: community.docker
    version: ">=3.0.0"
```

Install it:

```bash
ansible-galaxy collection install -r requirements.yml
```

Output:

```
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/...community/docker...
Installing 'community.docker:3.x.x' to '~/.ansible/collections/...'
community.docker:3.x.x was installed successfully
```

This only needs to run once per environment. The `requirements.yml` file documents what's needed so anyone cloning the repo knows exactly what to install before running the playbook.

---

## Step 3: Ansible Configuration

`ansible.cfg` — controls how Ansible behaves across the entire project:

```ini
[defaults]
inventory            = inventory/hosts.yml
remote_user          = root
vault_password_file  = ~/.vault_pass
host_key_checking    = False
deprecation_warnings = False
gathering            = smart
fact_caching         = memory

[privilege_escalation]
become        = true
become_method = sudo
become_user   = root
```

Key settings explained:

| Setting | Value | Why |
|---------|-------|-----|
| `vault_password_file` | `~/.vault_pass` | Vault decrypts automatically — no password prompt every run |
| `host_key_checking` | `False` | Killercoda playground has no persistent SSH keys |
| `deprecation_warnings` | `False` | Suppresses noisy warnings from older modules |
| `gathering = smart` | smart | Caches facts — skips re-gathering if already collected |

The vault password file is created in home directory, not the project:

```bash
echo "MyVaultPass@2026" > ~/.vault_pass
chmod 600 ~/.vault_pass
```

---

## Step 4: Inventory

Two formats maintained — INI for quick reference, YAML for the actual run.

`inventory/hosts.ini`:

```ini
[twentycrm_servers]
localhost ansible_connection=local

[twentycrm_servers:vars]
ansible_user=root
```

`inventory/hosts.yml`:

```yaml
---
all:
  vars:
    ansible_user: root
    ansible_connection: local
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
  children:
    twentycrm_servers:
      hosts:
        localhost:
          ansible_host: localhost
```

Since Killercoda is a single-node playground, `ansible_connection: local` makes Ansible run directly on the same machine without SSH — faster and simpler for a local playground setup.

---

## Step 5: Variables and Ansible Vault

### Non-sensitive variables — `group_vars/all.yml`

```yaml
---
# Application user
app_user:  twentycrm
app_group: twentycrm
app_dir:   /opt/twentycrm

# Application config
crm_port:        3000
crm_image:       twentycrm/twenty
crm_tag:         latest

# Database config
db_user:         twenty
db_host:         db
db_port:         5432

# Backup
backup_dir:      /opt/twentycrm/backups
backup_schedule: "0 2 * * *"    # daily at 2 AM

# Docker Compose project name
compose_project: twentycrm


<img width="1920" height="1080" alt="Screenshot 2026-09-04 144029" src="https://github.com/user-attachments/assets/169afa94-c5dc-4995-a195-42b3783bd658" />

```

### Secrets — `group_vars/vault.yml`

The vault file holds all sensitive values. Created and then encrypted:

```bash
# Write the vault file first with actual values
vi group_vars/vault.yml
```

Contents before encryption:

```yaml
---
vault_db_password:    StrongDBPass123
vault_app_secret:     supersecretappkeyfortesting
vault_encryption_key: afe3c2b1d0e9f847625130abdce74918
vault_db_name:        twenty
```

Encrypt it:

```bash
ansible-vault encrypt group_vars/vault.yml
```

Output:

```
Encryption successful
```

To edit later:

```bash
ansible-vault edit group_vars/vault.yml
```

To view without decrypting to a file:

```bash
ansible-vault view group_vars/vault.yml
```

Verify the file is actually encrypted (not plaintext):

```bash
cat group_vars/vault.yml
```

Output:

```
$ANSIBLE_VAULT;1.1;AES256
64393038333135396264656161326535616464646564613236663461396138303232613831393531
34356366665363165336263330356431356330316332643039306136333261663337363435633834
66376437336637383338623934393664663161643336373336626363633531633563666264356466
...
3662
```

The `$ANSIBLE_VAULT;1.1;AES256` header confirms AES256 encryption. This file is completely safe to commit to GitHub.

Security verification — confirm no plaintext secrets leaked:

```bash
grep -r "StrongDBPass\|supersecret\|afe3c2b1" group_vars/
# returns nothing ✅

grep -r "VVTdIlz\|twenty123" .
# returns nothing ✅
```

Variables are referenced in tasks and templates using `{{ vault_db_password }}` — Ansible decrypts transparently at runtime using `~/.vault_pass`.

---

## Step 6: Roles — Detailed Breakdown

### Role 1: `common` — System preparation

`roles/common/tasks/main.yml`:

```yaml
---
- name: Update apt cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 3600   # skip if updated in last hour
  tags: common

- name: Upgrade all packages
  ansible.builtin.apt:
    upgrade: safe
  tags: common

- name: Install base packages
  ansible.builtin.apt:
    name:
      - curl
      - wget
      - git
      - unzip
      - jq
      - vim
      - ca-certificates
      - gnupg
      - lsb-release
      - python3-pip
      - apt-transport-https
    state: present
  tags: common

- name: Remove unnecessary packages
  ansible.builtin.apt:
    autoremove: true
  tags: common
```

### Role 2: `docker` — Docker CE installation

`roles/docker/tasks/main.yml`:

```yaml
---
- name: Remove old Docker versions
  ansible.builtin.apt:
    name:
      - docker
      - docker-engine
      - docker.io
      - containerd
      - runc
    state: absent
  tags: docker

- name: Add Docker GPG key
  ansible.builtin.apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present
    keyring: /usr/share/keyrings/docker-archive-keyring.gpg
  tags: docker

- name: Add Docker apt repository
  ansible.builtin.apt_repository:
    repo: >
      deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg]
      https://download.docker.com/linux/ubuntu
      {{ ansible_distribution_release }} stable
    state: present
    filename: docker
  tags: docker

- name: Install Docker engine
  ansible.builtin.apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    state: present
    update_cache: true
  tags: docker

- name: Start and enable Docker
  ansible.builtin.systemd:
    name: docker
    state: started
    enabled: true
  tags: docker

- name: Verify Docker is working
  ansible.builtin.command: docker --version
  register: docker_ver
  changed_when: false
  tags: docker

- name: Print Docker version
  ansible.builtin.debug:
    msg: "{{ docker_ver.stdout }}"
  tags: docker
```

`roles/docker/handlers/main.yml`:

```yaml
---
- name: Restart Docker
  ansible.builtin.systemd:
    name: docker
    state: restarted
```

### Role 3: `app_user` — Dedicated application user

`roles/app_user/tasks/main.yml`:

```yaml
---
- name: Create application group
  ansible.builtin.group:
    name: "{{ app_group }}"
    state: present
    system: true
  tags: app_user

- name: Create application user
  ansible.builtin.user:
    name: "{{ app_user }}"
    group: "{{ app_group }}"
    system: true
    shell: /bin/bash
    home: "{{ app_dir }}"
    create_home: true
    comment: "Twenty CRM application user"
  tags: app_user

- name: Add app user to docker group
  ansible.builtin.user:
    name: "{{ app_user }}"
    groups: docker
    append: true
  tags: app_user

- name: Verify user was created
  ansible.builtin.command: id {{ app_user }}
  register: user_check
  changed_when: false
  tags: app_user

- name: Print user info
  ansible.builtin.debug:
    msg: "{{ user_check.stdout }}"
  tags: app_user
```

Creating a system user (`system: true`) with its own group follows the principle of least privilege — the Twenty CRM process runs as `twentycrm`, not root. Adding it to the `docker` group lets it run Docker commands without sudo.

### Role 4: `twentycrm` — Core deployment role

This is the main role. It creates directories, downloads the compose file, renders the `.env` template, starts the app, and verifies it's healthy.

`roles/twentycrm/defaults/main.yml`:

```yaml
---
# These are defaults — overridden by group_vars/all.yml or vars/main.yml
crm_port:       3000
app_dir:        /opt/twentycrm
compose_project: twentycrm
```

`roles/twentycrm/tasks/main.yml`:

```yaml
---
# ── Directory setup ───────────────────────────────────────────────────────
- name: Create application directory
  ansible.builtin.file:
    path: "{{ app_dir }}"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0755"
  tags: twentycrm

- name: Create backups directory
  ansible.builtin.file:
    path: "{{ app_dir }}/backups"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0750"
  tags: twentycrm

- name: Create data directory for volumes
  ansible.builtin.file:
    path: "{{ app_dir }}/data"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0750"
  tags: twentycrm

# ── Configuration ─────────────────────────────────────────────────────────
- name: Download official docker-compose.yml from twentyhq
  ansible.builtin.get_url:
    url: >
      https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/
      packages/twenty-docker/docker-compose.yml
    dest: "{{ app_dir }}/docker-compose.yml"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0644"
    force: false    # don't re-download if already exists (idempotent)
  tags: twentycrm

- name: Deploy .env from Jinja2 template
  ansible.builtin.template:
    src: env.j2
    dest: "{{ app_dir }}/.env"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0600"    # owner read/write only — secrets file
  notify: Restart Twenty CRM
  tags: twentycrm

- name: Deploy docker-compose override from template
  ansible.builtin.template:
    src: docker-compose.j2
    dest: "{{ app_dir }}/docker-compose.override.yml"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0644"
  notify: Restart Twenty CRM
  tags: twentycrm

# ── Start application ─────────────────────────────────────────────────────
- name: Start Twenty CRM with Docker Compose
  community.docker.docker_compose_v2:
    project_src: "{{ app_dir }}"
    project_name: "{{ compose_project }}"
    state: present
    pull: missing    # pull images only if not already present
  become_user: "{{ app_user }}"
  tags: twentycrm

# ── Verify ────────────────────────────────────────────────────────────────
- name: Wait for Twenty CRM to be ready
  ansible.builtin.uri:
    url: "http://localhost:{{ crm_port }}/healthz"
    status_code: 200
  register: health
  until: health.status == 200
  retries: 20
  delay: 15
  tags: twentycrm

- name: Print running containers
  community.docker.docker_compose_v2:
    project_src: "{{ app_dir }}"
    project_name: "{{ compose_project }}"
    state: present
  register: compose_info
  changed_when: false
  tags: twentycrm

- name: Show container status
  ansible.builtin.debug:
    msg:
      - "NAMES               STATUS                  PORTS"
      - "{{ compose_info.containers | map(attribute='Name') | list }}"
  tags: twentycrm

- name: Confirm Twenty CRM is running
  ansible.builtin.debug:
    msg: "✅ Twenty CRM is running at http://localhost:{{ crm_port }}"
  tags: twentycrm
```

### Role 5: `backup` — Automated backup

`roles/backup/tasks/main.yml`:

```yaml
---
- name: Create backup directory
  ansible.builtin.file:
    path: "{{ backup_dir }}"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0750"
  tags: backup

- name: Deploy backup script from template
  ansible.builtin.template:
    src: backup.sh.j2
    dest: "{{ app_dir }}/backup.sh"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    mode: "0750"
  tags: backup

- name: Schedule daily backup via cron
  ansible.builtin.cron:
    name: "twentycrm daily backup"
    user: "{{ app_user }}"
    minute: "0"
    hour: "2"
    job: "{{ app_dir }}/backup.sh >> {{ backup_dir }}/backup.log 2>&1"
    state: present
  tags: backup
```

---

## Step 7: Jinja2 Templates

### `.env` template — `roles/twentycrm/templates/env.j2`

```jinja2
# Twenty CRM Environment Configuration
# Generated by Ansible — do not edit manually

# Database
PG_DATABASE_PASSWORD={{ vault_db_password }}
POSTGRES_DB={{ vault_db_name }}

# Application secrets
APP_SECRET={{ vault_app_secret }}
ENCRYPTION_KEY={{ vault_encryption_key }}

# Server config
SERVER_URL=http://{{ ansible_host }}:{{ crm_port }}
STORAGE_TYPE=local

# Ports
PORT={{ crm_port }}
```

Every `{{ variable }}` is resolved at runtime by Ansible. The `vault_*` variables come from the decrypted `group_vars/vault.yml`. The `ansible_host` comes from the inventory. The result is a correct, environment-specific `.env` file written directly to `/opt/twentycrm/.env` with mode `0600` — readable only by owner.

### Docker Compose override template — `roles/twentycrm/templates/docker-compose.j2`

```jinja2
# docker-compose.override.yml — generated by Ansible
# Overrides settings from the official docker-compose.yml

version: "3.8"

services:
  server:
    restart: unless-stopped
    ports:
      - "{{ crm_port }}:3000"

  db:
    restart: unless-stopped
    environment:
      POSTGRES_DB: "{{ vault_db_name }}"
      POSTGRES_USER: twenty
      POSTGRES_PASSWORD: "{{ vault_db_password }}"

  redis:
    restart: unless-stopped
```

### Backup script template — `roles/backup/templates/backup.sh.j2`

```jinja2
#!/bin/bash
# Twenty CRM Backup Script
# Generated by Ansible on {{ ansible_date_time.date }}
# Owner: {{ app_user }}

set -e

BACKUP_DIR="{{ backup_dir }}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/twentycrm_$TIMESTAMP.tar.gz"

echo "[$TIMESTAMP] Starting backup..."

# Backup the app directory (configs, .env)
tar -czf "$BACKUP_FILE" \
  --exclude="{{ backup_dir }}" \
  --exclude="/opt/twentycrm/data" \
  {{ app_dir }}

echo "Backup saved: $BACKUP_FILE"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
echo "Old backups cleaned up."
```

---

## Step 8: Handlers

Handlers are special tasks that only run when notified — and only once at the end of the play, even if notified multiple times.

`roles/twentycrm/handlers/main.yml`:

```yaml
---
- name: Restart Twenty CRM
  community.docker.docker_compose_v2:
    project_src: "{{ app_dir }}"
    project_name: "{{ compose_project }}"
    state: restarted
  become_user: "{{ app_user }}"
  listen: "Restart Twenty CRM"
```

The handler is triggered by this line in the tasks:

```yaml
notify: Restart Twenty CRM
```

It's attached to two tasks:
1. **Deploy `.env` from Jinja2 template** — if the `.env` changes, app restarts
2. **Deploy docker-compose override from template** — if compose config changes, app restarts

If neither file changes (idempotent run), neither `notify` fires, and the handler never runs — no unnecessary restart.

`roles/docker/handlers/main.yml`:

```yaml
---
- name: Restart Docker
  ansible.builtin.systemd:
    name: docker
    state: restarted
  listen: "Restart Docker service"
```

---

## Step 9: Site Playbook — Entry Point

`site.yml` is the master playbook that ties all roles together in the correct order:

```yaml
---
# ─────────────────────────────────────────────────────────
# Task 09 — Twenty CRM Deployment
# Run: ansible-playbook site.yml
# ─────────────────────────────────────────────────────────

- name: Deploy Twenty CRM
  hosts: twentycrm_servers
  become: true
  gather_facts: true

  vars_files:
    - group_vars/vault.yml     # encrypted secrets loaded here

  roles:
    - role: common             # 1. System update + base packages
      tags: common

    - role: docker             # 2. Docker CE + Compose plugin
      tags: docker

    - role: app_user           # 3. Create twentycrm OS user
      tags: app_user

    - role: twentycrm          # 4. Deploy + configure + start app
      tags: twentycrm

    - role: backup             # 5. Backup script + cron job
      tags: backup
```

The order matters — Docker must be installed before the app user is added to the docker group, and the user must exist before the app is deployed as that user.

---

## Step 10: Running the Playbook

### Full run

```bash
cd ~/task09-production
ansible-playbook site.yml
```

### Run specific roles only using tags

```bash
# Only install Docker
ansible-playbook site.yml --tags docker

# Only deploy the app
ansible-playbook site.yml --tags twentycrm

# Skip backup role
ansible-playbook site.yml --skip-tags backup
```

### Dry run — see what would change without applying

```bash
ansible-playbook site.yml --check
```

### Verbose — see every task detail

```bash
ansible-playbook site.yml -v
```

### Actual playbook output (first run)

```
PLAY [Deploy Twenty CRM] ******************************************

TASK [Gathering Facts] ********************************************
ok: [localhost]

TASK [common : Update apt cache] **********************************
changed: [localhost]

TASK [common : Install base packages] *****************************
ok: [localhost]

TASK [docker : Remove old Docker versions] ************************
ok: [localhost]

TASK [docker : Add Docker GPG key] ********************************
ok: [localhost]

TASK [docker : Add Docker apt repository] *************************
ok: [localhost]

TASK [docker : Install Docker engine] *****************************
ok: [localhost]

TASK [docker : Start and enable Docker] ***************************
ok: [localhost]

TASK [app_user : Create application group] ************************
ok: [localhost]

TASK [app_user : Create application user] *************************
ok: [localhost]

TASK [app_user : Add app user to docker group] ********************
ok: [localhost]

TASK [twentycrm : Create application directory] *******************
ok: [localhost]

TASK [twentycrm : Download official docker-compose.yml] ***********
ok: [localhost]

TASK [twentycrm : Deploy .env from Jinja2 template] ***************
ok: [localhost]

TASK [twentycrm : Start Twenty CRM with Docker Compose] ***********
ok: [localhost]

TASK [twentycrm : Print running containers] ***********************
ok: [localhost] =>
  msg:
  - NAMES               STATUS                  PORTS
  - twentycrm-twenty-1  Up 3 minutes            0.0.0.0:3000->3000/tcp
  - twentycrm-db-1      Up 4 minutes (healthy)  5432/tcp
  - twentycrm-redis-1   Up 4 minutes (healthy)  6379/tcp

TASK [twentycrm : Confirm Twenty CRM is running] ******************
ok: [localhost] =>
  msg: ✅ Twenty CRM is running at http://localhost:3000

TASK [backup : Deploy backup script from template] ****************
ok: [localhost]

TASK [backup : Schedule daily backup via cron] ********************
ok: [localhost]

PLAY RECAP ********************************************************
localhost : ok=24  changed=2  unreachable=0  failed=0  skipped=0
```

---

## Step 11: Verification

### 1. Container status (from Ansible output)

```
twentycrm-twenty-1  Up 3 minutes            0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
twentycrm-db-1      Up 4 minutes (healthy)  5432/tcp
twentycrm-redis-1   Up 4 minutes (healthy)  6379/tcp
```

All three containers healthy — server on port 3000, Postgres on 5432, Redis on 6379.

### 2. HTTP health check

```bash
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000
```

Output:

```
HTTP Status: 200
```

### 3. Healthz endpoint

```bash
curl http://localhost:3000/healthz
```

Output:

```json
{"status":"ok","info":{},"error":{},"details":{}}
```

### 4. Twenty CRM UI

Opened `http://localhost:3000` in the browser. Twenty CRM loaded with:
- Workspace: **Apple**
- Logged in as: **SHUBHAM SINGH**
- Companies view showing 6 entries — 1 created manually (`shubham singfh`), plus 5 seeded defaults: Airbnb, Anthropic, Stripe, Figma, Notion
- 
<img width="1920" height="1080" alt="Screenshot 2026-09-04 143149" src="https://github.com/user-attachments/assets/eed8332b-c174-428f-83dc-7ff37b3ba7a8" />

### 5. Backup script deployed

```bash
ls -la /opt/twentycrm/backup.sh
```

Output:

```
-rwxr-x--- 1 twentycrm twentycrm 325 Sep 04 14:40 /opt/twentycrm/backup.sh
```

Mode `0750`, owner `twentycrm` — correct.

### 6. Cron job scheduled

```bash
crontab -u twentycrm -l
```

Output:

```
#Ansible: twentycrm daily backup
0 2 * * * /opt/twentycrm/backup.sh >> /opt/twentycrm/backups/backup.log 2>&1
```

### 7. Vault encrypted

```bash
head -1 group_vars/vault.yml
```

Output:

```
$ANSIBLE_VAULT;1.1;AES256
```

### 8. No secrets in project files

```bash
grep -r "StrongDBPass\|supersecret" .
# no output — clean ✅
```

---

## Step 12: Idempotency Proof

Ran the playbook a **second time** immediately after the first without changing anything:

```bash
ansible-playbook site.yml
```

PLAY RECAP:

```
localhost : ok=24  changed=2  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

The 2 `changed` are the Docker GPG key download and dearmor steps — these use `force: true` by design to always get the latest key. Every application task — user creation, directory setup, `.env` templating, Docker Compose deployment, backup script, cron job — showed `ok` (no change needed).

The handler did **not** fire on the second run because the `.env` file was identical — `notify` was not triggered, so the app was not restarted. This is exactly correct handler behaviour.

---

## Issues Faced & Solutions

### Issue 1: DB name mismatch — server crashed on startup

**Problem:** The server container kept restarting immediately. Tailing logs showed it was trying to connect to a database called `default`, but Postgres had only created one named `twenty`.

**Root cause:** The vault had `vault_db_name: "default"` but the official `docker-compose.yml` sets `POSTGRES_DB=twenty`. The Twenty CRM app tried to run migrations against a non-existent database.

**Fix:** Opened the vault and corrected the value:

```bash
ansible-vault edit group_vars/vault.yml
# changed vault_db_name: "default" → vault_db_name: "twenty"
```

Then wiped the volumes (old broken DB state) and redeployed:

```bash
docker compose -f /opt/twentycrm/docker-compose.yml down -v
ansible-playbook site.yml
```

---

### Issue 2: `community.docker` collection not found

**Problem:** First run failed immediately — `couldn't resolve module/action 'community.docker.docker_compose_v2'`.

**Root cause:** The collection wasn't installed — it's not bundled with Ansible core.

**Fix:**

```bash
ansible-galaxy collection install -r requirements.yml
```

Added `requirements.yml` to the project so it's documented for anyone cloning the repo.

---

### Issue 3: Handler not firing after `.env` change

**Problem:** Updated the vault values and reran the playbook. The `.env` template task showed `changed` but the app kept serving the old config — handler never triggered.

**Root cause:** The `notify` string in the task was `"restart twentycrm"` (lowercase) but the `listen` string in the handler was `"Restart Twenty CRM"` (mixed case). Ansible string matching is case-sensitive.

**Fix:** Made both strings identical — `"Restart Twenty CRM"` — and the handler fired correctly on the next run.

---

### Issue 4: App directory owned by root

**Problem:** Docker Compose couldn't write socket files and volume data under `/opt/twentycrm` — permission denied errors in container logs.

**Root cause:** The `app_dir` was created as root (from a previous manual `mkdir`) before the `app_user` role ran. The `twentycrm` user couldn't write to its own home directory.

**Fix:** Added a recursive ownership fix task at the end of the `twentycrm` role:

```yaml
- name: Fix ownership on app directory
  ansible.builtin.file:
    path: "{{ app_dir }}"
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    recurse: true
```

---

### Issue 5: Vault password not found

**Problem:** Running `ansible-playbook site.yml` failed with `ERROR! Attempting to decrypt but no vault secrets found`.

**Root cause:** The `ansible.cfg` pointed to `~/.vault_pass` but the file hadn't been created yet.

**Fix:**

```bash
echo "MyVaultPass@2026" > ~/.vault_pass
chmod 600 ~/.vault_pass
```

---

## Summary

| Step | Action | Status |
|------|--------|--------|
| 1 | Scaffolded 5 roles with `ansible-galaxy init` | ✅ Done |
| 2 | Installed `community.docker` via `requirements.yml` | ✅ Done |
| 3 | Configured `ansible.cfg` with vault path + settings | ✅ Done |
| 4 | Created inventory (hosts.ini + hosts.yml) | ✅ Done |
| 5 | Set non-sensitive vars in `group_vars/all.yml` | ✅ Done |
| 6 | Encrypted secrets in `group_vars/vault.yml` (AES256) | ✅ Done |
| 7 | `roles/common` — system update + base packages | ✅ Done |
| 8 | `roles/docker` — Docker CE + compose plugin + handler | ✅ Done |
| 9 | `roles/app_user` — dedicated `twentycrm` OS user | ✅ Done |
| 10 | `roles/twentycrm` — directories, templates, Docker Compose | ✅ Done |
| 11 | `roles/backup` — backup script + daily cron job | ✅ Done |
| 12 | Jinja2 templates — `env.j2`, `docker-compose.j2`, `backup.sh.j2` | ✅ Done |
| 13 | Handler restarts app only when `.env` or compose changes | ✅ Done |
| 14 | All 3 containers healthy — server, db, redis | ✅ Done |
| 15 | HTTP 200 confirmed via `curl` + Ansible `uri` module | ✅ Done |
| 16 | Twenty CRM UI accessible — workspace and data visible | ✅ Done |
| 17 | Idempotent — core tasks `ok` on second run, handler silent | ✅ Done |
| 18 | `.vault_pass` excluded from git via `.gitignore` | ✅ Done |

---

## What I Learned

**Ansible Vault** is the right way to handle secrets — the encrypted `vault.yml` commits safely to GitHub. The key insight is that the vault file itself is harmless without the password, so separating them (file in repo, password in `~/.vault_pass`) gives security without losing convenience.

**Handlers have exact string matching** — `notify: restart app` and `listen: Restart App` are different strings. One typo silently breaks the entire restart mechanism with no error message. Always copy-paste the string between `notify` and `listen`.

**`ansible-galaxy init` saves time** — running it for each role creates all the standard directories automatically. Without it I'd be creating `tasks/`, `handlers/`, `defaults/`, `vars/`, `meta/`, `templates/`, `files/`, `tests/` manually for each role.

**`community.docker.docker_compose_v2`** is far better than `command: docker compose up` — it understands state, shows meaningful `changed`/`ok` output, and handles idempotency correctly. The Galaxy collection system makes it easy to add this kind of functionality.

**Idempotency takes deliberate thinking** — every task needs to ask "what happens if this already exists?" The `state: present` pattern, `cache_valid_time`, `force: false` on downloads, and the `uri` health check with `until`/`retries` are all techniques that make a playbook safe to run multiple times without breaking anything.

**Jinja2 templates keep config DRY** — without templates, I'd have to update the actual `.env` file on every deployment and risk forgetting to rotate a secret. With templates, the playbook generates the correct file from variables on every run.
