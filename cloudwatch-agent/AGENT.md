# AWS Observability with CloudWatch - Task 10

## 1. Overview
This document details the implementation of AWS Observability for the Twenty CRM application using Amazon CloudWatch. It covers the deployment of the application, installation of the CloudWatch Agent, custom metric collection, dashboard creation, and alerting.

## 2. Implementation Steps
### 2.1 EC2 Provisioning
Launched a `t3.small` Ubuntu instance. Crucially, attached an IAM role with the `CloudWatchAgentServerPolicy` to allow the instance to push metrics to CloudWatch. Opened ports 22 and 2020 in the Security Group.

### 2.2 Application Deployment
Deployed Twenty CRM using Docker Compose. Fixed the default localhost redirect by updating the `SERVER_URL` and `FRONTEND_URL` environment variables to the EC2 Public IP.

### 2.3 CloudWatch Agent Configuration
Installed the Amazon CloudWatch Agent and configured a custom JSON file to collect:
- **Memory:** `mem_used_percent`
- **Disk:** `disk_used_percent` for `/` and `/opt/twenty-crm`
- **CPU:** `cpu_usage_user` and `cpu_usage_idle`
Metrics are pushed to the custom namespace `TwentyCRM/EC2` every 60 seconds.

## 3. Monitoring and Alerting
- **Dashboard:** Created a unified CloudWatch Dashboard visualizing Memory and CPU utilization in real-time.
- **Alarms:** Configured a CloudWatch Alarm to trigger when Memory utilization exceeds 80%.
- **Traffic Generation:** Used a `curl` loop to generate synthetic load, which successfully spiked the metrics on the dashboard, proving the observability pipeline works.

## 4. Issues Faced & Solutions
- **Issue:** CloudWatch Agent failed to start initially.
- **Solution:** The EC2 instance lacked the necessary IAM permissions. Attached the `CloudWatchAgentServerPolicy` to the instance profile, which resolved the issue.
- **Issue:** Default EC2 metrics do not include Memory or Disk usage.
- **Solution:** Installed and configured the CloudWatch Agent to collect and push these OS-level metrics to CloudWatch.

## 5. Conclusion
CloudWatch is a powerful tool for proactive monitoring. While default EC2 metrics provide basic hypervisor-level data (like CPU), the CloudWatch Agent is essential for gaining deep visibility into OS-level metrics (Memory, Disk) and application performance, enabling effective alerting and troubleshooting.
