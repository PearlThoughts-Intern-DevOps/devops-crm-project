# Task 9: Ansible Playbook – Twenty CRM Automation

## Objective

Automate the complete setup of Twenty CRM on a Linux target host using
Ansible — dependencies, Docker, a dedicated app user, directories, source
checkout, templated configuration, Docker Compose startup, a restart
handler, and verification.

## Environment Used

Killercoda Ubuntu 24.04 playground — Ansible control node and target node
connected over SSH. (Development started on the KodeKloud sandbox and was
completed on Killercoda.)

## Project Structure

```
devops-crm-project/
├── README.md              — this file
├── ansible/
│   ├── ansible.txt         — Ansible config: inventory path, SSH/become defaults
│   ├── hosts.txt            — inventory: target host under the twenty_crm group
│   ├── all.yml               — variables: user, dirs, repo, image, ports, DB creds, secrets
│   ├── env.j2                — Jinja2 template that renders the app's .env file
│   ├── docker-compose.yml.j2 — Jinja2 template that renders the Docker Compose stack
│   └── playbook.yml          — main playbook: all tasks + the restart handler
└── Screenshots/            — proof of playbook run, idempotency check, and verification
└── Ansible_Documentation/      - Documentation of complete procedures

```

## Walkthrough of `playbook.yml`

The play targets the `twenty_crm` group, runs with `become: true`, and loads
`all.yml` via `vars_files`. Tasks execute top to bottom as follows:

1. **Dependencies** — updates apt cache, installs `ca-certificates`, `gnupg`,
   `curl`, `lsb-release`, `git`, `python3-pip`.
2. **Docker install** — adds Docker's official apt key and repo, installs
   Docker Engine + CLI + containerd + Buildx + Compose v2 plugin, installs
   `python3-docker` via apt (not pip, due to Ubuntu 24.04's PEP 668
   restriction), enables and starts the Docker service.
3. **Application user** — creates a dedicated `twenty` group and user, adds
   it to the `docker` group, pre-creates its Ansible remote-tmp dir with
   correct ownership.
4. **Directories** — creates a compose project directory and a separate
   source-clone directory, both owned by `twenty`.
5. **Clone repository** — shallow-clones the official Twenty CRM repo into
   the source directory, running as the `twenty` user.
6. **Configure via templates** — renders `env.j2` → `.env` and
   `docker-compose.yml.j2` → `docker-compose.yml` into the compose
   directory; both notify the restart handler on change.
7. **Start containers** — runs `docker_compose_v2` (`state: present`) to
   bring up `db`, `redis`, `server`, and `worker`.
8. **Verify** — waits for the app port to open, polls `/healthz` until it
   returns HTTP 200, then prints the confirmed status.

**Handler (`restart twenty crm`)** — only fires when the `.env` or
`docker-compose.yml` templates actually change; restarts the stack via
Compose as the `twenty` user.

## Idempotency

The playbook was run twice. On the second run, package, user, directory,
and templating tasks reported no changes and the handler did not fire —
confirming safe re-runs.

## Verification

Confirmed on the target with `docker ps` (all four containers healthy) and
`curl -i http://localhost:3000/healthz` (HTTP 200).

## Key Design Decisions

- Separate compose and source directories, so re-cloning never overwrites
  generated config.
- Self-authored Compose template instead of the repo's own file, for an
  explicit, version-controlled, variable-driven deployment.
- `apt` over `pip` for the Docker Python SDK, to respect Ubuntu 24.04's
  externally-managed-environment protection.
- Verification against `/healthz` instead of `/`, since the Twenty API
  server returns 404 at the root path by design.

## What I Learned

- Structuring an Ansible project across inventory, group vars, templates,
  and a playbook with a handler.
- Handlers only fire on actual change notification — key to idempotency.
- Installing Docker + Compose v2 via Ansible using `community.docker`, and
  why the Docker Python SDK is required for `docker_compose_v2`.
- Ubuntu 24.04's PEP 668 changes the correct way to install Python packages
  system-wide.
- Verifying a real health endpoint rather than assuming the root path or
  any 2xx/3xx status means success.
