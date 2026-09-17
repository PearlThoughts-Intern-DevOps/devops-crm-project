# Task 16: Twenty CRM Failure & Recovery

## Objective

Deploy Twenty CRM on an Amazon Linux 2023 EC2 instance with Terraform and
Docker, then verify automatic recovery after both a container process failure
and an EC2 stop/start cycle.

Task 16 was completed on branch:

```text
chirag-task-16
```

The deployment intentionally uses only the existing default VPC, an existing
default subnet, EC2, a security group, an EC2 key pair, and Docker. It does not
create an ALB, ECR repository, S3 bucket, RDS database, or new VPC.

## Architecture

```text
User
  |
  | HTTP :2020
  v
EC2 (Amazon Linux 2023)
  |
  +-- Docker Service
       |
       +-- Twenty CRM Compose Project
            +-- Twenty Server
            |    +-- Restart Policy
            |    `-- Health Check
            +-- Twenty Worker
            +-- PostgreSQL
            `-- Redis
```

AWS configuration:

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| Network | Existing default VPC and default subnet |
| Operating system | Amazon Linux 2023 x86_64 |
| Instance type | `t3.small` |
| Root disk | Encrypted 20 GiB `gp3` |
| Instance metadata | IMDSv2 required |
| Application port | TCP `2020` |
| SSH port | TCP `22` from the configured administrator `/32` |
| Twenty version | `v2.38.1` |

## Terraform EC2 Setup

The existing Terraform provider, default-VPC data source, default-subnet data
source, EC2 module, key-pair resource, security group, variables, and outputs
were reused. Task 15 ALB resources and references were removed from the active
root configuration.

Terraform manages six resources:

- One EC2 key pair registration using a local public key.
- One EC2 security group.
- One SSH ingress rule.
- One TCP `2020` application ingress rule.
- One outbound security-group rule.
- One EC2 instance.

The EC2 module requires IMDSv2:

```hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}
```

The initial plan was reviewed before applying:

```text
Plan: 6 to add, 0 to change, 0 to destroy.
```

The successful apply returned:

```text
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

Terraform outputs the instance ID, public IP, private IP, public DNS, security
group ID, key-pair name, subnet ID, VPC ID, and the Twenty URL.

Local state, variable files, plans, and downloaded providers are excluded by
`terraform/.gitignore`. Private keys and secrets must never be committed.

## Docker Installation

EC2 user-data installs Docker and enables it immediately:

```bash
dnf install -y docker openssl
systemctl enable --now docker
```

`systemctl enable docker` is essential for Task 16. It configures systemd to
start Docker automatically every time Amazon Linux boots. The `--now` option
also starts Docker during the current boot.

Docker Compose is installed as a pinned CLI plugin and verified with:

```bash
docker compose version
```

Docker service verification:

```bash
sudo systemctl status docker --no-pager
sudo systemctl is-enabled docker
sudo systemctl is-active docker
```

The verified service state was `enabled` and `active (running)`.

## Twenty CRM Deployment

Docker Compose is used because this Twenty deployment requires four connected
services:

- `server`: Twenty web application on container port `3000`.
- `worker`: Twenty background worker.
- `db`: PostgreSQL 16.
- `redis`: Redis 7.

The host publishes the server on port `2020`:

```yaml
ports:
  - "2020:3000"
```

PostgreSQL and local application storage use named Docker volumes so data
survives container restarts and EC2 stop/start operations.

User-data creates a restricted `/opt/twenty/.env` file with generated database
and encryption secrets. At every EC2 boot, `/usr/local/bin/twenty-start` reads
the current public IPv4 address through IMDSv2 and refreshes `SERVER_URL` before
running `docker compose up -d`. This handles the public-IP change that can occur
after an EC2 stop/start.

The Compose project is started automatically by the enabled
`twenty.service` systemd unit. The unit does not run `docker compose down`
during shutdown, so existing containers and volumes are not deleted.

## Docker Restart Policy

Every Compose service uses:

```yaml
restart: unless-stopped
```

Restart-policy behavior:

| Policy | Behavior |
| --- | --- |
| `no` | Never restart automatically; this is the default. |
| `always` | Restart after an exit and when Docker starts, except while Docker considers the container manually stopped. |
| `on-failure` | Restart only after a non-zero exit; it does not provide the same daemon-restart behavior. |
| `unless-stopped` | Restart after unexpected exits and daemon startup unless an administrator intentionally stopped the container. |

`unless-stopped` was selected because it supports unexpected-failure recovery
and normal EC2 boot recovery while respecting an intentional administrator
stop.

Verification command:

```bash
sudo docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-server-1
```

Verified result:

```text
unless-stopped
```

## Docker Health Check

The Twenty server health check uses the real `/healthz` endpoint:

```yaml
healthcheck:
  test: ["CMD", "curl", "--fail", "http://localhost:3000/healthz"]
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 30s
```

The image was inspected before relying on the command:

```bash
sudo docker exec twenty-server-1 which curl
```

Verified result:

```text
/usr/bin/curl
```

The endpoint returned HTTP `200` and:

```json
{"status":"ok","info":{},"error":{},"details":{}}
```

Container status and health status are different:

- `running` means the container process is running.
- `starting` means health checks are still in their startup period.
- `healthy` means the configured health command is succeeding.
- `unhealthy` means the health command failed for the configured retry count.

## Failure Test

The baseline was recorded before the test:

```bash
sudo docker inspect -f '{{.HostConfig.RestartPolicy.Name}} {{.RestartCount}} {{.State.Health.Status}}' twenty-server-1
```

Baseline result:

```text
unless-stopped 0 healthy
```

An explicit Docker CLI kill was tested first:

```bash
sudo docker kill twenty-server-1
```

On Docker Engine 25.0.16, the daemon recorded this administrator action as a
manual stop. The Docker journal showed `hasBeenManuallyStopped=true`, so the
restart policy was intentionally suppressed. This is why `docker stop` is not
used as proof of an unexpected failure either.

To simulate a genuine unexpected process crash without marking the container
as manually stopped, the server was started, its host PID was obtained, and
that process was killed from the EC2 host:

```bash
sudo docker start twenty-server-1
sudo docker inspect -f '{{.State.Pid}}' twenty-server-1
sudo kill -9 <CONTAINER_HOST_PID>
```

## Automatic Container Recovery

Recovery was checked after the unexpected process exit:

```bash
sudo docker inspect -f '{{.State.Status}} {{.RestartCount}} {{.State.Health.Status}}' twenty-server-1
```

Docker first reported:

```text
running 1 starting
```

After the startup health period, it reported:

```text
running 1 healthy
```

The restart count increasing from `0` to `1` proved that Docker automatically
restarted the same container. The health endpoint then returned HTTP `200`.

```text
Container failure
      |
      v
Docker restart policy
      |
      v
Container automatically restarts
      |
      v
Health check verifies application
      |
      v
Twenty CRM available again
```

## EC2 Stop/Start Test

Before stopping EC2, the following were verified:

- Docker was enabled at boot and active.
- The server used `unless-stopped`.
- The server was `running` and `healthy`.
- The application returned HTTP `200`.

The EC2 instance was stopped and started with AWS CLI:

```bash
aws ec2 stop-instances --region us-east-1 --instance-ids <INSTANCE_ID>
aws ec2 wait instance-stopped --region us-east-1 --instance-ids <INSTANCE_ID>
aws ec2 start-instances --region us-east-1 --instance-ids <INSTANCE_ID>
aws ec2 wait instance-status-ok --region us-east-1 --instance-ids <INSTANCE_ID>
```

The operations have different meanings:

- A reboot restarts the guest operating system.
- A stop/start powers the instance off and starts the same EBS-backed instance
  again; its automatically assigned public IPv4 address can change.
- A terminate operation deletes the instance and normally its root volume. It
  was not used.

The public IPv4 address changed during the verified stop/start test because no
Elastic IP is attached.

## Recovery After EC2 Start

The new public address was retrieved with:

```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --instance-ids <INSTANCE_ID> \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

Post-boot verification returned:

```text
Docker service: active
Restart policy: unless-stopped
Container state: running
Health state: healthy
Health endpoint: HTTP 200
```

Because `SERVER_URL` changed with the public IPv4 address, the enabled
`twenty.service` ran `docker compose up -d` and automatically recreated the
server and worker with the new URL. PostgreSQL and Redis resumed using their
existing containers and persistent volumes.

```text
EC2 stop/start
      |
      v
Amazon Linux boots
      |
      v
systemd starts Docker
      |
      v
Docker loads existing containers
      |
      v
twenty.service refreshes SERVER_URL
      |
      v
Docker Compose starts/reconciles Twenty CRM
      |
      v
Health check becomes healthy
```

## Log Verification

Recent application logs were collected without dumping the full log:

```bash
sudo docker logs --since 5m --tail 50 twenty-server-1
sudo docker logs --since 15m --tail 30 twenty-server-1
```

The recovered server logged:

```text
[NestApplication] Nest application successfully started
```

Current-boot Docker logs were checked with:

```bash
sudo journalctl -u docker -b --no-pager -n 30
```

They showed Docker starting, loading containers, completing initialization,
and exposing its API socket. Timestamps were retained in the evidence.

## Commands Used

Terraform commands were run from `terraform/`:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=task16.tfplan
terraform apply task16.tfplan
terraform output
```

Key EC2 and Docker verification commands:

```bash
sudo systemctl status docker --no-pager
sudo systemctl is-enabled docker
sudo systemctl is-active docker
sudo docker ps
sudo docker inspect twenty-server-1
sudo docker logs --since 5m --tail 50 twenty-server-1
curl -i --max-time 15 http://<EC2_PUBLIC_IP>:2020/healthz
```

SSH uses the private key matching the public key imported by Terraform:

```bash
ssh -i ~/.ssh/chirag-crm-server ec2-user@<EC2_PUBLIC_IP>
```

## Verification Results

| Test | Result |
| --- | --- |
| Terraform validation | Passed |
| Terraform apply | `6 added, 0 changed, 0 destroyed` |
| Amazon Linux 2023 AMI | Verified available, x86_64 |
| Docker enabled at boot | Passed |
| Docker active after EC2 start | Passed |
| Compose services running | Passed |
| Restart policy | `unless-stopped` |
| Health-check command exists | `/usr/bin/curl` |
| Health endpoint | HTTP `200` |
| Unexpected process recovery | Restart count `0` to `1` |
| Post-restart health | `healthy` |
| EC2 stop/start recovery | Passed |
| Browser access after recovery | Passed on TCP `2020` |
| Application startup logs | Passed |

## Evidence to Capture

Capture these screenshots for the pull request:

- `terraform plan` showing only the six Task 16 resources.
- `terraform apply` completion and outputs.
- EC2 console showing `chirag-crm-dev-task16-ec2` in the running state.
- `systemctl status docker` showing `enabled` and `active (running)`.
- `docker ps` before the failure test with healthy services.
- Baseline restart count `0` and health `healthy`.
- The failure command and the automatic recovery result `running 1 healthy`.
- The EC2 transition from running to stopped and then pending/running.
- Docker active after the EC2 start.
- Healthy containers after the EC2 start.
- Browser showing Twenty CRM on port `2020`.
- `/healthz` returning HTTP `200`.
- Short Docker journal and Twenty application log excerpts.

Do not capture private keys, `.env` contents, Terraform state, passwords,
encryption keys, or AWS credentials.

## Troubleshooting

### Terraform validated the wrong directory

Running `terraform validate` from the repository root validated an empty root
configuration. The correct options are:

```bash
cd terraform
terraform validate
```

or:

```bash
terraform -chdir=terraform validate
```

### Leftover ALB references

Removing only the root ALB module left references in user-data, outputs, and
security-group rules. Those references and the active ALB security-group
resources were removed before planning.

### SSH source address changed

The administrator's public IPv4 address changed, so the `/32` SSH rule no
longer matched. The current address was found with:

```bash
curl https://checkip.amazonaws.com
```

`ssh_allowed_cidr` was updated and applied without replacing EC2.

### SSH used a non-matching private key

The downloaded `.pem` file did not match the public key imported by Terraform.
The successful connection used the matching local private key:

```bash
ssh -i ~/.ssh/chirag-crm-server ec2-user@<EC2_PUBLIC_IP>
```

### EC2 console output permission denied

The IAM user did not have `ec2:GetConsoleOutput`. Diagnostics were collected
over SSH from `/var/log/twenty-user-data.log`, Docker, systemd, and the
application instead.

### Explicit Docker kill was recorded as manual

On the tested Docker Engine version, `docker kill` set the daemon's manual-stop
state and suppressed immediate restart. The Docker journal confirmed
`hasBeenManuallyStopped=true`. A host-level SIGKILL of the container's main
process was used to simulate an actual unexpected process failure, after which
the restart count increased and the container returned to `healthy`.

### Public IP changed after EC2 stop/start

No Elastic IP is attached, so the public IPv4 address changed. The current
address was queried through AWS CLI, while the boot service used IMDSv2 to
refresh Twenty's `SERVER_URL` automatically.

## Conclusion

Task 16 successfully deployed Twenty CRM on a Terraform-managed Amazon Linux
2023 EC2 instance using the existing default network. Docker was enabled at
boot, all services used `unless-stopped`, the application had a verified health
check, and automatic recovery was demonstrated after an unexpected container
process failure and an EC2 stop/start cycle. The application returned HTTP
`200` and remained accessible on port `2020` after both recovery tests.
