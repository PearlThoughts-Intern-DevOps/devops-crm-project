# Task 10: AWS Observability with CloudWatch

## Overview

This task focused on implementing AWS observability for the Twenty CRM application running on an Amazon EC2 instance using Amazon CloudWatch.

The implementation covered:

- Launching and connecting to an EC2 instance
- Deploying and verifying Twenty CRM
- Exploring default EC2 CloudWatch metrics
- Installing and configuring the CloudWatch Agent
- Collecting CPU, memory, swap, and disk metrics
- Sending server logs to CloudWatch Logs
- Creating CloudWatch alarms
- Creating a CloudWatch dashboard
- Generating server activity and observing metric changes
- Testing alarm triggering and recovery
- Documenting the implementation, issues, and solutions
- Terminating the EC2 instance after the task

The EC2/Twenty CRM setup was automated using the Ansible playbook developed in Task 9.

---

# 1. EC2 Instance

| Item                    | Value                                                               |
| ----------------------- | ------------------------------------------------------------------- |
| Instance Name           | `task-10-mohit`                                                     |
| Application             | Twenty CRM                                                          |
| Monitoring Service      | Amazon CloudWatch                                                   |
| IAM Role                | `cloudwatchagentec2role`                                            |
| CloudWatch Agent Config | `/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json` |

The EC2 instance was launched using the AWS account and credentials provided for the internship task. SSH access was established and the server was prepared for the application and monitoring setup.

---

# 2. Twenty CRM Deployment

The Twenty CRM server was provisioned using the Ansible playbook developed during Task 9.

The playbook automated the main server setup and application deployment, including dependencies, Docker configuration, application directories, repository setup, and Twenty CRM deployment.

Using Ansible made the server setup repeatable and reduced manual configuration.

After deployment, Twenty CRM was verified with its health endpoint:

```bash
curl -s http://localhost:2020/healthz
```

A successful response confirmed that the application was running.

---

# 3. Exploring Default EC2 CloudWatch Metrics

The EC2 instance was checked through:

**AWS Console → CloudWatch → Metrics → EC2**

The default EC2 metrics were explored, including CPU utilization and network-related instance metrics.

These built-in metrics provide a useful baseline for monitoring the EC2 instance. Additional operating-system-level metrics, particularly memory and filesystem utilization, were collected using the CloudWatch Agent.

---

# 4. CloudWatch Agent Setup

The CloudWatch Agent was installed on the EC2 instance.

The configuration file was created at:

```text
/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

The EC2 instance used the IAM role:

```text
cloudwatchagentec2role
```

The role allowed the CloudWatch Agent to communicate with AWS monitoring services without storing permanent AWS access keys on the instance.

---

# 5. CloudWatch Agent Configuration

The following configuration was used:

```json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/monitoring.log",
            "log_group_name": "monitoring",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "totalcpu": true,
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "swap": {
        "measurement": ["swap_used_percent"]
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["*"],
        "metrics_collection_interval": 60
      }
    }
  }
}
```

---

# 6. Metrics Collected

## CPU

The agent collected:

- `cpu_usage_idle`
- `cpu_usage_iowait`
- `cpu_usage_user`
- `cpu_usage_system`

CPU metrics were collected at a one-minute interval.

## Memory

Memory utilization was collected using:

```text
mem_used_percent
```

## Swap

Swap utilization was collected using:

```text
swap_used_percent
```

## Disk

Filesystem utilization was collected using:

```text
used_percent
```

for all configured disk resources.

These metrics provided additional operating-system-level visibility beyond the standard EC2 monitoring data.

---

# 7. CloudWatch Logs

The CloudWatch Agent was also configured to collect:

```text
/var/log/monitoring.log
```

The logs were sent to the CloudWatch Logs group:

```text
monitoring
```

The log stream used:

```text
{instance_id}
```

This provided centralized log visibility through CloudWatch.

---

# 8. Verifying CloudWatch Agent Metrics

After the CloudWatch Agent was configured and started, the instance was checked in CloudWatch to verify that the agent was successfully publishing data.

The following were verified:

- CPU metrics
- Memory utilization
- Swap utilization
- Disk utilization

The metrics were observed over time to confirm that data was being received at the configured interval.

---

# 9. CloudWatch Dashboard

A dedicated CloudWatch dashboard was created for the EC2 monitoring task.

The dashboard was used as a centralized monitoring view for the Twenty CRM server.

The dashboard included relevant charts such as:

- CPU utilization
- Memory utilization
- Disk utilization
- Swap utilization
- EC2 performance metrics

This made it easier to observe the health and resource usage of the server from one place.

---

# 10. CloudWatch Alarms

CloudWatch alarms were created for suitable resource metrics.

A CPU utilization alarm was used to demonstrate alerting when CPU usage crossed the configured threshold.

The CPU alarm test used a threshold of:

```text
CPU utilization > 10%
```

The alarm was tested by deliberately creating CPU load on the server.

The expected lifecycle was:

```text
OK → ALARM → OK
```

> Note: Keep the threshold in this document aligned with the actual threshold shown in your final CloudWatch alarm screenshot.

---

# 11. Generating Server Activity

Twenty CRM was accessed during the monitoring test to generate normal server activity.

Additional CPU load was deliberately created to test the CloudWatch alarm:

```bash
yes > /dev/null
```

This caused CPU utilization to increase and allowed the metric and dashboard behavior to be observed.

After the test, the process was stopped:

```bash
ctrl+c
```

---

# 12. Alarm Testing

The alarm test followed these steps.

### Step 1 — Normal State

The instance was running normally and the alarm was in:

```text
OK
```

### Step 2 — Generate CPU Load

CPU load was generated:

```bash
yes > /dev/null
```

### Step 3 — Observe CloudWatch

CPU utilization increased in CloudWatch.

After the configured evaluation conditions were satisfied, the alarm transitioned to:

```text
ALARM
```

### Step 4 — Stop the Load

The test process was stopped:

```bash
ctrl+c
```

### Step 5 — Verify Recovery

After the recovery evaluation period, CPU utilization decreased and the alarm returned to:

```text
OK
```

This verified both alert triggering and recovery behavior.

---

# 13. Monitoring Twenty CRM Activity

Twenty CRM was accessed during the test to generate application activity on the EC2 instance.

The CloudWatch dashboard was used to observe how server resource usage changed during application usage and during the additional CPU-load test.

The overall observability flow was:

```text
Twenty CRM Activity
        ↓
EC2 Resource Usage
        ↓
CloudWatch Agent / EC2 Metrics
        ↓
CloudWatch Dashboard
        ↓
CloudWatch Alarm
```

---

# 14. Monitoring and Troubleshooting

CloudWatch can be used not only for alerting but also for troubleshooting.

A typical troubleshooting workflow for the Twenty CRM server is:

```text
Application Issue
      ↓
Check EC2 Health
      ↓
Check CPU
      ↓
Check Memory
      ↓
Check Disk
      ↓
Review CloudWatch Logs
      ↓
Check Alarm History
      ↓
Investigate Application / Server
```

For example:

- High CPU can indicate a CPU-intensive process or unexpected workload.
- High memory utilization can indicate resource pressure.
- High disk utilization can indicate storage exhaustion.
- Logs can provide additional context when investigating application or server behavior.
- Alarm history can help identify when a resource crossed a configured threshold.

---

# 15. IAM and Security

The EC2 instance used:

```text
cloudwatchagentec2role
```

The IAM role allowed the CloudWatch Agent to access the required AWS monitoring services without placing long-lived AWS access keys in the CloudWatch Agent configuration.

This is preferable to storing permanent credentials directly on the server.

---

# 16. Issues Faced and Solutions

## Issue 1 — Default EC2 metrics did not provide memory utilization

### Problem

The default EC2 monitoring metrics were not sufficient for the required operating-system-level memory monitoring.

### Solution

The CloudWatch Agent was installed and configured to collect:

```text
mem_used_percent
```

The metric was then available through CloudWatch.

---

## Issue 2 — Disk utilization needed to be monitored

### Problem

The task required disk utilization monitoring.

### Solution

The CloudWatch Agent was configured to collect:

```text
used_percent
```

for the disk resources.

---

## Issue 3 — Proving that the alarm worked

### Problem

Creating an alarm alone does not confirm that it triggers and recovers correctly.

### Solution

CPU load was deliberately generated:

```bash
yes > /dev/null
```

The increase in CPU utilization was observed in CloudWatch and the alarm transitioned to `ALARM`.

The load was then stopped:

```bash
ctrl+c
```

The alarm was monitored until it returned to `OK`.

---

# 17. Architecture

```text
                    AWS
                     │
                     ▼
             ┌────────────────┐
             │ EC2            │
             │ task-10-mohit  │
             └───────┬────────┘
                     │
             ┌───────┴────────┐
             │                │
             ▼                ▼
       Twenty CRM       CloudWatch Agent
                            │
                ┌───────────┼───────────┐
                │           │           │
                ▼           ▼           ▼
               CPU        Memory       Disk
                │           │           │
                └───────────┼───────────┘
                            ▼
                    Amazon CloudWatch
                     │           │
             ┌───────┴───┐   ┌──┴──────┐
             ▼           ▼   ▼         │
        Dashboard      Alarms        Logs
```

---

# 18. What I Learned

This task provided practical experience with AWS observability and monitoring.

Key learning outcomes:

- Understanding default EC2 metrics
- Understanding why a CloudWatch Agent is useful for system-level metrics
- Installing and configuring the CloudWatch Agent
- Collecting CPU, memory, swap, and disk metrics
- Sending server logs to CloudWatch Logs
- Creating CloudWatch dashboards
- Creating and testing CloudWatch alarms
- Understanding alarm states and recovery
- Using metrics for troubleshooting
- Using IAM roles for AWS service access
- Observing the relationship between application activity and infrastructure metrics
- Combining Ansible-based deployment with AWS observability

---

# 19. Conclusion

Task 10 implemented an end-to-end AWS observability setup for the Twenty CRM application running on EC2.

The server was provisioned using the Ansible automation developed in Task 9. CloudWatch was then used to monitor the instance, collect additional system-level metrics, centralize logs, visualize resource usage through a dashboard, and trigger alarms when resource usage crossed configured thresholds.

The CPU-load test demonstrated the complete alerting lifecycle:

```text
Normal
  ↓
CPU Load
  ↓
Metric Increase
  ↓
Alarm Triggered
  ↓
CPU Load Removed
  ↓
Alarm Recovery
```

After completing the required testing and documentation, the EC2 instance was terminated as required by the task.

---
