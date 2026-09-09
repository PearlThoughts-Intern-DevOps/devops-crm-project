# Task 9 — Twenty CRM Deployment with Ansible

## Objective

Automate deployment of Twenty CRM on an AWS Ubuntu EC2 instance using Ansible. The deployment must install Docker and prerequisites, create an application user, configure Docker Compose from Ansible variables and a Jinja2 template, start the application, restart it after configuration changes, verify availability, and remain idempotent.

## Target environment

| Item | Value |
|---|---|
| Platform | AWS EC2 |
| Operating system | Ubuntu Linux |
| Ansible inventory target | `twenty-server` (local connection) |
| CRM port | `3000` |
| Application URL | `http://108.130.246.178:3000` |

The AWS security group must allow inbound TCP port `3000` from the required client IP addresses.

## Project structure

```text
~/twenty-ansible/
├── ansible.cfg
├── inventory/hosts.ini
├── group_vars/all.yml
├── templates/docker-compose.yml.j2
├── files/Dockerfile
├── files/.dockerignore
└── playbook.yml
```

## Implementation
The Ansible playbook performs the following actions:

1. Updates the APT cache and installs `git`, `curl`, CA certificates, GnuPG, Python pip, Docker Engine, and Docker Compose v2.
2. Enables and starts the Docker service.
3. Creates a dedicated `twenty` group and application user. The user is added to the Docker group.
4. Creates `/opt/twenty-crm` with the correct ownership and permissions.
5. Clones the provided `devops-crm-project` repository into `/opt/twenty-crm/devops-crm-project`.
6. Copies the Dockerfile and `.dockerignore` file into the cloned repository.
7. Renders `docker-compose.yml` from `templates/docker-compose.yml.j2` using variables in `group_vars/all.yml`.
8. Starts Twenty CRM, PostgreSQL, Redis, and the worker using the `community.docker.docker_compose_v2` Ansible module.
9. Waits for port `3000` and verifies the application through an HTTP request.
10. Notifies the `restart twenty crm` handler whenever the Compose template changes.

Generated PostgreSQL and application secrets are stored locally by the Ansible password lookup under `/tmp/twenty_secrets`. The Compose configuration supplies the Twenty `ENCRYPTION_KEY` and database connection settings.

## Deployment command

```bash
cd ~/twenty-ansible
ansible-galaxy collection install community.docker
mkdir -p /tmp/twenty_secrets
chmod 700 /tmp/twenty_secrets
ansible-playbook playbook.yml
```

## Validation

The initial deployment completed successfully with this Ansible recap:

```text
PLAY RECAP
twenty-server : ok=18 changed=4 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

The HTTP verification task returned status `200`:

```text
Twenty CRM is up — HTTP status 200 at http://108.130.246.178:3000
```

Further validation commands:

```bash
docker compose -f /opt/twenty-crm/devops-crm-project/docker-compose.yml ps
curl -i http://127.0.0.1:3000/healthz
curl -I http://108.130.246.178:3000
```

The web interface was accessible at `/welcome` through the EC2 public address.

## Idempotence

The playbook uses state-based Ansible modules (`apt`, `systemd`, `group`, `user`, `file`, `git`, `copy`, `template`, and `docker_compose_v2`). Re-running it does not recreate resources that are already in the desired state. To demonstrate this, run:

```bash
cd ~/twenty-ansible
ansible-playbook playbook.yml
```

On a subsequent run, already configured resources should report `ok`; changes occur only if packages, source code, or rendered configuration have changed.

## Configuration change handling

The Docker Compose template task notifies the `restart twenty crm` handler when variables or template content changes. The handler executes Docker Compose with `state: restarted`, ensuring that Twenty CRM uses the latest rendered configuration.

## Conclusion

Twenty CRM was deployed successfully on AWS through an idempotent Ansible playbook. The service is containerized with Docker Compose, automatically verified through HTTP, and configured to restart when deployment configuration changes.