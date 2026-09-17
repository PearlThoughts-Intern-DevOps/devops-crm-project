# Task 17: Ansible and AWS EC2 Deployment

## Objective

Use Terraform only to create a minimal AWS EC2 infrastructure and use Ansible to configure the server and deploy Twenty CRM with Docker Compose.

Terraform does not use `user_data`, provisioners, ECR, S3, an ALB, RDS, or a custom VPC. Ansible performs all operating-system and application configuration.

## Verified Result

- Region: `us-east-1`
- EC2 name: `chirag-crm-dev-task-17-ec2`
- Instance type: `t3.small`
- AMI: `ami-081b0a6eac00b4f53` (Amazon Linux 2023, x86_64)
- Instance ID: `i-09078b481c290f07c`
- Public IP during verification: `54.198.78.176`
- Application URL during verification: `http://54.198.78.176:2020`
- Existing key pair: `chirag-ansible-crm`
- Ansible SSH user: `ec2-user`
- Twenty CRM version: `v2.38.1`
- Docker Compose version: `v5.5.1`
- Final Ansible recap: `ok=29 changed=0 unreachable=0 failed=0 skipped=2`
- Browser verification: successful

The public IP and URL are temporary and become invalid after `terraform destroy`.

## Architecture

```text
Local Mac
   |
   | Terraform
   v
AWS us-east-1
└── Existing default VPC
    └── Existing default subnet
        └── EC2 t3.small (Amazon Linux 2023)
            ├── TCP 22 from administrator IP /32
            └── TCP 2020 from the internet
                 ^
                 | SSH / Ansible
                 |
              Local Mac

EC2 instance
└── Docker Compose
    ├── Twenty server :2020 -> :3000
    ├── Twenty worker
    ├── PostgreSQL 16
    └── Redis 7
```

## Directory Structure

```text
devops-crm-project/
└── task-17/
    ├── README.md
    ├── screenshots/
    │   └── README.md
    ├── terraform/
    │   ├── .gitignore
    │   ├── .terraform.lock.hcl
    │   ├── versions.tf
    │   ├── provider.tf
    │   ├── variables.tf
    │   ├── data.tf
    │   ├── security-group.tf
    │   ├── ec2.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars.example
    └── ansible/
        ├── .gitignore
        ├── ansible.cfg
        ├── inventory.ini
        ├── playbook.yml
        ├── group_vars/
        │   └── all.yml
        ├── handlers/
        │   └── main.yml
        └── templates/
            ├── docker-compose.yml.j2
            └── twenty.env.j2
```

Local Terraform state, plans, `terraform.tfvars`, generated Ansible secrets, and the private PEM key are not committed.

## Terraform Configuration

Terraform uses data sources to retrieve:

- The existing default VPC
- Available default subnets
- One selected default subnet
- The existing `chirag-ansible-crm` EC2 key pair

Terraform creates only:

- One EC2 instance
- One security group
- One SSH ingress rule
- One Twenty CRM ingress rule
- One outbound rule

The EC2 instance has a 20 GiB encrypted `gp3` root volume, IMDSv2 enforcement, a public IPv4 address, and standard T3 CPU credits. It contains no Terraform `user_data` or provisioners.

### Security Group

| Direction | Port | Source/destination | Purpose |
| --- | ---: | --- | --- |
| Inbound | 22 | Administrator public IP `/32` | SSH and Ansible |
| Inbound | 2020 | `0.0.0.0/0` | Twenty CRM browser access |
| Outbound | All | `0.0.0.0/0` | Packages and container images |

If the administrator public IP changes, retrieve the new address:

```bash
curl -s https://checkip.amazonaws.com
```

Update `ssh_allowed_cidr` in the ignored `terraform.tfvars`, then run a new Terraform plan and apply.

### Terraform Variables

Create the local variables file from the example:

```bash
cd task-17/terraform
cp terraform.tfvars.example terraform.tfvars
```

Set the local values:

```hcl
key_name         = "chirag-ansible-crm"
ssh_allowed_cidr = "YOUR_PUBLIC_IP/32"
private_key_path = "~/Downloads/chirag-ansible-crm.pem"
```

`terraform.tfvars` is ignored by Git.

## Terraform Deployment

Run from `task-17/terraform`:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=task17.tfplan
terraform apply task17.tfplan
```

Retrieve useful outputs:

```bash
terraform output
terraform output -raw public_ip
terraform output -raw public_dns
terraform output -raw ssh_command
terraform output -raw application_url
```

The configuration provides these outputs:

- `instance_id`
- `public_ip`
- `public_dns`
- `ssh_command`
- `application_url`

## Ansible Configuration

### Inventory

The inventory connects to the Terraform-created instance as the verified Amazon Linux user:

```ini
[twenty]
EC2_PUBLIC_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/Downloads/chirag-ansible-crm.pem ansible_python_interpreter=/usr/bin/python3
```

The private PEM key is never copied into or committed to the repository. Its required local permission is:

```bash
chmod 400 ~/Downloads/chirag-ansible-crm.pem
```

### Why `ansible.cfg` Was Created

`ansible.cfg` keeps commands short and gives the project consistent behavior:

- `inventory = inventory.ini` selects the Task 17 inventory automatically, so `-i inventory.ini` is optional.
- `host_key_checking = True` protects against connecting to an unexpected SSH server.
- `interpreter_python = auto_silent` selects an appropriate Python interpreter without unnecessary discovery warnings.
- `retry_files_enabled = False` prevents obsolete `.retry` files from appearing in the repository.
- `timeout = 30` provides a reasonable SSH connection timeout.
- `pipelining = True` reduces SSH operations and improves playbook speed.

### Secrets

The playbook uses Ansible's password lookup to generate and persist:

- A PostgreSQL password
- A Twenty encryption key

They are stored locally under `task-17/ansible/.secrets/`, which is ignored by Git. Repeated playbook runs reuse the same values. The rendered remote `/opt/twenty/.env` file has mode `0600`.

The committed `twenty.env.j2` contains only Jinja placeholders, not real secret values.

### Playbook Responsibilities

The playbook:

1. Verifies Amazon Linux 2023.
2. Updates server packages.
3. Installs Docker and required dependencies.
4. Enables and starts Docker.
5. Installs a checksum-verified Docker Compose plugin.
6. Adds `ec2-user` to the Docker group.
7. Creates and enables a 4 GiB swap file for the 2 GiB instance.
8. Creates `/opt/twenty`.
9. Generates and securely renders the environment file.
10. Renders the Docker Compose configuration.
11. Starts PostgreSQL, Redis, the Twenty server, and the Twenty worker.
12. Runs configuration-change handlers when templates change.
13. Waits for port `2020` and the `/healthz` endpoint.
14. Verifies Docker is running.
15. Displays container status and recent server logs.

## Docker Compose Services

| Service | Image | Purpose |
| --- | --- | --- |
| `server` | `twentycrm/twenty:v2.38.1` | Twenty web server and API |
| `worker` | `twentycrm/twenty:v2.38.1` | Background jobs |
| `db` | `postgres:16-alpine` | Persistent database |
| `redis` | `redis:7-alpine` | Cache and job coordination |

Named volumes preserve PostgreSQL data, Redis data, and Twenty local storage.

## Docker Restart Policy

Every service uses:

```yaml
restart: unless-stopped
```

This restarts containers after crashes and Docker or EC2 restarts unless an administrator intentionally stops them.

Verified on the server with:

```bash
sudo docker inspect -f '{{.HostConfig.RestartPolicy.Name}} {{.State.Health.Status}}' twenty-server-1
```

Verified result:

```text
unless-stopped healthy
```

## Docker Health Checks

- Twenty server: `http://localhost:3000/healthz`
- PostgreSQL: `pg_isready`
- Redis: `redis-cli ping`

The playbook additionally checks `http://127.0.0.1:2020/healthz` from the EC2 host and retries while Twenty performs its initial database setup.

## Ansible Deployment

Verify the installed tools on the Mac:

```bash
ansible --version
ansible-galaxy collection list community.docker
```

Test connectivity from `task-17/ansible`:

```bash
ansible all -m ping --ssh-common-args='-o StrictHostKeyChecking=accept-new'
```

Run a syntax check:

```bash
ansible-playbook --syntax-check playbook.yml
```

Deploy:

```bash
ansible-playbook playbook.yml
```

## Verification

### Ansible Result

The successful deployment run finished with:

```text
ok=32 changed=15 unreachable=0 failed=0
```

The clean idempotency run finished with:

```text
54.198.78.176 : ok=29 changed=0 unreachable=0 failed=0 skipped=2 rescued=0 ignored=0
```

The two skipped tasks were expected:

- `Format new swap file` skipped because the swap file was already formatted.
- `Enable swap` skipped because swap was already active.

### EC2 Verification

Connect to the instance:

```bash
ssh -i ~/Downloads/chirag-ansible-crm.pem ec2-user@EC2_PUBLIC_IP
```

Check Docker:

```bash
sudo systemctl status docker --no-pager
```

The verified service state was `active (running)` and `enabled`.

Check containers:

```bash
cd /opt/twenty
sudo docker compose ps
```

Verified container state:

```text
twenty-db-1       Up (healthy)
twenty-redis-1    Up (healthy)
twenty-server-1   Up (healthy)   0.0.0.0:2020->3000/tcp
twenty-worker-1   Up
```

Check HTTP locally:

```bash
curl -I http://localhost:2020
```

Verified response:

```text
HTTP/1.1 200 OK
```

Check recent logs:

```bash
sudo docker compose logs --tail=50 server
```

The verified logs included `Nest application successfully started`.

### Browser Verification

Open:

```text
http://EC2_PUBLIC_IP:2020
```

The Twenty CRM page loaded successfully at `http://54.198.78.176:2020` before cleanup.

## Idempotency

The playbook was executed again after successful deployment. No configuration or container was unnecessarily changed:

```text
changed=0
failed=0
```

Generated secrets were reused, packages remained installed, Docker stayed running, swap remained active, templates remained unchanged, the restart handler did not run, and the existing Compose project remained healthy.

## Troubleshooting and Resolutions

### 1. Terraform Could Not Tag Security Group Rules

#### Symptom

The first Terraform apply created the EC2 instance and security group but failed while creating the three rules:

```text
UnauthorizedOperation: not authorized to perform ec2:CreateTags
on resource security-group-rule/*
```

#### Cause

The AWS provider's `default_tags` configuration propagated tags to individual security-group rule resources. The IAM user could create rules but could not tag rule resources.

#### Resolution

- Removed provider-wide `default_tags`.
- Defined `local.common_tags`.
- Applied explicit tags only to the EC2 instance, security group, and root EBS block.
- Kept rule resources untagged.
- Preserved the partial Terraform state instead of recreating infrastructure.
- Generated a repair plan containing only the three missing rules.

Final repair plan:

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

Final repair apply:

```text
Resources: 3 added, 0 changed, 0 destroyed.
```

### 2. Initial SSH Host-Key Verification Failed

#### Symptom

```text
Host key verification failed.
```

#### Resolution

Accepted only the new host key during the first connection:

```bash
ansible all -i inventory.ini -m ping \
  --ssh-common-args='-o StrictHostKeyChecking=accept-new'
```

The result was `SUCCESS` and `pong`. Normal host-key checking remained enabled afterward.

### 3. Amazon Linux `curl` Package Conflict

#### Symptom

The first Ansible run failed during dependency installation with a DNF dependency-solving error because `curl-minimal` was already installed and conflicted with `curl`.

First-run recap:

```text
ok=5 changed=1 unreachable=0 failed=1
```

#### Resolution

Replaced `curl` with the Amazon Linux-compatible `curl-minimal` package in the playbook. The next run reused the existing secrets and completed the deployment.

### 4. Twenty Needed Time to Become Healthy

#### Symptom

The port opened while the server was still running database setup, and the health task retried several times.

#### Resolution

The playbook uses retries and delay on the `/healthz` endpoint. It waited until HTTP `200` instead of treating normal startup time as a permanent failure.

### 5. Docker Initially Reported `health: starting`

#### Symptom

The first `docker compose ps` output captured the server during its health-check start period.

#### Resolution

The application-level health request succeeded, and a later Compose check confirmed:

```text
twenty-server-1   Up (healthy)
```

### 6. Ansible Fact Deprecation Warnings

#### Symptom

Ansible warned that top-level facts such as `ansible_distribution` are deprecated.

#### Resolution

Updated the assertions to use supported fact dictionary syntax:

```yaml
ansible_facts["distribution"]
ansible_facts["distribution_major_version"]
```

## Screenshot Checklist

Capture and retain screenshots of:

1. Terraform plan summary.
2. Terraform apply summary and outputs.
3. Ansible ping returning `pong`.
4. Successful Ansible recap with `failed=0`.
5. Idempotency recap with `changed=0`.
6. Docker service showing `active (running)`.
7. `docker compose ps` showing healthy containers.
8. Restart policy and health output.
9. `curl -I http://localhost:2020` returning HTTP `200`.
10. Twenty CRM open in the browser.

Store the corresponding image files in `task-17/screenshots/` using the suggested names in its `README.md`.

Do not include private keys, generated secret values, AWS access keys, or the contents of `.env` in screenshots.

## Cleanup

Do not destroy the infrastructure until browser verification, screenshots, and documentation are complete.

From `task-17/terraform`, first review the destruction plan:

```bash
terraform plan -destroy
```

Then destroy only after explicit confirmation:

```bash
terraform destroy
```

Verify the result reports all Task 17 resources destroyed and no errors.

Verified cleanup result:

```text
Resources: 0 added, 0 changed, 5 destroyed.
```

Terraform state was empty after cleanup. The existing default VPC, default subnet, and EC2 key pair were preserved.

## Git Workflow

The work was created on:

```text
chirag-task-17
```

After verification and cleanup, review files before committing:

```bash
git status --short
git diff --check
git add task-17
git status --short
git diff --cached
```

Commit and push:

```bash
git commit -m "Complete Task 17 Ansible EC2 deployment"
git push -u origin chirag-task-17
```

Then raise a pull request from `chirag-task-17` to the repository's target branch.

## Conclusion

Task 17 demonstrates separation of responsibilities: Terraform creates only the minimal AWS infrastructure, while Ansible idempotently configures Amazon Linux, installs Docker, manages secrets, deploys the complete Twenty CRM stack, waits for application health, and reports verification evidence. The final deployment passed SSH, Docker service, container health, HTTP, browser, restart-policy, and idempotency checks.
