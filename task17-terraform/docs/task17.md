# Task 17: Ansible + Terraform EC2 Deployment (Twenty CRM)

## Overview
Provisioned one EC2 instance using Terraform and deployed Twenty CRM on it using an Ansible playbook (Docker + docker-compose), then destroyed the infra with Terraform.

## Infra (Terraform)
- Region: us-east-1
- Instance type: t3.small
- AMI: ami-0b6d9d3d33ba97d99 (Ubuntu)
- Default VPC + default subnet (via data sources, no new VPC created)
- Security group: ports 22 (SSH) and 3000 (app) open
- Key pair: vikash-task17 (created via `aws ec2 create-key-pair`)

Commands used:
terraform init
terraform validate
terraform plan
terraform apply -auto-approve


## Configuration (Ansible)
Ansible was installed directly on the EC2 instance and run against `localhost` (connection=local), since the local Windows machine can't act as an Ansible control node (WSL2 unavailable due to RAM limits).

Playbook (`playbook.yml`) tasks:
- Update server packages (`apt update && upgrade`)
- Install Docker (get.docker.com script) + docker-compose plugin
- Create app directory `/opt/twenty-crm`
- Write `.env` with app/db/redis config
- Write `docker-compose.yml` defining:
  - `db` (postgres:16) — healthcheck via `pg_isready`
  - `redis` (redis:7) — healthcheck via `redis-cli ping`
  - `server` (twentycrm/twenty:latest) — depends_on db & redis (`condition: service_healthy`), healthcheck via `curl /healthz`
  - All services: `restart: always`
- Deploy via `docker compose up -d`
- Verify: `docker compose ps` (container status) and `docker compose logs` (app logs)

Run command:
ansible-playbook -i inventory.ini playbook.yml


## Verification
- `docker compose ps` showed db, redis, server containers `Up`/`healthy`
- `curl -I http://localhost:3000` returned `HTTP/1.1 200 OK`
- App confirmed reachable at `http://<public_ip>:3000`

## Issues & Fixes
| Issue | Fix |
|---|---|
| HCL error: multi-arg single-line blocks in security group | Expanded `ingress`/`egress` blocks to multi-line syntax |
| SSH key `.pem` from Task 16 not found | Generated new key pair `vikash-task17` |
| `.pem` "invalid format" | PowerShell `>` redirect used UTF-16; regenerated with `Out-File -Encoding ascii` |
| `terraform apply` showed no changes after key swap | Terraform doesn't diff key material, only key name — used `terraform apply -replace="aws_instance.twenty"` |
| YAML parse error in playbook | Curly quotes from paste corrupted file; recreated via `cat <<'EOF'` heredoc |
| Server container restarting, `psql socket` error | App was using local socket instead of `db` host; added `PG_DATABASE_URL=postgres://postgres:postgres@db:5432/default` |
| `redis cache storage requires REDIS_URL` error | Added `redis` service to compose + `REDIS_URL=redis://redis:6379` to `.env` |
| Healthcheck `unhealthy` for ~2 min after migrations | App was still starting background jobs on t3.small; resolved on its own, `curl` returned 200 shortly after |

## Cleanup
terraform destroy -auto-approve

Confirmed no EC2 instance remained in the AWS console after destroy.

Then:
git add docs\task17.md
git commit -m "Task 17: Terraform + Ansible EC2 deployment docs"
git push origin vikash-yadav-task17