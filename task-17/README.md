\# Task 17 - Terraform + Ansible Deployment of Twenty CRM



Terraform provisions the EC2 instance. Ansible configures it and deploys Twenty CRM.



\---



\## Architecture



```

Terraform (Windows)  →  EC2 (t3.small, Ubuntu 26.04)  →  Ansible configures locally

&#x20;                                                         ├── installs Docker

&#x20;                                                         ├── creates /opt/twenty-crm

&#x20;                                                         ├── writes .env

&#x20;                                                         └── runs 3 containers

```



\- \*\*Terraform\*\*: EC2 + Security Group only (no user\_data)

\- \*\*Ansible\*\*: Runs on the EC2 itself (`ansible\_connection=local`), configures everything



\---



\## Terraform



Provisions in default VPC:

\- EC2 t3.small, `ami-0b6d9d3d33ba97d99`, 20 GiB gp3

\- Security Group: port 22 (from my IP), port 2020 (from anywhere)



\*\*Outputs:\*\*

```

instance\_id        = "i-0f97de82c8f44b2f6"

instance\_public\_ip = "44.202.179.124"

```



\*\*Commands run:\*\* `terraform init`, `validate`, `plan`, `apply -auto-approve`



\---



\## Ansible



\### `ansible.cfg`

```ini

\[defaults]

host\_key\_checking = False

inventory = inventory.ini

retry\_files\_enabled = False

deprecation\_warnings = False



\[privilege\_escalation]

become = True

become\_method = sudo

become\_user = root

become\_ask\_pass = False

```



\### `inventory.ini`

```ini

\[twenty\_crm]

localhost ansible\_connection=local

```



\### `deploy.yml` — Task groups



1\. \*\*System prep\*\* — Create 2 GB swap, update apt, install required packages (curl, gnupg, python3-pip, python3-docker)

2\. \*\*Docker install\*\* — Install `docker.io`, enable and start service

3\. \*\*Directories\*\* — Create `/opt/twenty-crm`, `postgres-data`, `redis-data`

4\. \*\*Environment\*\* — Write `/opt/twenty-crm/.env` with `PG\_DATABASE\_URL`, `REDIS\_URL`, `APP\_SECRET`, `SERVER\_URL`

5\. \*\*Deploy containers\*\* — Docker network `twenty-net`; run Postgres 16, Redis 7, and `twentycrm/twenty:latest` with `restart\_policy: always` and health check

6\. \*\*Verify\*\* — Wait for HTTP 200 on port 2020; print `docker ps`; print Twenty CRM logs; print health status



\---



\## Playbook Run Output



```

PLAY RECAP \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

localhost : ok=23  changed=5  unreachable=0  failed=0  skipped=2  rescued=0  ignored=0

```



\### Container status



```

CONTAINER ID   IMAGE                     STATUS                    PORTS                    NAMES

4bd637ed36dd   twentycrm/twenty:latest   Up About an hour (healthy)   0.0.0.0:2020->3000/tcp   twenty-crm

c1b407d8cb67   redis:7                   Up 10 minutes             6379/tcp                 twenty-redis

01147b919c53   postgres:16               Up About an hour          5432/tcp                 twenty-db

```



\### Health check



```

Twenty CRM health status: healthy

```



\### App verification (from inside EC2)



```bash

$ curl -I http://localhost:2020

HTTP/1.1 200 OK

Content-Type: text/html; charset=utf-8

Content-Length: 38372

```



\---



\## Issues Encountered and Resolutions



| # | Issue | Root Cause | Fix |

|---|---|---|---|

| 1 | `pip3 install docker` failed (PEP 668) | Ubuntu 26.04 blocks system pip | Used `apt install python3-docker` instead |

| 2 | Ansible callback `community.general.yaml` removed | Ansible 2.20 removed the plugin | Removed `stdout\_callback` from `ansible.cfg` |

| 3 | Playbook snapshot showed `unhealthy` (30 retries exhausted) | t3.small had no swap; cold first boot | Added 2 GB swap task; bumped retries to 60 |

| 4 | Redis `MISCONF` errors | Redis (UID 999) couldn't write to volume owned by ubuntu | `chown -R 999:999 /opt/twenty-crm/redis-data` |

| 5 | SSH dropping every few minutes | Local network instability | Ran playbook with `tee` to log output |



\---



\## Cleanup



```bash

cd terraform

terraform destroy -auto-approve

```



\---



\## Files



\- `task-17/ansible.cfg` — Ansible configuration

\- `task-17/inventory.ini` — localhost inventory

\- `task-17/deploy.yml` — main playbook

\- `task-17/run-output.log` — full playbook output

\- `task-17/README.md` — this file

\- `terraform/\*.tf` — EC2 + SG provisioning



\---





