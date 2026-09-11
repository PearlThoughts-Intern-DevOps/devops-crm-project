# Task 10 – AWS Observability with Amazon CloudWatch

## Objective

This task deploys Twenty CRM on Amazon EC2 and adds infrastructure monitoring
with Amazon CloudWatch. It covers default EC2 metrics, host-level metrics from
the CloudWatch Agent, a CPU alarm, a dashboard, controlled activity testing, and
troubleshooting.

## Architecture

```text
User Browser
      |
      | HTTP TCP 2020
      v
EC2 Security Group
      |
      v
Amazon EC2: Amazon Linux 2023 / t3.small / 20 GiB gp3
      |
      +-- Docker Compose
      |     +-- Twenty CRM
      |
      +-- Monitoring
            |
            +-- EC2 Default Metrics
            |     +-- CPU Utilization
            |
            +-- Amazon CloudWatch Agent
                  +-- Memory Utilization
                  +-- Disk Utilization
                            |
                            v
                      Amazon CloudWatch
                            |
                            +-- Metrics
                            |     +-- CPU Utilization
                            |     +-- Memory Utilization
                            |     +-- Disk Utilization
                            |
                            +-- Alarm
                            |     +-- CPU Utilization Alarm
                            |
                            +-- Dashboard
                                  +-- CPU Utilization
                                  +-- Memory Utilization
                                  +-- Disk Utilization
```

EC2 supplies the `CPUUtilization` metric used by the alarm and dashboard. The
CloudWatch Agent supplies `mem_used_percent` and `disk_used_percent`. All three
metrics are presented together on the CloudWatch dashboard, while only CPU
utilization has an alarm in this implementation.

## EC2 Configuration

| Setting | Value |
| --- | --- |
| Region | `us-east-1` (US East, N. Virginia) |
| AMI | Amazon Linux 2023 |
| Architecture | 64-bit x86 |
| Instance type | `t3.small` |
| vCPUs | 2 |
| Memory | Approximately 2 GiB |
| Root storage | 20 GiB EBS `gp3` |
| SSH user | `ec2-user` |
| SSH port | TCP `22` |
| Twenty CRM port | TCP `2020` |
| IAM instance profile | `CloudWatchAgentEC2Role` |
| CloudWatch monitoring | Detailed monitoring |

SSH and application access should be restricted to the administrator's public
IP address with a `/32` CIDR. The predefined `CloudWatchAgentEC2Role` must be
attached while launching the instance. No additional IAM user or role is
required unless a real permission error proves that the provided role is
insufficient.

## EC2 User Data and CloudWatch Agent Configuration

The following user data installs and configures the CloudWatch Agent when the
instance starts:

```bash
#!/bin/bash
set -e

dnf update -y
dnf install -y amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}",
      "ImageId": "${aws:ImageId}"
    },
    "aggregation_dimensions": [
      ["InstanceId"]
    ],
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system",
          "cpu_usage_iowait"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

systemctl enable amazon-cloudwatch-agent
```

The configuration publishes measurements every 60 seconds. The important
settings are:

- `append_dimensions` associates the measurements with the instance ID,
  instance type, and AMI.
- `aggregation_dimensions` makes it easy to filter metrics by instance ID.
- `totalcpu` creates measurements for the whole instance rather than a graph
  for every CPU core.
- `mem_used_percent` measures host memory utilization.
- `disk used_percent` measures utilization of the root filesystem.
- `run_as_user: root` allows the agent to inspect system resources.

The default namespace for metrics published by the agent is `CWAgent`.

## Connect to EC2

Protect the SSH key on the local machine:

```bash
chmod 400 ~/Downloads/twenty-task10-key.pem
```

Connect using the Amazon Linux account:

```bash
ssh -i ~/Downloads/twenty-task10-key.pem ec2-user@EC2_PUBLIC_IP
```

Verify the instance:

```bash
cat /etc/os-release
nproc
free -h
df -h /
lsblk
```

## Swap Configuration for `t3.small`

The `t3.small` has approximately 2 GiB RAM. A 4 GiB swap file was added to
provide additional protection against an out-of-memory termination while
Twenty CRM and the monitoring agent were running:

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-twenty-swap.conf
sudo sysctl --system
```

Verify swap without trying to recreate it:

```bash
free -h
swapon --show
grep -n '/swapfile' /etc/fstab
sysctl vm.swappiness
```

Swap is slower than RAM. A larger instance would be preferable for a
long-running production deployment.

## Docker Installation

Install and start Docker on Amazon Linux 2023:

```bash
sudo dnf install -y docker git curl
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
```

Log out and reconnect so that Docker group membership takes effect. Then
verify the installation:

```bash
docker --version
docker info
docker compose version
systemctl is-active docker
```

## Git Branch and Repository

Create the Task 10 branch from the previously working branch and configure the
correct upstream:

```bash
git fetch origin
git switch -c chirag-task-10 origin/chirag-task-5
git push -u origin chirag-task-10
```

On EC2, clone the Task 10 branch:

```bash
cd /home/ec2-user
git clone --branch chirag-task-10 \
  https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

## Twenty CRM Deployment

Docker Compose parses required variables for the complete Compose model even
when only one service is selected. A temporary placeholder permits validation
without starting the unrelated custom application service:

```bash
export TWENTY_API_KEY=not-used-for-task10
docker compose config --quiet twenty
docker compose pull twenty
docker compose up -d twenty
```

Only the `twenty` service is required for this observability task. The
placeholder is not used to authenticate because the `app` service is not
started.

## Application Verification

```bash
docker compose ps
docker ps
docker compose logs --tail=100 twenty
curl -I --max-time 15 http://localhost:2020
free -h
df -h /
docker stats --no-stream
```

Twenty CRM is accessed at:

```text
http://EC2_PUBLIC_IP:2020
```

The observed application logs included successful Redis background saves,
PostgreSQL checkpoints, and completed Twenty scheduled jobs. No fatal errors
were present in the supplied log output.

## Default EC2 Metrics

Default metrics are available at:

```text
AWS Console → CloudWatch → All metrics → AWS/EC2 → Per-Instance Metrics
```

Filter the metrics with the EC2 instance ID.

| Metric | Purpose |
| --- | --- |
| `CPUUtilization` | Percentage of allocated EC2 CPU in use |
| `NetworkIn` | Bytes received by the instance |
| `NetworkOut` | Bytes sent by the instance |
| `DiskReadOps` | Completed instance-store read operations |
| `DiskWriteOps` | Completed instance-store write operations |
| `StatusCheckFailed` | Failed EC2 instance or system health checks |
| `CPUCreditBalance` | Remaining burst credits on the `t3.small` |
| `CPUCreditUsage` | CPU burst credits consumed |

Default EC2 monitoring cannot see guest operating-system memory or mounted
filesystem utilization. The CloudWatch Agent runs inside the operating system
and supplies those measurements.

## CloudWatch Agent Verification

Verify the package, configuration, service, and logs:

```bash
rpm -q amazon-cloudwatch-agent
sudo cat /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo systemctl status amazon-cloudwatch-agent --no-pager
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
sudo tail -n 100 \
  /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

The expected service state is `active (running)`. Agent metrics are found at:

```text
AWS Console → CloudWatch → All metrics → CWAgent
```

Expected metrics include:

| Metric | Meaning |
| --- | --- |
| `cpu_usage_idle` | Percentage of time the CPU is idle |
| `cpu_usage_user` | CPU used by user processes |
| `cpu_usage_system` | CPU used by system processes |
| `cpu_usage_iowait` | CPU time spent waiting for I/O |
| `mem_used_percent` | Percentage of host memory used |
| `disk_used_percent` | Percentage of the root filesystem used |

## CloudWatch Alarm

### CPU utilization alarm

| Setting | Value |
| --- | --- |
| Namespace | `AWS/EC2` |
| Metric | `CPUUtilization` |
| Statistic | Average |
| Period | 5 minutes |
| Threshold | Greater than 70% |
| Evaluation periods | 1 |
| Datapoints to alarm | 1 out of 1 |
| Missing data | Treat missing data as missing |

The default EC2 metric is used for the CPU alarm. A 70% threshold makes the
alarm useful for identifying sustained CPU pressure during the controlled
test. With a five-minute period and `1 out of 1` datapoint, the alarm changes
state when the average CPU utilization for one complete five-minute period is
greater than 70%.

Only the CPU utilization alarm was created for this implementation. Memory
and disk utilization were monitored on the dashboard but did not have alarms.
No SNS notification action was required for this lab.

## CloudWatch Dashboard

The dashboard named `Chirag-TwentyCRM-Observability` contained these three
metrics:

- EC2 `CPUUtilization`
- `CWAgent` `mem_used_percent`
- `CWAgent` `disk_used_percent`

The dashboard combines an AWS infrastructure metric with guest
operating-system metrics in one view. In the captured dashboard, the displayed
values were approximately 2.7% CPU utilization, 82% memory utilization, and
40.5% disk utilization. These values are a point-in-time observation and will
change as the workload changes.

## Controlled Activity and Alarm Testing

First generate normal activity by opening Twenty CRM, navigating between
pages, viewing or creating records, and refreshing the application. Additional
safe HTTP activity can be generated with:

```bash
for i in $(seq 1 100); do
  curl -s -o /dev/null http://localhost:2020
done
```

For a controlled CPU alarm test, verify the CPU count and install `stress-ng`:

```bash
nproc
sudo dnf install -y stress-ng
stress-ng --version
```

Run two CPU workers for seven minutes:

```bash
stress-ng --cpu 2 --timeout 7m --metrics-brief
```

The command ends automatically. Press `Ctrl+C` to stop it early if Twenty
becomes unresponsive. During the test, `CPUUtilization` should increase and the
CPU alarm should enter `ALARM` after enough breaching datapoints. After the
load stops and enough normal datapoints arrive, the alarm should return to
`OK`. Metrics and alarms may take several minutes to update.

Record real before-and-after values and screenshots; do not claim an alarm
transition unless it was observed.

## Issues Faced and Solutions

### Docker and Git commands were not found

The initial verification returned `docker: command not found` and
`git: command not found`. The missing packages were installed and Docker was
started:

```bash
sudo dnf install -y docker git
sudo systemctl enable --now docker
```

### Compose required `TWENTY_API_KEY`

Compose validation failed because the `app` service declared
`TWENTY_API_KEY` as required. Compose interpolated this variable before
selecting the `twenty` service. A temporary placeholder was exported and only
the required service was started:

```bash
export TWENTY_API_KEY=not-used-for-task10
docker compose up -d twenty
```

### Limited memory on `t3.small`

The instance provided approximately 2 GiB RAM. A persistent 4 GiB swap file
was configured, and utilization was checked with `free -h`, `swapon --show`,
and `docker stats --no-stream`.

## How CloudWatch Helps with Monitoring

CloudWatch continuously records the health and performance of the EC2
instance. Default EC2 metrics show CPU, network traffic, health checks, and CPU
credits. The CloudWatch Agent adds memory, filesystem, and detailed host CPU
measurements. A dashboard makes changes and correlations easier to see.

## How CloudWatch Helps with Alerting

The CloudWatch CPU alarm evaluates EC2 CPU utilization against the configured
70% threshold. It can identify sustained compute pressure without requiring an
engineer to continuously watch the dashboard. Production alarms can send
notifications through Amazon SNS or an incident-management service.

## How CloudWatch Helps with Troubleshooting

CloudWatch helps correlate an application symptom with its infrastructure:

- High CPU during a slow CRM response can indicate compute pressure.
- High memory and swap usage can explain poor response time.
- High filesystem usage can indicate excessive logs or container data.
- Increased network traffic confirms that requests reached the server.
- Failed status checks distinguish EC2 health problems from application bugs.
- Missing `CWAgent` metrics can indicate a stopped agent, invalid
  configuration, missing IAM permission, or connectivity problem.

Useful diagnostic commands are:

```bash
docker compose ps
docker compose logs --tail=200 twenty
docker stats --no-stream
free -h
df -h
top
sudo ss -tulpn
sudo systemctl status amazon-cloudwatch-agent
sudo tail -n 100 \
  /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

## Evidence Checklist

Check each item only after capturing and verifying it:

- [ ] EC2 instance details showing Amazon Linux 2023 and `t3.small`
- [ ] IAM role `CloudWatchAgentEC2Role`
- [ ] Security-group rules for TCP 22 and TCP 2020
- [ ] Successful SSH connection
- [ ] 20 GiB storage, memory, and swap verification
- [ ] Docker and Compose installation
- [ ] Twenty container running and healthy
- [ ] Twenty CRM browser page
- [ ] Default `AWS/EC2` metrics
- [ ] CloudWatch Agent configuration and running service
- [ ] `CWAgent` CPU, memory, and disk metrics
- [x] CPU alarm configured at 70%, five minutes, and 1 out of 1
- [x] Dashboard showing CPU, memory, and disk utilization
- [ ] Metrics before and during controlled activity
- [ ] CPU alarm transition to `ALARM` and recovery to `OK`
- [ ] Git branch, commit, push, and pull request
- [ ] EC2 termination confirmation

## Cleanup

Do not terminate the instance until screenshots are saved, documentation is
committed, the branch is pushed, and the pull request is created. After final
verification, terminate it from:

```text
AWS Console → EC2 → Instances → select instance
→ Instance state → Terminate instance
```

## Conclusion

Twenty CRM was deployed on an Amazon Linux 2023 `t3.small` EC2 instance in
`us-east-1` using Docker Compose. Default EC2 metrics provide
infrastructure-level monitoring, while the CloudWatch Agent adds host memory,
filesystem, and detailed CPU visibility. The CPU alarm and three-metric
dashboard make resource pressure easier to detect, visualize, and troubleshoot.

Any unchecked evidence items must be completed and supported with real
screenshots before final submission.
