# Task 16: Twenty CRM Failure & Recovery

## Objective

The objective of this task is to configure and test failure recovery for the Twenty CRM application running on an AWS EC2 instance using Docker. This involves:

1. Running Twenty CRM inside a Docker container on EC2.
2. Configuring the container with a Docker restart policy (`unless-stopped`) so it automatically restarts if it stops unexpectedly.
3. Adding a Docker health check to actively monitor the Twenty CRM application.
4. Manually killing/stopping the container process to verify that Docker automatically restarts it.
5. Stopping and restarting the EC2 instance to verify that Docker and Twenty CRM start automatically upon system boot.
6. Verifying container and application logs to confirm successful recovery.

---

## Environment Details

- **Cloud Provider:** AWS
- **Region:** `us-east-1`
- **Instance ID:** `i-031b3aabd890be8ad`
- **Instance Type:** `t3.small` (2 vCPU, 2GB RAM)
- **Operating System:** Ubuntu 24.04 LTS
- **Security Group:** `mohit-twenty-crm-task16-sg` (`sg-0481c8d5a43c62692`)
  - Inbound Port 22 (SSH)
  - Inbound Port 2020 (Twenty CRM Web Application)
- **Docker Image:** `twentycrm/twenty-app-dev:latest`
- **Port Mapping:** `2020:2020`
- **Restart Policy:** `unless-stopped`
- **Docker Health Check:** `curl -f http://localhost:2020/ || exit 1`
  - Interval: 30 seconds
  - Timeout: 10 seconds
  - Start Period: 120 seconds
  - Retries: 3

---

## 1. System Preparation and Docker Setup

### 1.1 Swap Space Configuration
Because Twenty CRM requires additional memory during startup, database migrations, and route compilation, a 2GB swapfile was configured on the `t3.small` instance:

```bash
sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
```

### 1.2 Docker Installation & Service Enablement
Docker was installed and enabled in systemd so that the Docker daemon automatically starts whenever the EC2 instance boots:

```bash
sudo apt-get update -y
sudo apt-get install -y docker.io curl jq openssl
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

Verification of Docker service enablement:

```bash
systemctl is-enabled docker
# Output: enabled

systemctl is-active docker
# Output: active
```

---

## 2. Running Twenty CRM Container with Restart Policy and Health Check

The Twenty CRM container was deployed with:
- `--restart unless-stopped`: Ensures the container is automatically restarted upon crash or host reboot unless manually stopped.
- `--health-cmd`: Executes an HTTP request to `http://localhost:2020/` every 30 seconds.
- `--health-start-period 120s`: Allows sufficient time for internal database migrations before health checks begin evaluating health status.

```bash
docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL="http://localhost:2020" \
  -e APP_SECRET="twenty-failure-recovery-secret-task16-mohit" \
  -e SIGN_IN_PREFILLED=true \
  --health-cmd="curl -f http://localhost:2020/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-start-period=120s \
  --health-retries=3 \
  twentycrm/twenty-app-dev:latest
```

### Initial Status Verification:

```bash
docker inspect twenty-crm --format 'Name={{.Name}} RestartPolicy={{.HostConfig.RestartPolicy.Name}} Status={{.State.Status}} Health={{.State.Health.Status}}'
```

Output:
```text
Name=/twenty-crm RestartPolicy=unless-stopped Status=running Health=starting
```

Once internal initialization completed:

```bash
docker ps
```

Output:
```text
CONTAINER ID   IMAGE                             COMMAND   CREATED         STATUS                   PORTS                                         NAMES
6f07111d133e   twentycrm/twenty-app-dev:latest   "/init"   9 minutes ago   Up 9 minutes (healthy)   0.0.0.0:2020->2020/tcp, [::]:2020->2020/tcp   twenty-crm
```

Verifying HTTP accessibility:

```bash
curl -I http://localhost:2020/
```

Output:
```text
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 35685
```

---

## 3. Failure & Recovery Test 1: Container Process Crash

To simulate an unexpected process crash (such as a fatal exception, segmentation fault, or out-of-memory termination), the container's main process PID on the host was killed using `SIGKILL`.

### 3.1 Pre-Failure State:
```bash
docker inspect twenty-crm --format "HostPID={{.State.Pid}} Status={{.State.Status}} Health={{.State.Health.Status}} RestartCount={{.RestartCount}}"
```

Output:
```text
HostPID=5627 Status=running Health=healthy RestartCount=0
```

### 3.2 Simulating the Crash:
```bash
sudo kill -9 5627
```

### 3.3 Post-Crash Verification:
Within seconds, the Docker daemon detected the non-zero exit of the process and automatically restarted the container according to the `unless-stopped` restart policy:

```bash
docker inspect twenty-crm --format "Status={{.State.Status}} ExitCode={{.State.ExitCode}} RestartCount={{.RestartCount}} NewPid={{.State.Pid}}"
```

Output:
```text
Status=running ExitCode=0 RestartCount=1 NewPid=5959
```

### 3.4 Second Failure Test:
A second unexpected termination was executed:

```bash
sudo kill -9 5959
docker inspect twenty-crm --format "Status={{.State.Status}} RestartCount={{.RestartCount}} NewPid={{.State.Pid}}"
```

Output:
```text
Status=running RestartCount=2 NewPid=7110
```

### 3.5 Recovery Verification:
After restarting, the container re-initialized and returned to a healthy state:

```bash
docker ps
```

Output:
```text
CONTAINER ID   IMAGE                             COMMAND   CREATED          STATUS                   PORTS                                         NAMES
6f07111d133e   twentycrm/twenty-app-dev:latest   "/init"   17 minutes ago   Up 3 minutes (healthy)   0.0.0.0:2020->2020/tcp, [::]:2020->2020/tcp   twenty-crm
```

Application check:
```bash
curl -I http://localhost:2020/
# Output: HTTP/1.1 200 OK
```

**Result:** Docker successfully detected the unexpected crash and automatically restarted the container. `RestartCount` incremented as expected, and the application recovered without manual intervention.

---

## 4. Failure & Recovery Test 2: EC2 Instance Stop and Restart

To simulate an infrastructure failure, hardware maintenance, or a machine reboot, the EC2 instance was completely stopped and restarted using the AWS CLI.

### 4.1 Stopping the EC2 Instance:
```bash
aws ec2 stop-instances --region us-east-1 --instance-ids i-031b3aabd890be8ad
aws ec2 wait instance-stopped --region us-east-1 --instance-ids i-031b3aabd890be8ad
```

Verification of stopped state:
```bash
aws ec2 describe-instances --region us-east-1 --instance-ids i-031b3aabd890be8ad --query "Reservations[0].Instances[0].[InstanceId,State.Name]" --output table
```

Output:
```text
-------------------------
|   DescribeInstances   |
+-----------------------+
|  i-031b3aabd890be8ad  |
|  stopped              |
+-----------------------+
```

### 4.2 Starting the EC2 Instance:
```bash
aws ec2 start-instances --region us-east-1 --instance-ids i-031b3aabd890be8ad
aws ec2 wait instance-running --region us-east-1 --instance-ids i-031b3aabd890be8ad
```

Verification of running state and assigned IP:
```bash
aws ec2 describe-instances --region us-east-1 --instance-ids i-031b3aabd890be8ad --query "Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]" --output table
```

Output:
```text
-------------------------
|   DescribeInstances   |
+-----------------------+
|  i-031b3aabd890be8ad  |
|  running              |
|  100.61.122.159       |
+-----------------------+
```

### 4.3 Verifying Automatic Container Recovery After Reboot:
Immediately upon reconnecting to the EC2 instance via SSH:

```bash
uptime
# Output: 08:53:55 up 0 min, 1 user, load average: 0.56, 0.14, 0.05

systemctl is-active docker
# Output: active

docker ps -a
```

Output:
```text
CONTAINER ID   IMAGE                             COMMAND   CREATED          STATUS                             PORTS                                         NAMES
6f07111d133e   twentycrm/twenty-app-dev:latest   "/init"   19 minutes ago   Up 24 seconds (health: starting)   0.0.0.0:2020->2020/tcp, [::]:2020->2020/tcp   twenty-crm
```

Checking container start timestamp:
```bash
docker inspect twenty-crm --format "Name={{.Name}} RestartPolicy={{.HostConfig.RestartPolicy.Name}} Status={{.State.Status}} Health={{.State.Health.Status}} StartedAt={{.State.StartedAt}}"
```

Output:
```text
Name=/twenty-crm RestartPolicy=unless-stopped Status=running Health=starting StartedAt=2026-09-16T08:53:31.328509355Z
```

The `StartedAt` timestamp confirms that Docker automatically launched the Twenty CRM container during boot.

### 4.4 Final Health and HTTP Response Verification:
After the application finished initializing internal services:

```bash
docker ps
```

Output:
```text
CONTAINER ID   IMAGE                             COMMAND   CREATED          STATUS                   PORTS                                         NAMES
6f07111d133e   twentycrm/twenty-app-dev:latest   "/init"   23 minutes ago   Up 5 minutes (healthy)   0.0.0.0:2020->2020/tcp, [::]:2020->2020/tcp   twenty-crm
```

Local verification:
```bash
curl -I http://localhost:2020/
```

Output:
```text
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 35685
Date: Wed, 16 Sep 2026 08:58:42 GMT
```

External verification from client machine:
```bash
curl -I http://100.61.122.159:2020/
```

Output:
```text
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 35685
Date: Wed, 16 Sep 2026 08:58:55 GMT
```

---

## 5. Application and Container Logs

During container startup and recovery, the logs were monitored using `docker logs --tail 30 twenty-crm` to confirm clean initialization:

```text
[Nest] 120  - 09/16/2026, 8:54:18 AM  LOG [DatabaseConfigDriver] Config variables loaded: 1 values found in DB, 126 falling to env vars/defaults
[Nest] 120  - 09/16/2026, 8:54:18 AM  LOG [FlushCacheCommand] Cache flushed
==> START Running upgrade
[Nest] 226  - 09/16/2026, 8:54:47 AM  LOG [UpgradeCommand] Initialized upgrade sequence: 339 step(s)
[Nest] 226  - 09/16/2026, 8:54:47 AM  LOG [WorkspaceCommandRunnerService] Upgrade for workspace 20202020-1c25-4d02-bf25-6aeccf7ea419 completed.
==> DONE
s6-rc: info: service init-db successfully started
s6-rc: info: service twenty-server: starting
s6-rc: info: service twenty-server successfully started
s6-rc: info: service twenty-worker: starting
s6-rc: info: service twenty-worker successfully started
[Nest] 494  - 09/16/2026, 8:58:31 AM  LOG [GraphQLModule] Mapped {/metadata, POST} route
[Nest] 494  - 09/16/2026, 8:58:31 AM  LOG [GraphQLModule] Mapped {/admin-panel, POST} route
[Nest] 494  - 09/16/2026, 8:58:31 AM  LOG [GraphQLModule] Mapped {/graphql, POST} route
[Nest] 494  - 09/16/2026, 8:58:31 AM  LOG [NestApplication] Nest application successfully started
```

The logs show:
1. PostgreSQL schema and database connection established.
2. Redis cache successfully flushed.
3. Database upgrade sequence completed.
4. `twenty-server` and `twenty-worker` services started.
5. NestJS application mapped GraphQL and API routes and reported: `Nest application successfully started`.

---

## 6. Verification Checklist

| Task Requirement | Status | Evidence / Verification |
| --- | --- | --- |
| Run Twenty CRM on EC2 with Docker | **Verified** | Container running on EC2 instance `i-031b3aabd890be8ad` |
| Configure Docker restart policy | **Verified** | `--restart unless-stopped` configured and verified via `docker inspect` |
| Add Docker health check | **Verified** | Active health check on port 2020; container reaches `healthy` |
| Manually stop/kill container | **Verified** | Sent `SIGKILL` to container process on host |
| Verify Docker auto-restart | **Verified** | `RestartCount` incremented from 0 to 1 and 2; status remained `running` |
| Stop and restart EC2 instance | **Verified** | Stopped and started using `aws ec2 stop-instances` and `aws ec2 start-instances` |
| Verify Twenty CRM auto-starts after EC2 restart | **Verified** | Systemd started Docker; Docker started `twenty-crm` automatically (`Up 24s`) |
| Check logs for successful recovery | **Verified** | Logs confirmed database, Redis, worker, and NestJS initialization |
| Document failure and recovery process | **Verified** | Complete commands, outputs, and explanations documented in this file |

---

## 7. Conclusion

The Twenty CRM failure recovery configuration was tested and verified for both application-level process crashes and host-level system restarts:
- Docker's `unless-stopped` restart policy successfully detected process termination and restored the container in seconds.
- Enabling Docker in `systemd` ensured that all running containers with `unless-stopped` automatically restarted upon EC2 reboot.
- The Docker health check accurately monitored application readiness, transitioning from `starting` to `healthy` once the web server was accessible and serving HTTP 200 responses.
