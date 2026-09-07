# Task 10: AWS Observability with CloudWatch

## Objective

Implemented AWS observability for the Twenty CRM application running on an Amazon EC2 instance using Amazon CloudWatch.

## 1. EC2 Instance Setup

- Launched an Ubuntu EC2 instance in AWS.
- Connected to the instance using SSH.
- Instance type used: `t3.small`
- AWS Region: `us-east-1 (N. Virginia)`

## 2. Twenty CRM Deployment

Twenty CRM was deployed and run on the EC2 instance using Docker.

The application was exposed on port `2020`.

The application was successfully started on the EC2 instance and verified locally using an HTTP 200 response.

## 3. CloudWatch Agent

Installed and configured the Amazon CloudWatch Agent on the EC2 instance.

The agent was configured to collect:

- CPU utilization
- Memory utilization
- Disk utilization

Metrics were configured with a 60-second collection interval.

## 4. CloudWatch Metrics Configuration

The CloudWatch Agent configuration included:

- `cpu_usage_idle`
- `cpu_usage_user`
- `cpu_usage_system`
- `cpu_usage_iowait`
- `mem_used_percent`
- Disk `used_percent`

The disk metric was configured for the root filesystem `/`.

## 5. CloudWatch Alarm

Created the following CloudWatch alarm:

`Tannu-Task10-CPU-High`

Configuration:

- Namespace: `AWS/EC2`
- Metric: `CPUUtilization`
- Statistic: Average
- Period: 5 minutes
- Threshold: CPU utilization greater than 70%
- Evaluation: 1 datapoint within 5 minutes

The alarm was created without notification actions because the provided IAM user did not have permission to create/list SNS topics.

## 6. CloudWatch Dashboard

Created a personal CloudWatch dashboard:

`Tannu-Task10-Observability`

A CPU utilization widget using the EC2 CPUUtilization metric was added and configured for the EC2 instance. After the instance was terminated, the dashboard no longer displayed live metric data.

## 7. Testing

The CloudWatch Agent was started successfully and its status showed:

- Status: Running
- Config status: Configured

The Twenty CRM container was also successfully started during the implementation.

## 8. Issues Faced

### Redis connection issue

During Twenty CRM startup, Redis connection/session-store errors were observed.

Redis was started and verified locally, after which the Twenty CRM application successfully started.

### Disk space issue

The EC2 instance had limited disk space and the root filesystem reached very high utilization.

The issue was handled by cleaning package cache, pruning unused Docker resources, and removing unnecessary local `node_modules`.

### Memory pressure

Memory usage was high while running Twenty CRM.

A swap file was configured to provide additional virtual memory.

### EC2 termination

During the final verification stage, the EC2 instance became terminated.

A replacement instance could not be launched because the provided IAM user had an explicit deny for:

`ec2:RunInstances`

Therefore, final live metric-change testing could not be completed.

## 9. Final Status

The following components were successfully implemented:

- EC2 setup
- SSH connection
- Twenty CRM deployment
- CloudWatch Agent installation
- CPU monitoring configuration
- Memory monitoring configuration
- Disk monitoring configuration
- CloudWatch CPU alarm
- Personal CloudWatch dashboard

Final live CRM activity and metric-change verification could not be completed because the EC2 instance was terminated before final testing.