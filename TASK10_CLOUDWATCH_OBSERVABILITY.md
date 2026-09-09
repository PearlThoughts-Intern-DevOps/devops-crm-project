# Task 10: AWS Observability with CloudWatch

## Objective

Implement observability for the `devops-crm-project` (Twenty CRM) app
running on an EC2 instance using Amazon CloudWatch — default EC2
metrics, a custom CloudWatch Agent for OS-level metrics, alarms, and a
dashboard.

---

## 1. EC2 Instance

| Configuration | Value |
|---|---|
| Instance name | `task10-netaji` |
| Instance type | `t3.small` |
| Operating system | Amazon Linux 2023 |
| Availability Zone | `us-east-1c` |
| Root storage | 20 GiB |
| IAM instance profile | `CloudWatchAgentEC2Role` (pre-created, attached at launch — no new IAM user/role created) |
| Public IPv4 | `54.165.68.139` |
| SSH user | `ec2-user` |

The instance passed all AWS status checks (3/3) and was in the
`Running` state throughout.

---

## 2. Deploying Twenty CRM

Reused the same Docker/Docker Compose setup validated in Task 7
(`devops-crm-project-task7.zip`, which already includes the page-layout
bugfix from that task):

```bash
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
```

Buildx and Compose installed as standalone binaries (AL2023's `dnf`
repos don't include them):

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -fL https://github.com/docker/buildx/releases/download/v0.36.1/buildx-v0.36.1.linux-amd64 -o /usr/local/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Project transferred via `scp` (no git/PAT on the instance, consistent
with the same constraint from Task 7):

```bash
scp -i ~/.ssh/task7-netaji.pem devops-crm-project-task7.zip ec2-user@54.165.68.139:/home/ec2-user/
unzip -q devops-crm-project-task7.zip
cd devops-crm-project
```

Built and started:

```bash
docker-compose pull twenty
docker-compose up -d twenty
docker build -t devops-crm-project-app:latest .
docker-compose up -d
```

Authenticated non-interactively via API key (generated from the Twenty
UI, Settings → MCP & APIs):

```bash
docker-compose exec app yarn twenty remote:add --url http://localhost:2020 --api-key '<API_KEY>'
```

Verified running:

```bash
curl -I http://localhost:2020
# HTTP/1.1 200 OK
```

---

## 3. Default EC2 Metrics (before installing the agent)

Checked EC2 → instance → **Monitoring** tab. Default metrics available
with zero extra setup:

- CPU utilization (%)
- Network in / Network out (bytes)
- Network packets in / out (count)
- CPU credit usage / CPU credit balance (count) — specific to
  burstable `t3` instance types
- Status check failures

**Notably absent by default: memory utilization and disk space usage.**
These require something running *inside* the OS to report them, which
is exactly what the CloudWatch Agent (next section) provides — AWS's
hypervisor-level view has no visibility into what's happening inside
the guest OS's memory/filesystem.

---

## 4. Installing and Configuring the CloudWatch Agent

Installed directly from AL2023's own repo:

```bash
sudo dnf install -y amazon-cloudwatch-agent
```

Configuration (`/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json`),
collecting CPU, memory, and disk utilization as required:

```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  }
}
```

Started the agent with this config:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

Verified it was running:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

After a couple of minutes, confirmed the new `CWAgent` namespace
appeared under CloudWatch → Metrics → All metrics, with `cpu_usage_*`,
`mem_used_percent`, and `used_percent` (disk) all present.

_(Insert screenshot: CWAgent namespace in CloudWatch Metrics)_

---

## 5. CloudWatch Alarms

| Alarm | Metric | Namespace | Threshold |
|---|---|---|---|
| High memory usage | `mem_used_percent` | `CWAgent` | > 70% for 1 datapoint over 1 minute |
| High CPU utilization | `CPUUtilization` | `AWS/EC2` (default) | > 70% for 1 datapoint over 1 minute |

_(Insert screenshot: both alarms listed in CloudWatch → Alarms)_

---

## 6. CloudWatch Dashboard

Created dashboard `netaji-task10-dashboard` with widgets for:

- CPU utilization (`AWS/EC2` namespace)
- Memory used % (`CWAgent` namespace)
- Disk used % (`CWAgent` namespace)

_(Insert screenshot: dashboard overview)_

---

## 7. Generating Load and Verifying Metrics Respond

```bash
sudo dnf install -y stress-ng
stress-ng --cpu 2 --timeout 120s &
stress-ng --vm 1 --vm-bytes 500M --timeout 120s &
for i in {1..50}; do curl -s -o /dev/null http://localhost:2020; done
```

Also interacted with the Twenty CRM UI directly in the browser during
the load test to generate genuine application traffic, not just
synthetic load.

After 1–2 minutes, refreshed the dashboard and alarms:

_(Insert screenshot: dashboard showing the CPU/memory spike from the
load test, and note here whether either alarm actually transitioned to
ALARM state)_

---

## 8. How CloudWatch Supports Monitoring, Alerting, and Troubleshooting

- **Monitoring**: the dashboard gives a single at-a-glance view of
  CPU, memory, and disk over time, without needing an active SSH
  session — something that would have been useful throughout this
  internship's earlier debugging (e.g., checking `free -h` manually
  during Task 5/Task 10's own memory-pressure incident, below).
- **Alerting**: alarms mean a threshold breach is caught proactively
  instead of being discovered only when something visibly breaks.
- **Troubleshooting**: having historical CPU/memory/disk graphs makes
  it possible to correlate *when* something went wrong with *what the
  system was doing* at that time — directly relevant to this task's own
  near-crisis (see below).

---

## 9. Issues Faced and Resolutions

### 9.1 Skipped swap setup caused severe memory pressure and an
unresponsive instance

While moving quickly through setup, the swap-file creation steps were
skipped. Partway through `docker build` (running `yarn install` and a
`chown -R` over `node_modules`), the instance became extremely slow —
multiple SSH sessions hung, and even simple keystrokes were delayed by
several seconds, producing garbled/duplicated input.

**Diagnosis**: `free -h` showed only ~95MB free with 0B swap and 1.6GB
of 1.9GB total RAM in use. This matches classic memory-pressure
thrashing on a `t3.small` (2GB RAM) attempting a Node.js dependency
install + Docker layer export simultaneously.

**Resolution**: rebooted the instance from the AWS Console (status
checks confirmed it was still fundamentally healthy, just starved),
then created the 2GB swap file *before* retrying anything:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

The subsequent `docker build` completed cleanly in ~2 minutes with no
further slowdown, confirming swap was the missing piece.

### 9.2 Multi-line heredoc got corrupted when pasted over SSH

Attempting to write the CloudWatch Agent's JSON config using a
`cat > file << 'EOF' ... EOF` heredoc resulted in the pasted multi-line
content being flattened onto a single line by the terminal, breaking
the heredoc's closing delimiter and leaving the shell waiting
indefinitely (visible as a `>` continuation prompt).

**Resolution**: avoided multi-line heredocs entirely for pasted content
over this SSH connection — instead, generated the JSON as a single
compact line and wrote it with `echo '...' | sudo tee <path>`, which
pastes reliably regardless of terminal line-handling quirks.

### 9.3 `docker-compose build` requiring Docker Buildx (recurring from
Task 7)

Same issue as Task 7 — Amazon Linux's base `docker` package doesn't
include Buildx, and newer `docker-compose` versions require it for
`build`/`up --build`. Resolved the same way: installed Buildx as a
manual CLI plugin, and built the app image directly with
`docker build` rather than relying on Compose's build step.

---

## 10. Cleanup

```bash
docker-compose down -v
```

EC2 instance terminated via AWS Console → Instance State → Terminate,
immediately after capturing the screenshots above, to stay within the
2-hour instance time limit and avoid unnecessary AWS costs.

---

## What I Learned

- Why AWS's default EC2 metrics stop at the hypervisor boundary (CPU,
  network, disk I/O) and can't see inside the guest OS (memory, disk
  space usage) — and that this is precisely the gap the CloudWatch
  Agent exists to fill.
- How to install and configure the CloudWatch Agent to collect custom
  OS-level metrics into a dedicated `CWAgent` namespace.
- How CloudWatch Alarms and Dashboards turn raw metrics into actionable
  signals and a single monitoring view.
- Firsthand, why swap matters on small burstable instances: skipping it
  turned a routine Docker build into a near-unresponsive instance, and
  watching `free -h` and the CPU credit graphs helped diagnose it as a
  resource-exhaustion issue rather than a broken deployment.
- A practical lesson in terminal reliability: multi-line heredocs can
  silently break over certain SSH/paste paths, and collapsing
  multi-line content into a single-line command is a more robust
  pattern when reliability matters more than readability.
