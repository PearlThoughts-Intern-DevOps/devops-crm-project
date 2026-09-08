# Task 10: AWS CloudWatch Observability for Twenty CRM

## 1. Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance and configure Amazon CloudWatch for server monitoring, metrics collection, alerting, and troubleshooting.

The implementation included:

* Launching and connecting to an EC2 instance.
* Deploying and running Twenty CRM.
* Exploring default EC2 CloudWatch metrics.
* Installing and configuring the CloudWatch Agent.
* Collecting CPU, memory, and disk utilization metrics.
* Creating CloudWatch alarms.
* Creating a CloudWatch dashboard.
* Generating application/server activity.
* Verifying monitoring and alerting behavior.
* Documenting issues and solutions.

---

## 2. AWS Environment

| Configuration            | Details                        |
| ------------------------ | ------------------------------ |
| AWS Region               | `us-east-1`                    |
| EC2 Instance ID          | `i-05c1316461a2f5586`          |
| EC2 Hostname             | `ip-172-31-8-121.ec2.internal` |
| EC2 User                 | `ec2-user`                     |
| Twenty CRM Port          | `2020`                         |
| CloudWatch Namespace     | `CWAgent`                      |
| CloudWatch Agent Version | `1.300069.1`                   |
| IAM Instance Profile     | `CloudWatchAgentEC2Role`       |

---

## 3. EC2 Instance Setup

An EC2 instance was launched in the `us-east-1` AWS region using the provided AWS account.

The instance was accessed using SSH:

```bash
ssh -i <key-file> ec2-user@<EC2-PUBLIC-IP>
```

After connecting, the instance hostname was verified:

```bash
hostname
```

The EC2 instance used the provided IAM instance profile:

```text
CloudWatchAgentEC2Role
```

The instance profile was verified using the EC2 Instance Metadata Service.

---

## 4. Twenty CRM Deployment

The Twenty CRM project was cloned onto the EC2 instance.

The project directory was:

```bash
~/devops-crm-project
```

The repository was cloned from the provided GitHub repository.

### Node.js and Yarn

The project required a compatible Node.js version.

Initially, Node.js 18 was installed. Twenty CRM produced an `ERR_REQUIRE_ESM` error related to the `uuid` package.

The issue was resolved by installing and using Node.js 24 with NVM.

Installed versions:

```text
Node.js: v24.20.0
npm: 11.19.0
Yarn: 4.13.0
```

The project specifies Yarn 4.13.0 in `package.json`.

Dependencies were installed using:

```bash
corepack yarn install
```

---

## 5. Starting Twenty CRM

Twenty CRM was started using:

```bash
corepack yarn twenty docker:start
```

The application started successfully after resolving the memory issue described below.

The application was exposed on port `2020`:

```text
http://<EC2-PUBLIC-IP>:2020
```

Docker was verified using:

```bash
docker ps
```

The Twenty CRM container was running with:

```text
0.0.0.0:2020->2020/tcp
```

The application startup output confirmed:

```text
Server running on http://localhost:2020
```

---

## 6. Issue 1: Twenty CRM Container Was OOM Killed

### Problem

During the first Twenty CRM startup attempt, the application failed its health check.

The Docker container was inspected using:

```bash
docker inspect twenty-app-dev --format='ExitCode={{.State.ExitCode}} Error={{.State.Error}} OOMKilled={{.State.OOMKilled}}'
```

The result showed:

```text
OOMKilled=true
```

The EC2 instance had approximately 2 GB of RAM and no swap:

```text
Mem: 1.9Gi
Swap: 0B
```

### Solution

A 2 GB swap file was created:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

The swap configuration was persisted:

```bash
sudo bash -c 'echo "/swapfile swap swap defaults 0 0" >> /etc/fstab'
```

Swap was verified using:

```bash
sudo swapon --show
```

Result:

```text
NAME      TYPE SIZE USED PRIO
/swapfile file   2G   0B   -2
```

After enabling swap, Twenty CRM successfully started.

### Result

The application became healthy and the Docker container remained running.

This was an important troubleshooting step because CloudWatch memory monitoring can help identify resource pressure that may lead to application failures.

---

## 7. Default EC2 CloudWatch Metrics

The default EC2 metrics available in Amazon CloudWatch were explored.

The primary metric used for this task was:

```text
AWS/EC2 → CPUUtilization
```

The metric was monitored for:

```text
InstanceId: i-05c1316461a2f5586
```

The default EC2 CPU metric was used to create the CPU alarm and dashboard monitoring.

---

## 8. CloudWatch Agent Installation

The Amazon CloudWatch Agent was installed on the EC2 instance.

The installed version was:

```text
amazon-cloudwatch-agent-1.300069.1-1.amzn2023.x86_64
```

The CloudWatch Agent control command was used to configure and start the agent.

---

## 9. CloudWatch Agent Configuration

The CloudWatch Agent was configured to collect system-level metrics.

The configuration included:

* CPU utilization
* Memory utilization
* Disk utilization

The configuration used the custom CloudWatch namespace:

```text
CWAgent
```

Configuration:

```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"],
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
        "resources": ["*"]
      }
    }
  }
}
```

The CloudWatch Agent was started with:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
```

---

## 10. CloudWatch Agent Verification

The agent status was checked using:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

The result confirmed:

```json
{
  "status": "running",
  "configstatus": "configured",
  "version": "1.300069.1"
}
```

Therefore, the CloudWatch Agent was successfully installed, configured, and running.

---

## 11. CPU Monitoring

The CloudWatch Agent configuration included CPU metrics:

```text
cpu_usage_idle
cpu_usage_user
cpu_usage_system
```

The collection interval was:

```text
60 seconds
```

CPU metrics were published under:

```text
CWAgent
```

The default AWS EC2 CPU metric was also available under:

```text
AWS/EC2 → CPUUtilization
```

---

## 12. Memory Monitoring

Memory monitoring was configured using:

```text
mem_used_percent
```

The collection interval was:

```text
60 seconds
```

The metric was configured under the:

```text
CWAgent
```

namespace.

The CloudWatch Agent remained in the `running` and `configured` state while memory collection was configured.

---

## 13. Disk Monitoring

Disk monitoring was configured using:

```text
used_percent
```

The CloudWatch Agent was configured to collect disk utilization for all available disk resources.

The collection interval was:

```text
60 seconds
```

---

## 14. Issue 2: CloudWatch ListMetrics AccessDenied

While attempting to verify the memory metric directly from the EC2 instance, the following command was used:

```bash
aws cloudwatch list-metrics \
  --namespace CWAgent \
  --metric-name mem_used_percent \
  --dimensions Name=InstanceId,Value=i-05c1316461a2f5586 \
  --region us-east-1
```

The AWS CLI returned an access-denied error because the EC2 IAM role did not have:

```text
cloudwatch:ListMetrics
```

permission.

### Cause

The EC2 instance was using the provided:

```text
CloudWatchAgentEC2Role
```

The role is intended for CloudWatch Agent operation, but it did not provide permission for the `ListMetrics` API call from the instance.

### Solution / Handling

The issue was treated as a read/list permission limitation rather than a CloudWatch Agent failure.

The CloudWatch Agent itself was verified separately:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

The result showed:

```text
status: running
configstatus: configured
```

Therefore, no unnecessary IAM policy changes were made.

Metric verification was performed through the CloudWatch console instead.

---

## 15. CloudWatch CPU Alarm

A CloudWatch alarm was created for EC2 CPU utilization.

### Alarm Configuration

| Setting    | Value                  |
| ---------- | ---------------------- |
| Alarm Name | `Ekta-Task10-High-CPU` |
| Namespace  | `AWS/EC2`              |
| Metric     | `CPUUtilization`       |
| Instance   | `i-05c1316461a2f5586`  |
| Statistic  | Average                |
| Period     | 5 minutes              |
| Threshold  | Greater than 80%       |
| Datapoints | 1 out of 1             |
| Actions    | No actions             |

Alarm condition:

```text
CPUUtilization > 80 for 1 datapoint within 5 minutes
```

The alarm was successfully created and reached the `OK` state when CPU utilization remained below the configured threshold.

---

## 16. Memory Alarm

A memory alarm was planned using:

```text
CWAgent → mem_used_percent
```

The intended configuration was:

| Setting    | Value                     |
| ---------- | ------------------------- |
| Alarm Name | `Ekta-Task10-High-Memory` |
| Metric     | `mem_used_percent`        |
| Statistic  | Average                   |
| Period     | 5 minutes                 |
| Threshold  | Greater than 80%          |
| Datapoints | 1 out of 1                |
| Actions    | No actions                |

However, the current EC2 instance metric was not appearing in the CloudWatch metric search at the time of testing.

Therefore, the memory alarm was not falsely created without confirming the metric.

---

## 17. CloudWatch Dashboard

A dedicated CloudWatch dashboard was created for the intern.

Dashboard name:

```text
Ekta-Task10-Dashboard
```

The dashboard is intended to monitor:

* EC2 CPU utilization
* CloudWatch Agent memory utilization
* CloudWatch Agent disk utilization

The dashboard can be used to observe resource utilization while Twenty CRM is running and being accessed.

---

## 18. Application Activity Testing

Twenty CRM was accessed through the EC2 public endpoint.

Application activity included normal operations such as:

* Opening the application.
* Navigating through the CRM.
* Refreshing pages.
* Accessing CRM records.
* Performing normal application interactions.

This activity was intended to generate server workload that could be observed through CloudWatch.

---

## 19. Monitoring and Troubleshooting

CloudWatch provides several useful capabilities for monitoring the Twenty CRM server.

### Monitoring

CloudWatch can monitor:

* CPU utilization.
* Memory utilization.
* Disk utilization.
* Application/server resource consumption.
* Changes in resource usage over time.

### Alerting

CloudWatch alarms can be configured to detect abnormal resource usage.

For example:

```text
CPUUtilization > 80%
```

can trigger a high-CPU alarm.

Similarly:

```text
mem_used_percent > 80%
```

can be used as a high-memory condition once the metric is available.

### Troubleshooting

CloudWatch metrics can help identify:

* High CPU usage.
* Memory pressure.
* Disk capacity problems.
* Resource-related application failures.

In this task, the Twenty CRM container was confirmed as `OOMKilled`. The issue was addressed by adding swap space to the EC2 instance.

---

## 20. Important Commands Used

### Check EC2 resources

```bash
free -h
```

```bash
df -h
```

```bash
nproc
```

```bash
vmstat 1 5
```

### Check Docker

```bash
docker ps
```

```bash
docker inspect twenty-app-dev --format='ExitCode={{.State.ExitCode}} Error={{.State.Error}} OOMKilled={{.State.OOMKilled}}'
```

### Start Twenty CRM

```bash
corepack yarn twenty docker:start
```

### Check CloudWatch Agent

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

### Check CloudWatch Agent logs

```bash
sudo tail -50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

---

## 21. Issues and Solutions Summary

| Issue                                        | Cause                                                      | Solution                                                    |
| -------------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------- |
| Twenty CRM failed health check               | EC2 container was OOM killed                               | Added 2 GB swap                                             |
| Node.js `ERR_REQUIRE_ESM`                    | Node.js 18 incompatibility                                 | Installed Node.js 24                                        |
| CloudWatch Agent wizard error                | Incorrect value entered for old log config path            | Used direct JSON configuration                              |
| `ListMetrics AccessDenied`                   | EC2 role lacks `cloudwatch:ListMetrics`                    | Verified agent status and used CloudWatch console           |
| Memory metric not found for current instance | Metric was not visible in CloudWatch search during testing | Kept agent running and avoided creating an unverified alarm |
| Accidental `Close` and `override` files      | CloudWatch/terminal text was accidentally pasted into Bash | Removed the empty files                                     |

---

## 22. Testing Results

### Twenty CRM

Status:

```text
SUCCESS
```

The application successfully started and the Docker container remained running.

### CloudWatch Agent

Status:

```text
running
```

Configuration status:

```text
configured
```

### CPU Alarm

Alarm:

```text
Ekta-Task10-High-CPU
```

Status:

```text
OK
```

### Dashboard

Dashboard:

```text
Ekta-Task10-Dashboard
```

Created successfully.

### Memory and Disk

Memory and disk collection were included in the CloudWatch Agent configuration. Metric visibility for the current instance was checked through CloudWatch.

---

## 23. Screenshots

Add the following screenshots to the repository/documentation before final submission.

### Screenshot 1 – EC2 Instance

Show:

* EC2 instance ID
* Running state
* Region
* Public IP

```text
[Add EC2 screenshot here]
```

### Screenshot 2 – Twenty CRM

Show the Twenty CRM application running:

```text
[Add Twenty CRM screenshot here]
```

### Screenshot 3 – Docker Container

Show:

```bash
docker ps
```

with the Twenty CRM container running.

```text
[Add Docker screenshot here]
```

### Screenshot 4 – CloudWatch Agent Status

Show:

```text
status: running
configstatus: configured
```

```text
[Add CloudWatch Agent screenshot here]
```

### Screenshot 5 – CloudWatch Metrics

Show the `CWAgent` namespace and collected metrics.

```text
[Add CloudWatch metrics screenshot here]
```

### Screenshot 6 – CPU Alarm

Show:

```text
Ekta-Task10-High-CPU
```

with its threshold and `OK` state.

```text
[Add CPU alarm screenshot here]
```

### Screenshot 7 – CloudWatch Dashboard

Show:

```text
Ekta-Task10-Dashboard
```

```text
[Add dashboard screenshot here]
```

### Screenshot 8 – OOM Issue and Swap Solution

Show the relevant terminal output demonstrating:

```text
OOMKilled=true
```

and the configured swap:

```text
/swapfile 2G
```

```text
[Add troubleshooting screenshot here]
```

---

## 24. Loom Video

Loom video demonstrating the implementation:

```text
[Add Loom video link here]
```

The video should demonstrate:

1. EC2 instance.
2. Twenty CRM deployment.
3. CloudWatch Agent configuration.
4. CloudWatch metrics.
5. CloudWatch alarm.
6. CloudWatch dashboard.
7. Testing/activity.
8. Issues and solutions.

---

## 25. GitHub

Branch used for this task:

```text
Ekta-Task-10
```

Commit message:

```text
docs: add AWS CloudWatch observability for task 10
```

Pull Request:

```text
[Add Pull Request link here]
```

---

## 26. Final Status

The Task 10 implementation covered AWS EC2 deployment, Twenty CRM deployment, CloudWatch monitoring, CloudWatch Agent configuration, CPU alerting, dashboard creation, troubleshooting, and documentation.

The major infrastructure issue encountered was the Twenty CRM container being OOM killed on the small EC2 instance. This was resolved by configuring a 2 GB swap file.

The CloudWatch Agent was successfully installed and verified as:

```text
running
configured
```

The CPU alarm was successfully created and verified in the `OK` state.

The CloudWatch dashboard was created for monitoring the EC2 instance.

Before final cleanup, all required screenshots, documentation, and Loom evidence should be completed.

---

## 27. EC2 Cleanup

After all testing, screenshots, Loom recording, documentation, and GitHub PR activities are complete, the EC2 instance should be terminated to avoid unnecessary AWS charges.

Instance:

```text
i-05c1316461a2f5586
```

**Important:** Terminate the EC2 instance only after all evidence and submission requirements have been completed.

