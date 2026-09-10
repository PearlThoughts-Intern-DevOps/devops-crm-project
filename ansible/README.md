# Task 9: Twenty CRM Deployment with Ansible

This project deploys Twenty CRM on a single Ubuntu 22.04 server using Ansible and Docker Compose. The Ansible control node and managed host are the same KodeKloud Playground machine, so the inventory uses a local connection instead of SSH.

## Architecture

The deployment runs three Docker services:

- Twenty CRM
- PostgreSQL
- Redis

Twenty CRM is exposed on host port `2020`.

## Project Structure

```text
ansible/
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── all.yml
├── templates/
│   └── docker-compose.yml.j2
├── handlers/
│   └── main.yml
├── screenshots/
├── playbook.yml
└── README.md
```

## Requirements

- Ubuntu 22.04
- Ansible Core 2.17
- Git
- `community.docker` Ansible collection
- Internet access for packages, the repository clone, and Docker images

## Inventory

```ini
[twenty]
localhost ansible_connection=local
```

`ansible_connection=local` tells Ansible to manage the machine on which the command is executed. No separate target server or SSH connection is required.

## Install the Prerequisites

```bash
apt update
apt install -y ansible git python3-pip
python3 -m pip install --upgrade 'ansible-core>=2.17,<2.18'
ansible-galaxy collection install community.docker
```

Verify Ansible:

```bash
ansible --version
```

## Test the Inventory

Run from the `ansible` directory:

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

## Validate the Playbook

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml --syntax-check
```

Expected result:

```text
playbook: playbook.yml
```

## Deploy Twenty CRM

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

The playbook:

1. Confirms that the server runs Ubuntu 22.04.
2. Installs the required dependencies and Docker packages.
3. Enables and starts Docker.
4. Creates the dedicated `twenty` user and group.
5. Creates the application directories with the correct permissions.
6. Clones the official Twenty CRM repository.
7. Renders the Docker Compose configuration from a Jinja2 template.
8. Starts PostgreSQL, Redis, and Twenty CRM.
9. Runs the restart handler when the Compose configuration changes.
10. Verifies port `2020` and an HTTP `200` response.

## Verify Docker and the Application

```bash
docker --version
docker compose version
cd /opt/twenty
docker compose ps
curl -I http://localhost:2020
```

The Compose output should show PostgreSQL as healthy and Redis and Twenty CRM as running. The HTTP request should return:

```text
HTTP/1.1 200 OK
```

Twenty CRM can be accessed at `http://SERVER_IP:2020`, replacing `SERVER_IP` with the address supplied by the playground.

## Test Idempotency

Run the playbook a second time:

```bash
cd /root/devops-crm-project/ansible
ansible-playbook -i inventory/hosts.ini playbook.yml
```

Expected recap:

```text
localhost : ok=18 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

`changed=0` and `failed=0` demonstrate that the playbook is idempotent.

## Issues Faced and Resolutions

### 1. Ansible Version Was Too Old

Ubuntu initially installed Ansible 2.10.8, which was too old for `community.docker` 5.2.2 and the `docker_compose_v2` module.

The issue was resolved by installing a compatible Ansible Core release:

```bash
apt install -y python3-pip
python3 -m pip install --upgrade 'ansible-core>=2.17,<2.18'
ansible --version
```

The resulting version was Ansible Core 2.17.14.

### 2. Docker Compose Ansible Module Was Unavailable

The `community.docker.docker_compose_v2` module is not included with Ansible Core by default.

The required collection was installed with:

```bash
ansible-galaxy collection install community.docker
```

### 3. Single-Node Inventory Configuration

The KodeKloud Playground used the same machine as both the Ansible control node and the managed host, so a normal SSH inventory was unnecessary.

The inventory was configured to use a local connection:

```ini
[twenty]
localhost ansible_connection=local
```

The connection was verified with:

```bash
ansible -i inventory/hosts.ini twenty -m ping
```

Ansible returned `SUCCESS` and `pong`.

### 4. Docker Engine and Compose Were Initially Unavailable

Docker Engine and the Docker Compose plugin were not installed in the original playground environment.

The playbook configured Docker's official Ubuntu repository and installed:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

The installation was verified with:

```bash
docker --version
docker compose version
```

### 5. Twenty CRM Needed Time to Start

Port `2020` opened before Twenty CRM was completely ready. The first HTTP checks failed while database migrations and application startup were still running.

The playbook first waits for the port and then retries the HTTP request:

```yaml
retries: 30
delay: 10
until: twenty_http_check.status == 200
```

The check eventually succeeded, and the manual request returned `HTTP/1.1 200 OK`.

### 6. Service Startup Order

Twenty CRM depends on PostgreSQL and Redis. Starting it before PostgreSQL was ready could cause application startup failures.

A PostgreSQL health check and Compose dependency conditions were added:

```yaml
depends_on:
  postgres:
    condition: service_healthy
  redis:
    condition: service_started
```

The final Compose status showed PostgreSQL as healthy and all three services running.

### 7. Configuration Changes Required a Restart

Changes to the generated Docker Compose configuration needed to be applied without restarting the application on every playbook run.

The template task notifies the `Restart Twenty CRM` handler only when its content changes:

```yaml
notify: Restart Twenty CRM
```

This applies configuration changes while avoiding unnecessary restarts.

### 8. Ensuring Idempotency

The playbook needed to avoid unnecessary changes during repeated execution.

Declarative Ansible modules were used for packages, users, directories, Git, templates, services, and Docker Compose. The second execution produced:

```text
changed=0
unreachable=0
failed=0
```

This confirmed that the playbook is idempotent.

## Troubleshooting

Check Docker and the deployed services:

```bash
systemctl status docker
docker compose version
cd /opt/twenty
docker compose ps
docker compose logs --tail=50
```

The first Twenty CRM startup can take several minutes while database migrations complete.

## Result

The playbook provides an automated, repeatable deployment of Twenty CRM with PostgreSQL and Redis on one Ubuntu 22.04 host.
