# Task 10 — AWS Observability with CloudWatch

**Branch:** `sakhisurakhya/task-10`

**Instance:** `devops-crm-task10` (Ubuntu, `t3.small`, 20 GiB storage) — launched and terminated within the 2-hour window

**Public IP (while active):** `52.91.4.185`

## 1. Overview

This task adds **CloudWatch monitoring** to Twenty CRM running on EC2.

The CloudWatch Agent collects system metrics such as CPU, memory, disk, and swap usage. I also created alarms and a dashboard to monitor the instance.

## 2. EC2 Setup

* **AMI:** Ubuntu Server
* **Instance type:** `t3.small` (2 vCPU, 2GB RAM)
* **Storage:** 20 GiB
* **IAM Role:** `CloudWatchAgentEC2Role` — allows the EC2 instance to send metrics to CloudWatch
* **Security group:** SSH (22) and Custom TCP (2020), both from Anywhere
* **Key pair:** Reused the existing key pair from Task 7

## 3. Deploying Twenty CRM

I connected to the EC2 instance using SSH and installed Docker, Node.js, and the Twenty CLI.

I also added a 2 GB swap file because Twenty CRM can use a lot of memory during startup.

```bash
ssh -i <key>.pem ubuntu@52.91.4.185

sudo apt update

sudo apt install -y docker.io docker-compose-v2

sudo systemctl start docker

sudo systemctl enable docker

sudo usermod -aG docker $USER

newgrp docker

curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -

sudo apt install -y nodejs

sudo corepack enable

sudo npm install -g twenty-sdk

sudo fallocate -l 2G /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

twenty docker:start
```

### 3.1 Verifying Twenty CRM

`twenty docker:start` showed "Failed" at the final "Registering cron jobs" step because of a health-check timeout.

However, Twenty CRM was actually running correctly.

```bash
sudo docker ps -a

twenty docker:status

curl -I http://localhost:2020
```

The response was:

```text
HTTP/1.1 200 OK
```

I also opened Twenty CRM in the browser and confirmed that it was working correctly with the seeded CRM data.

## 4. Exploring Default EC2 Metrics in CloudWatch

CloudWatch automatically provides some basic EC2 metrics without installing an agent.

These include:

* `CPUUtilization`
* `NetworkIn` / `NetworkOut`
* `DiskReadOps` / `DiskWriteOps`
* `StatusCheckFailed`

However, default EC2 metrics do not show memory usage or disk space usage inside the operating system.

The CloudWatch Agent is required to collect these additional metrics.

## 5. Installing and Configuring the CloudWatch Agent

### 5.1 Install

I downloaded and installed the CloudWatch Agent.

```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

sudo dpkg -i amazon-cloudwatch-agent.deb
```

### 5.2 Configuration

I created:

`/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json`

The configuration collects CPU, memory, disk, and swap metrics.

The custom namespace used was:

`TwentyCRM/EC2`

The instance ID was also added as a dimension.

### 5.3 Start with config

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

Result:

`Configuration validation succeeded`

### 5.4 Verify running

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

Result:

```json
{
  "status": "running",
  "configstatus": "configured",
  "version": "1.300072.0b1766"
}
```

This confirmed that the CloudWatch Agent was running correctly.

## 6. Verifying Custom Metrics in CloudWatch

I opened **CloudWatch → Metrics → Custom namespaces**.

The `TwentyCRM/EC2` namespace appeared with **8 metrics**.

These included:

* `mem_used_percent`
* `mem_available_percent`
* `swap_used_percent`
* `cpu_usage_idle`
* `cpu_usage_user`
* `cpu_usage_system`
* `used_percent`
* `free`

These metrics were not available in the default EC2 metrics.

This confirmed that the CloudWatch Agent and IAM role were working correctly.

`Screenshots: screenshots/06-custom-namespace-metrics.png, screenshots/07-cpu-metrics-graph.png`

## 7. CloudWatch Alarms

### Alarm 1 — High Memory Usage

* **Name:** `sakhisurakhya-high-memory-alarm`
* **Metric:** `mem_used_percent`
* **Namespace:** `TwentyCRM/EC2`
* **Condition:** Greater than **85%** for 1 datapoint within 5 minutes

This alarm helps detect high memory usage before the application has problems.

### Alarm 2 — High Disk Usage

* **Name:** `sakhisurakhya-high-disk-alarm`
* **Metric:** `used_percent`
* **Namespace:** `TwentyCRM/EC2`
* **Resource:** `/`
* **Condition:** Greater than **89%**

This alarm helps detect when the disk is almost full.

Both alarms were created without SNS notifications because notifications were not required for this task.

`Screenshots: screenshots/08-alarms-created.png`

## 8. CloudWatch Dashboard

Created a dashboard:

`sakhisurakhya-twenty-crm-dashboard`

It contains two widgets:

1. **Custom Agent Metrics** — Shows memory, CPU, and disk metrics from `TwentyCRM/EC2`.

2. **Default EC2 Metrics** — Shows CPU and network metrics from `AWS/EC2`.

This dashboard shows the difference between default EC2 metrics and the additional metrics collected by the CloudWatch Agent.

`Screenshots: screenshots/09-full-dashboard.png`

## 9. Generating Activity and Observing Metric Changes

I generated real activity in Twenty CRM.

The activity included:

* Opening Companies, People, and Opportunities
* Opening company details
* Creating 3 test companies

The company count increased from **599 → 602**.

### Observed result on the dashboard

* `mem_used_percent` increased from around **57% to 75%**.
* `cpu_usage_user` increased during the period when I created the test companies.
* `disk_used_percent` stayed almost the same.

This showed that the CloudWatch metrics were responding to real application activity.

`Screenshots: screenshots/10-metrics-before-activity.png, screenshots/11-metrics-after-activity.png`

## 10. How CloudWatch Helps with Monitoring, Alerting, and Troubleshooting

* **Monitoring:** CloudWatch provides a dashboard to continuously monitor CPU, memory, and disk usage.

* **Alerting:** The alarms can detect high memory or disk usage before the application fails.

* **Troubleshooting:** CloudWatch keeps metric history, so it is easier to check what happened before an issue occurred.

This would make problems like the memory and disk issues from previous tasks easier to identify.

## 11. Issues Faced & Solutions

### Issue 1 — Accidentally ran a Linux command in Windows PowerShell

**Problem:** After an SSH disconnect, I accidentally ran the Linux `wget` command in Windows PowerShell.

**Solution:** I cancelled the command, connected to the EC2 instance again, and ran the command on Ubuntu.

### Issue 2 — "Create alarm" button initially unclickable

**Problem:** The CloudWatch "Create alarm" button was disabled when multiple metrics were selected.

**Solution:** I selected only one metric, and the button became active.

## 12. Cleanup

```bash
twenty docker:stop
```

After completing the testing and taking the screenshots, I terminated the EC2 instance from the AWS Console.

The CloudWatch dashboard and alarms remain available even after the EC2 instance was terminated.

## 14. Status

* Launched EC2 instance with `CloudWatchAgentEC2Role` attached
* Connected via SSH
* Deployed and verified Twenty CRM
* Checked default EC2 metrics
* Installed and configured CloudWatch Agent
* Collected CPU, memory, disk, and swap metrics
* Verified 8 custom metrics in `TwentyCRM/EC2`
* Created 2 CloudWatch Alarms
* Created CloudWatch Dashboard
* Generated real application activity
* Observed metric changes
* Documented monitoring, alerting, and troubleshooting
* Terminated EC2 instance within the 2-hour window
* Screenshots captured
* Loom video completed
* Branch, push, and PR completed
