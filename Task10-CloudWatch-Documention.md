# Task 10: AWS Observability with CloudWatch — Twenty CRM on EC2

## Overview
Implemented monitoring for a Twenty CRM instance running on EC2 using Amazon CloudWatch — explored default EC2 metrics, installed and configured the CloudWatch Agent for system-level metrics (CPU, memory, disk), created alarms, built a dashboard, and verified everything with live load testing.

## 1. EC2 Instance Setup
- AMI: **Ubuntu** (not Amazon Linux — confirmed via `cat /etc/os-release` after `dnf` was not found)
- Instance type: t2/t3.micro
- Instance ID: `i-019ed83338e3971af`
- Region: `us-east-1`
- Default user: `ubuntu` (not `ec2-user`, since this is Ubuntu)
- Security group rules: SSH (22), and the ports needed for Twenty CRM access
- IAM role attached: `EC2-CloudWatch-Agent-Role`, with policies:
  - `CloudWatchAgentServerPolicy` (lets the agent push metrics)
  - `CloudWatchReadOnlyAccess` (added later, to allow `list-metrics` calls from the instance)
  - `CloudWatchFullAccess` (added later still, to allow creating alarms and dashboards from the instance via CLI)

## 2. Connecting & Deploying Twenty CRM
```bash
ssh -i your-key.pem ubuntu@<PUBLIC_IP>
```

This repo (`devops-crm-project`) is a **twenty-sdk app scaffold**, not a plain Docker Compose project — there is no `docker-compose.yml` in it. Deployment uses Twenty's own CLI-driven Docker workflow.

Installed prerequisites on a fresh Ubuntu instance:
```bash
sudo apt update -y
sudo apt install -y docker.io git tmux
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
# log out/in for group membership to apply
sudo apt install -y docker-compose   # resolved to docker-compose-v2 on this Ubuntu release

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 24.5.0
nvm use 24.5.0

corepack enable
corepack prepare yarn@4.13.0 --activate
```

Cloned and ran the app:
```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
yarn install
yarn twenty docker:start
yarn twenty docker:status
```

Ran the dev/sync server inside `tmux` (so it survives disconnects) and served on **port 2020**:
```bash
tmux new -s twenty
yarn twenty dev
```

Because `yarn twenty dev` prints a `localhost:2020/authorize?...` URL, and "localhost" refers to the EC2 instance itself (not the local laptop), an **SSH tunnel** was required to authenticate from a local browser:
```bash
ssh -i your-key.pem -N -L 2020:localhost:2020 -L <callback_port>:localhost:<callback_port> ubuntu@<PUBLIC_IP>
```
(The callback port is randomized per run and must match exactly what's shown in the printed URL.)

## 3. Verify Twenty CRM Running
```bash
docker ps
curl -I http://localhost:2020
```
Confirmed working by logging into the app at `http://localhost:2020` (via the tunnel) and browsing the default seeded data (Companies, People, Opportunities, etc.).
Screenshot: Twenty CRM Companies list loaded successfully in browser.

## 4. Explore Default EC2 Metrics
Console path: **CloudWatch → Metrics → Classic metrics → AWS/EC2 → Per-Instance Metrics**.
Default metrics available out of the box (23 total for this instance): `CPUUtilization`, `NetworkIn`/`NetworkOut`, `DiskReadOps`/`DiskWriteOps`, `StatusCheckFailed`, `InstanceEBSIOPSExceededCheck`, `InstanceEBSThroughputExceededCheck`, `EBSIOBalance%`, etc.
**Key gap confirmed:** no memory or disk-usage-*percentage* metrics by default — this is exactly why the CloudWatch Agent is needed.
Screenshot: default metrics browse table for the instance.

## 5. CloudWatch Agent Installation & Configuration
Ubuntu uses a `.deb` package rather than `dnf`:
```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

Configured a custom namespace `Twenty-CRM-EC2` collecting CPU, memory, and disk:
```bash
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/config.json > /dev/null << 'EOF'
{
  "metrics": {
    "namespace": "Twenty-CRM-EC2",
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
EOF
```
A copy of this config is committed at `cloudwatch-config/config.json` in this repo branch.

Started and verified:
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```
Result: `"status": "running"`, `"configstatus": "configured"`.

## 6. Verify Custom Metrics in CloudWatch
Confirmed via CLI (after granting read permissions — see Issues section):
```bash
aws cloudwatch list-metrics --namespace Twenty-CRM-EC2 --region us-east-1
```
Returned `mem_used_percent` and `disk_used_percent` metrics, dimensioned by **`host` = `ip-172-31-21-200`** (note: the agent's custom metrics use a `host` dimension, not `InstanceId` — that dimension only applies to default `AWS/EC2` namespace metrics).

## 7. Alarms Created
| Alarm Name | Namespace | Metric | Dimension | Threshold | Evaluation |
|---|---|---|---|---|---|
| TwentyCRM-HighCPU | AWS/EC2 | CPUUtilization | InstanceId | > 70% | 2 x 60s periods |
| TwentyCRM-HighMemory | Twenty-CRM-EC2 | mem_used_percent | host | > 80% | 2 x 60s periods |

```bash
aws cloudwatch put-metric-alarm --alarm-name "TwentyCRM-HighCPU" --namespace "AWS/EC2" --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-019ed83338e3971af --statistic Average --period 60 --threshold 70 --comparison-operator GreaterThanThreshold --evaluation-periods 2 --alarm-description "Alarm when CPU exceeds 70%" --region us-east-1

aws cloudwatch put-metric-alarm --alarm-name "TwentyCRM-HighMemory" --namespace "Twenty-CRM-EC2" --metric-name mem_used_percent --dimensions Name=host,Value=ip-172-31-21-200 --statistic Average --period 60 --threshold 80 --comparison-operator GreaterThanThreshold --evaluation-periods 2 --alarm-description "Alarm when memory exceeds 80%" --region us-east-1
```
Verified with `aws cloudwatch describe-alarms --alarm-names "TwentyCRM-HighCPU" "TwentyCRM-HighMemory" --region us-east-1`.

## 8. Dashboard
Created `Vikash-Task10-Dashboard` with three widgets (CPU, Memory, Disk):
```bash
aws cloudwatch put-dashboard --dashboard-name "Vikash-Task10-Dashboard" --dashboard-body '{
  "widgets": [
    {"type":"metric","x":0,"y":0,"width":12,"height":6,
     "properties":{"metrics":[["AWS/EC2","CPUUtilization","InstanceId","i-019ed83338e3971af"]],
     "period":60,"stat":"Average","region":"us-east-1","title":"CPU Utilization"}},
    {"type":"metric","x":12,"y":0,"width":12,"height":6,
     "properties":{"metrics":[["Twenty-CRM-EC2","mem_used_percent","host","ip-172-31-21-200"]],
     "period":60,"stat":"Average","region":"us-east-1","title":"Memory Utilization"}},
    {"type":"metric","x":0,"y":6,"width":12,"height":6,
     "properties":{"metrics":[["Twenty-CRM-EC2","disk_used_percent","path","/","host","ip-172-31-21-200"]],
     "period":60,"stat":"Average","region":"us-east-1","title":"Disk Utilization"}}
  ]
}' --region us-east-1
```
Verified with `aws cloudwatch list-dashboards --region us-east-1`.

## 9. Load Testing / Verification
Used Twenty CRM in the browser (navigated Companies/People views) and generated synthetic load with `stress-ng`:
```bash
sudo apt install -y stress-ng
stress-ng --cpu 2 --timeout 180s
stress-ng --vm 1 --vm-bytes 512M --timeout 180s
```

**Observed:**
- CPU graph rose sharply during the stress test (baseline ~1% → peak ~46-92% depending on run)
- `TwentyCRM-HighCPU` alarm transitioned **OK → ALARM** (`"In alarm"`) during the sustained spike
- Alarm returned to **OK** within a few minutes after the stress process ended
- Dashboard widgets reflected the same rise and recovery in near real time (~1 minute lag)

Screenshots captured: baseline metrics, alarm in "In alarm" state, alarm back to "OK", dashboard with all three widgets populated.

## 10. How CloudWatch Helps with Monitoring, Alerting, and Troubleshooting
- **Monitoring:** the dashboard gives a real-time, at-a-glance view of instance health (CPU/memory/disk) without needing to SSH in and run `top`/`df` manually.
- **Alerting:** alarms notify — or can trigger automated actions — the moment a threshold is breached, enabling a proactive response before the application degrades or the instance runs out of resources.
- **Troubleshooting:** historical metric data lets you correlate application-level symptoms (e.g., Twenty CRM feeling slow) with resource exhaustion (e.g., a memory or CPU spike at the same timestamp), narrowing down root cause far faster than guesswork.

## 11. Issues Faced & Solutions
| Issue | Cause | Solution |
|---|---|---|
| `sudo: dnf: command not found` | Instance was actually Ubuntu, not Amazon Linux as assumed | Switched to `apt`, `.deb` package for CloudWatch Agent, `ubuntu` user instead of `ec2-user` |
| `docker-compose-plugin` not found via apt | Not available in this Ubuntu release's default repos | Installed `docker-compose`, which resolved to `docker-compose-v2` — provides the same `docker compose` subcommand syntax |
| No `docker-compose.yml` in repo | Repo is a `twenty-sdk` app scaffold, not a plain containerized app | Used `yarn twenty docker:start` / `yarn twenty dev` instead, per SETUP.md |
| `localhost:2020/authorize` URL refused to connect in local browser | "localhost" in the CLI output refers to the EC2 instance, not the local machine | Opened an SSH tunnel (`-L 2020:localhost:2020 -L <callback_port>:localhost:<callback_port>`) and used the tunnel to reach the auth URL locally |
| `aws cloudwatch list-metrics` → AccessDenied | `CloudWatchAgentServerPolicy` only grants push (`PutMetricData`), not read/list permissions | Attached `CloudWatchReadOnlyAccess` to the instance role |
| `aws cloudwatch put-metric-alarm` → AccessDenied | Role still lacked alarm/dashboard write permissions | Attached `CloudWatchFullAccess` to the instance role |
| `badly formed help string` on `put-metric-alarm` | The pre-installed AWS CLI (v1, from Ubuntu's apt repo) had a bug parsing the multi-line command | Removed it and installed AWS CLI v2 from the official installer (`awscli-exe-linux-x86_64.zip`) |
| `aws: command not found` right after installing CLI v2 | Shell had cached the old `/usr/bin/aws` path | Ran `hash -r` to refresh the shell's command path cache |
| Custom agent metrics dimensioned by `host`, not `InstanceId` | The CloudWatch Agent's own metrics use the instance's hostname as the dimension by default, unlike native `AWS/EC2` metrics | Used `Name=host,Value=<hostname>` for alarms/dashboard widgets referencing the custom `Twenty-CRM-EC2` namespace |

## 12. Cleanup
Instance terminated after all testing and screenshots were captured:
```bash
aws ec2 terminate-instances --instance-ids i-019ed83338e3971af
```