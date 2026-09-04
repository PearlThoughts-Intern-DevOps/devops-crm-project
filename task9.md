# Task 9 — Ansible Playbook: Automating Twenty CRM Setup

**Branch:** `sakhisurakhya/task-9`
**Playground used:** Killercoda — Ansible Labs → "Ansible Playbook Deployer" (`het-tanis/course/Ansible-Labs/06-Ansible-Playbook-Deployer`)

## 1. Overview

This task automates the same manual setup process performed by hand in Tasks 3, 5, and 7 (install Docker, configure the app, run Twenty CRM) using an **Ansible playbook** — a single repeatable, idempotent command that installs Docker, creates a dedicated app user, clones the repository, templates the configuration, and starts Twenty CRM via Docker Compose on a target host.

**Target host:** `node01` (a pre-provisioned target node in the Killercoda Ansible Playground, reachable from the `controlplane` control node).

## 2. Project Structure

```
ansible/
├── ansible.cfg              # Ansible project configuration
├── inventory.ini            # Target host inventory (node01)
├── requirements.yml         # Required Ansible Galaxy collections
├── playbook.yml             # Main playbook (all tasks + handler)
├── vars/
│   └── main.yml              # Variables (user, paths, app config)
└── templates/
   ├── env.j2                 # Jinja2 template for .env config
    └── docker-compose.yml.j2  # Jinja2 template for docker-compose.yml
|__Screenshots 


## 3. What the Playbook Does

| Requirement | How it's implemented |
|---|---|
| Inventory with target host | `inventory.ini` — `[twenty_crm]` group pointing at `node01` |
| Install dependencies + Docker | `apt` tasks install `docker.io`, `docker-compose-v2`, `git`, `curl`, `python3-pip`, plus the Docker Python SDK (`docker`, `requests`) needed by the `community.docker` collection |
| Dedicated application user | `group` + `user` modules create a system user `twentycrm`, added to the `docker` group |
| Directories with permissions | `file` module (loop) creates `/opt/twentycrm`, `/opt/twentycrm/config`, `/opt/twentycrm/data`, owned by the app user, mode `0750` |
| Clone the repository | `git` module clones `devops-crm-project` into the app directory, run as the app user |
| Configure via variables + Jinja2 | `template` module renders `env.j2` and `docker-compose.yml.j2` using values from `vars/main.yml` |
| Start via Docker Compose | `community.docker.docker_compose_v2` module brings up the stack |
| Handler on config change | Both `template` tasks `notify: restart twenty crm`; the handler only fires if the rendered file actually changed |
| Verify running successfully | `wait_for` (port check) + `uri` module (HTTP 200 check, with retries) confirm the app is actually responding, not just that containers started |
| Idempotency | Every task uses idempotent Ansible modules (`apt`, `user`, `group`, `file`, `git`, `template`, `docker_compose_v2`) rather than raw `shell`/`command` — demonstrated in Section 5 |

## 4. How to Run It

### 4.1 Prerequisites (on the control node)
```bash
ansible-galaxy collection install -r requirements.yml
```

### 4.2 Test connectivity
```bash
ansible -i inventory.ini twenty_crm -m ping
```
Result:
```
node01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4.3 Run the playbook
```bash
ansible-playbook -i inventory.ini playbook.yml
```

### 4.4 Verify manually on the target host
```bash
ssh node01
sudo docker ps
curl -I http://127.0.0.1:2020
```

## 5. Idempotency Verification

Ran the playbook against `node01` and observed the following behavior across runs:

**First run** — installed Docker, created the user/directories, cloned the repo, rendered the templates, and started the Twenty CRM container. Result:
```
node01 : ok=14  changed=7  unreachable=0  failed=1  skipped=0
```
*(One task — the HTTP verification — initially failed due to the container still finishing its startup sequence under low memory; see Issue 1 below. This was not a playbook logic error.)*

**After resolving the memory constraint (Issue 1) and re-running the playbook**, every task reported `ok` with **zero changes**, since the environment was already in the exact desired state:
```
TASK [Report Twenty CRM deployment status] ***
ok: [node01] =>
  msg: Twenty CRM is up and responding with HTTP 200 on port 2020

PLAY RECAP
node01 : ok=16   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

This confirms idempotency: with nothing to change (packages already installed, user/group already present, directories already correct, templates already matching byte-for-byte so the restart handler did **not** fire, and the Docker Compose stack already running as desired), Ansible correctly reported `changed=0` across all 16 tasks on the repeat run.



## 6. Issues Faced & Solutions

### Issue 1 — HTTP health check failed with "Connection reset by peer" on first run
**Problem:** The final verification task (`Verify HTTP response from Twenty CRM`) failed after exhausting its retries, with:
```
msg: 'Status code was -1 and not [200]: Connection failure: [Errno 104] Connection reset by peer'
```
**Diagnosis:** Connected directly to `node01` and checked resources — `free -h` showed the node had only ~66MB of RAM available (out of 1.9GB total) with **zero swap configured**. The node is a Killercoda lab VM already running Kubernetes system pods in the background (visible via `kubelet`/`containerd` mounts in `df -h`), leaving very little memory for the Twenty CRM container's startup process (migrations, marketplace catalog sync, cron registration, etc.) — the same class of issue encountered in Task 7's EC2 deployment.
**Solution:** Added a 1GB swap file directly on `node01`:
```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```
Confirmed via `docker inspect --format='{{json .State.Health}}' twentycrm-server` that the container's own health check then transitioned to `"Status":"healthy"`, and `curl -I http://127.0.0.1:2020` returned `HTTP/1.1 200 OK`. Re-ran the playbook afterward, which then completed cleanly through the verification task. Also increased the `uri` module's `retries` from 10 to 15 in the playbook to give more headroom for resource-constrained target hosts in general.

### Issue 2 — `pip` install failed with "externally-managed-environment"
**Problem:** The `Install Python Docker SDK` task failed with:
```
error: externally-managed-environment
× This environment is externally managed
```
**Diagnosis:** Modern Debian/Ubuntu releases (PEP 668) block `pip install` from writing directly into the system Python environment, to prevent conflicts with OS-managed packages.
**Solution:** Added `extra_args: --break-system-packages` to the `ansible.builtin.pip` task. This is safe for a disposable lab/target VM dedicated to this deployment; in a production context, using a Python virtual environment (`community.general` or a `venv` task) would be the more conservative alternative.

### Issue 3 — Browser-based terminal paste unreliability
**Problem:** Pasting large multi-line file content (especially `playbook.yml`) directly into Killercoda's terminal via `nano` or `cat << EOF` occasionally corrupted or truncated the file, likely due to the browser terminal's paste-buffering limits.
**Solution:** Switched to Killercoda's built-in graphical **Editor** tab (a VS Code-based file editor) for the largest file, and used smaller, chunked `cat >> file << EOF` appends via the terminal for the rest — verifying line counts (`wc -l`) and running `ansible-playbook --syntax-check` after each step to catch corruption early before attempting a full run.

`

