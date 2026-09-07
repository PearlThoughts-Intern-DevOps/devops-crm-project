# Twenty CRM – AWS EC2 CloudWatch Monitoring, Alerting and Traffic Testing

## 1. Objective

The objective of this task is to deploy and verify the Twenty CRM application on an AWS EC2 instance and configure Amazon CloudWatch for monitoring, alerting, dashboard visualization, and troubleshooting.

The implementation includes:

* Twenty CRM running in Docker
* Node.js 24
* Yarn 4
* EC2 default CloudWatch metrics
* CloudWatch Agent
* CPU monitoring
* Memory monitoring
* Disk monitoring
* Swap monitoring
* CloudWatch alarms
* CloudWatch dashboard
* Twenty CRM application activity
* Apache HTTP traffic generation
* Metric verification
* Monitoring and troubleshooting documentation

---

# 2. EC2 Environment

The application is hosted on an AWS EC2 instance.

Basic environment:

* Cloud: AWS EC2
* Operating System: Amazon Linux
* Application: Twenty CRM
* Application Port: 2020
* Container Runtime: Docker
* Node.js: 24.x
* Package Manager: Yarn 4.x
* Monitoring: Amazon CloudWatch
* Monitoring Agent: Amazon CloudWatch Agent

---

# 3. Connect to EC2

From Windows CMD:

```cmd
cd C:\Users\Rohith\Downloads
```

Connect using the EC2 private key:

```cmd
ssh -i rohtask.pem ec2-user@YOUR-EC2-PUBLIC-IP
```

Verify the user:

```bash
whoami
```

---

# 4. Update the EC2 Instance

```bash
sudo dnf update -y
```

---

# 5. Install Docker

```bash
sudo dnf install -y docker
```

Start and enable Docker:

```bash
sudo systemctl enable --now docker
```

Add the EC2 user to the Docker group:

```bash
sudo usermod -aG docker ec2-user
```

Apply the group change:

```bash
newgrp docker
```

Verify:

```bash
docker --version
```

```bash
docker ps
```

---

# 6. Install Node.js 24

Remove an existing Node.js version if necessary:

```bash
sudo dnf remove -y nodejs
```

Configure NodeSource for Node.js 24:

```bash
curl -fsSL https://rpm.nodesource.com/setup_24.x | sudo bash -
```

Install Node.js:

```bash
sudo dnf install -y nodejs
```

Verify:

```bash
node -v
```

```bash
npm -v
```

The Node.js version should be 24.x.

---

# 7. Install and Enable Corepack/Yarn

Install Corepack:

```bash
sudo npm install -g corepack
```

Enable Corepack:

```bash
sudo corepack enable
```

Verify:

```bash
yarn -v
```

If required, activate Yarn 4:

```bash
corepack prepare yarn@4.9.2 --activate
```

Verify again:

```bash
yarn -v
```

The expected Yarn version should be 4.x.

---

# 8. Clone the DevOps Project

Move to the home directory:

```bash
cd /home/ec2-user
```

Clone the repository:

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
```

Enter the repository:

```bash
cd /home/ec2-user/devops-crm-project
```

Verify:

```bash
ls
```

---

# 9. Run Twenty CRM

Navigate to the Twenty Docker directory if applicable:

```bash
cd packages/twenty-docker
```

Start Twenty CRM using the project's configured command:

```bash
yarn twenty docker:start
```

Verify the Docker container:

```bash
docker ps
```

The Twenty CRM container should be in a running state and expose port 2020.

Test locally:

```bash
curl -I http://localhost:2020
```

Twenty CRM can then be accessed from a browser using:

```text
http://YOUR-EC2-PUBLIC-IP:2020
```

---

# 10. Create a Swap File

Check whether swap already exists:

```bash
free -h
```

```bash
swapon --show
```

If no swap is available, create a 2 GB swap file:

```bash
sudo fallocate -l 2G /swapfile
```

Set secure permissions:

```bash
sudo chmod 600 /swapfile
```

Initialize the file as swap:

```bash
sudo mkswap /swapfile
```

Enable it:

```bash
sudo swapon /swapfile
```

Verify:

```bash
swapon --show
```

```bash
free -h
```

Make the swap file persistent:

```bash
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

Verify:

```bash
grep swapfile /etc/fstab
```

Expected result:

```text
/swapfile swap swap defaults 0 0
```

---

# 11. Check EC2 Resource Usage

CPU:

```bash
top
```

Memory:

```bash
free -h
```

Disk:

```bash
df -h /
```

Swap:

```bash
swapon --show
```

All resources together:

```bash
echo "===== CPU ====="
top -bn1 | grep "%Cpu"

echo "===== MEMORY ====="
free -h

echo "===== DISK ====="
df -h /

echo "===== SWAP ====="
swapon --show
```

---

# 12. Install CloudWatch Agent

Download the CloudWatch Agent:

```bash
cd /tmp
```

```bash
wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
```

Install it:

```bash
sudo rpm -U ./amazon-cloudwatch-agent.rpm
```

Verify:

```bash
rpm -qa | grep amazon-cloudwatch-agent
```

---

# 13. CloudWatch Agent Configuration

The CloudWatch Agent will collect CPU, memory, disk, and swap metrics.

The custom CloudWatch namespace is:

```text
twentyrohithcrm
```

Create the configuration file:

```bash
sudo nano /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

Use:

```json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "twentyrohithcrm",
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "totalcpu": true,
        "metrics_collection_interval": 60
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
        "resources": [
          "/"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
```

Save the file:

```text
Ctrl + O
Enter
Ctrl + X
```

---

# 14. Start the CloudWatch Agent

Apply the configuration:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s
```

Check the agent status:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

Expected:

```text
"status": "running"
"configstatus": "configured"
```

Check the CloudWatch Agent logs:

```bash
sudo tail -30 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

---

# 15. Verify CloudWatch Agent Metrics

Wait approximately 2–5 minutes after starting the agent.

Open:

**AWS Console → CloudWatch → Metrics → All metrics**

Navigate to:

**Custom namespaces → twentyrohithcrm**

Select the EC2 instance.

The following metrics should be available:

```text
cpu_usage_idle
cpu_usage_user
cpu_usage_system
mem_used_percent
used_percent
swap_used_percent
```

Metric meaning:

| Metric              | Purpose                      |
| ------------------- | ---------------------------- |
| `cpu_usage_idle`    | CPU idle percentage          |
| `cpu_usage_user`    | CPU used by user processes   |
| `cpu_usage_system`  | CPU used by system processes |
| `mem_used_percent`  | Memory utilization           |
| `used_percent`      | Disk utilization             |
| `swap_used_percent` | Swap utilization             |

---

# 16. Default EC2 CloudWatch Metrics

EC2 automatically provides several metrics without the CloudWatch Agent.

Examples include:

```text
CPUUtilization
NetworkIn
NetworkOut
NetworkPacketsIn
NetworkPacketsOut
EBSReadBytes
EBSWriteBytes
EBSReadOps
EBSWriteOps
StatusCheckFailed
```

The important distinction is that **memory utilization is not one of the standard EC2 metrics**.

Memory is collected using:

```text
mem_used_percent
```

from the CloudWatch Agent.

---

# 17. Create CloudWatch Dashboard

Open:

**CloudWatch → Dashboards → Create dashboard**

Create a dashboard named:

```text
Rohith-TwentyCRM-EC2
```

Add the following widgets:

### CPU

```text
CPUUtilization
```

### Memory

```text
mem_used_percent
```

### Disk

```text
used_percent
```

### Swap

```text
swap_used_percent
```

### Network

```text
NetworkIn
NetworkOut
```

The final dashboard provides a centralized view of:

```text
CPU
Memory
Disk
Swap
Network
```

Save the dashboard.

---

# 18. Create CloudWatch CPU Alarm

Go to:

**CloudWatch → Alarms → Create alarm**

Select:

**EC2 → Per-Instance Metrics → CPUUtilization**

Configure:

```text
Statistic: Average
Period: 5 minutes
Condition: Greater than 70%
```

Alarm name:

```text
Rohith-TwentyCRM-High-CPU
```

Purpose:

To detect high CPU utilization on the EC2 instance.

---

# 19. Create CloudWatch Memory Alarm

Create another CloudWatch alarm.

Select:

**Custom namespaces → twentyrohithcrm → mem_used_percent**

Configure:

```text
Statistic: Average
Period: 5 minutes
Condition: Greater than 80%
```

Alarm name:

```text
Rohith-TwentyCRM-High-Memory
```

Purpose:

To detect high memory utilization on the EC2 instance.

---

# 20. Access Twenty CRM and Generate Activity

Open Twenty CRM:

```text
http://YOUR-EC2-PUBLIC-IP:2020
```

Generate application activity by:

* Creating a company
* Creating contacts
* Creating an opportunity
* Searching records
* Updating records
* Navigating through the CRM
* Performing normal CRM operations

Verify the container:

```bash
docker ps
```

Check container resource usage:

```bash
docker stats
```

---

# 21. Generate Apache Traffic

Apache can be used to generate HTTP traffic for server activity testing.

Install ApacheBench:

```bash
sudo dnf install -y httpd-tools
```

Verify:

```bash
ab -V
```

ApacheBench can then send requests to the Apache HTTP server.

For example:

```bash
ab -n 10000 -c 50 http://localhost/
```

For a larger traffic test:

```bash
ab -n 50000 -c 100 http://localhost/
```

Where:

* `-n 50000` means 50,000 total requests.
* `-c 100` means 100 concurrent requests.

This generates a burst of HTTP traffic.

Apache request activity can be observed using:

```bash
sudo tail -f /var/log/httpd/access_log
```

---

# 22. Generate Controlled CPU Load

Apache traffic may increase network activity but may not generate enough CPU utilization to trigger a CPU alarm.

For controlled CPU testing, temporarily run:

```bash
yes > /dev/null &
```

Monitor CPU:

```bash
top
```

After testing, stop the process:

```bash
pkill yes
```

The CPU utilization should return toward its normal level after the load is stopped.

The `yes` process should not be left running after the test.

---

# 23. Verify CloudWatch Metric Changes

Open:

**CloudWatch → Dashboards → Rohith-TwentyCRM-EC2**

Set the dashboard time range to:

```text
Last 15 minutes
```

Observe the metrics before, during, and after activity.

Expected behavior:

```text
Normal workload
      ↓
Twenty CRM / HTTP activity
      ↓
Resource utilization changes
      ↓
CloudWatch Agent collects metrics
      ↓
Dashboard updates
```

CPU can be observed through:

```text
CPUUtilization
```

Memory:

```text
mem_used_percent
```

Disk:

```text
used_percent
```

Swap:

```text
swap_used_percent
```

Network:

```text
NetworkIn
NetworkOut
```

---

# 24. Verify CloudWatch Alarms

Open:

**CloudWatch → Alarms → All alarms**

Verify:

```text
Rohith-TwentyCRM-High-CPU
Rohith-TwentyCRM-High-Memory
```

Normally the alarms should initially show:

```text
OK
```

If the CPU metric remains above the configured threshold for the required evaluation period:

```text
OK → ALARM
```

After CPU utilization returns below the threshold and remains there for the required evaluation periods:

```text
ALARM → OK
```

This demonstrates that CloudWatch alarms can identify abnormal resource utilization.

---

# 25. Monitoring

CloudWatch provides centralized monitoring of the EC2 instance and Twenty CRM environment.

The default EC2 metrics provide information such as:

* CPU utilization
* Network traffic
* EBS activity
* Instance status

The CloudWatch Agent provides operating-system-level metrics such as:

* Memory utilization
* Disk utilization
* Swap utilization
* Additional CPU metrics

The CloudWatch dashboard provides a single location from which these metrics can be viewed.

---

# 26. Alerting

CloudWatch alarms continuously evaluate configured metrics against defined thresholds.

The CPU alarm monitors:

```text
CPUUtilization > 70%
```

The memory alarm monitors:

```text
mem_used_percent > 80%
```

When a metric remains above the threshold for the configured evaluation period, the alarm can change from `OK` to `ALARM`.

CloudWatch alarms can also be integrated with Amazon SNS when notification delivery is required.

---

# 27. Troubleshooting

CloudWatch can help identify performance problems on the Twenty CRM EC2 server.

### High CPU

A high CPU metric can indicate:

* High application workload
* CPU-intensive processes
* Increased server traffic
* Resource-intensive Docker workloads

Useful commands:

```bash
top
```

```bash
docker stats
```

### High Memory

A high memory metric can indicate:

* Memory-intensive processes
* Increased application workload
* Insufficient available memory
* Increased swap usage

Useful commands:

```bash
free -h
```

```bash
swapon --show
```

### High Disk Usage

A high disk metric can indicate:

* Large log files
* Docker storage growth
* Application data growth
* Insufficient disk capacity

Useful command:

```bash
df -h /
```

### High Swap Usage

High swap usage can indicate memory pressure.

Check:

```bash
free -h
```

```bash
swapon --show
```

### Docker Problems

Check running containers:

```bash
docker ps
```

Check resource consumption:

```bash
docker stats
```

### CloudWatch Agent Problems

Check status:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

Check logs:

```bash
sudo tail -30 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

---

# 28. Screenshots / Evidence

The following screenshots should be captured for the task:

1. EC2 instance running
2. Twenty CRM application running
3. `docker ps`
4. CloudWatch Agent installation
5. CloudWatch Agent status showing running/configured
6. `twentyrohithcrm` CloudWatch namespace
7. CPU metrics
8. Memory metric
9. Disk metric
10. Swap metric
11. CloudWatch dashboard
12. CPU alarm
13. Memory alarm
14. Twenty CRM activity
15. Docker resource usage
16. Apache traffic generation
17. Changed CloudWatch metrics during activity/load
18. Alarm state change, if successfully triggered

---

# 29. Final Result

The Twenty CRM application was deployed and monitored on an AWS EC2 instance.

Amazon CloudWatch was configured using both default EC2 metrics and the CloudWatch Agent.

The CloudWatch Agent collected:

* CPU
* Memory
* Disk
* Swap

A dedicated dashboard named:

```text
Rohith-TwentyCRM-EC2
```

was created to provide centralized monitoring.

Two CloudWatch alarms were configured:

```text
Rohith-TwentyCRM-High-CPU
Rohith-TwentyCRM-High-Memory
```

Twenty CRM activity and server traffic were generated to verify changes in resource utilization.

CloudWatch was used to observe metric changes, evaluate alarm conditions, and provide information useful for troubleshooting.

The implementation demonstrates how CloudWatch can be used for:

* Monitoring
* Visualization
* Alerting
* Performance analysis
* Resource troubleshooting
* Operational visibility
