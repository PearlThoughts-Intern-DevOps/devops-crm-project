# TASK 10 – AWS CloudWatch Observability

## 1. Objective

The objective of this task was to implement AWS observability using Amazon CloudWatch for monitoring an EC2 instance and collecting system-level metrics using the CloudWatch Agent.

The implementation includes:

* EC2 monitoring
* CloudWatch Agent installation
* CPU, memory and disk monitoring
* Custom CloudWatch metrics
* CPU and memory alarms
* CloudWatch monitoring dashboard

## 2. EC2 Instance

The application was deployed on an Amazon Linux 2023 EC2 instance.

Configuration:

* OS: Amazon Linux 2023
* Instance Type: t3.small
* Region: us-east-1
* vCPU: 2
* Memory: 2 GiB
* Root Storage: 20 GiB

## 3. Application Environment

The DevOps CRM project was used for the application environment.

Required tools were configured on the EC2 instance:

* Node.js 24.5.0
* Yarn 4.13.0
* Docker
* Amazon CloudWatch Agent

The project dependencies were installed successfully using:

```bash
yarn install
```

## 4. CloudWatch Agent Installation

The CloudWatch Agent was installed using:

```bash
sudo yum install amazon-cloudwatch-agent -y
```

The installation completed successfully.

## 5. CloudWatch Agent Configuration

A custom CloudWatch Agent configuration was created at:

```text
/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

The configuration collects:

### CPU Metrics

* cpu_usage_user
* cpu_usage_system
* cpu_usage_idle

### Memory Metrics

* mem_used_percent

### Disk Metrics

* used_percent

Metrics are published to the custom namespace:

```text
CWAgent
```

The configuration also attaches the EC2 Instance ID to the metrics.

## 6. Starting the CloudWatch Agent

The agent was started using:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
```

Configuration validation completed successfully.

The service status was verified using:

```bash
sudo systemctl status amazon-cloudwatch-agent --no-pager
```

The service showed:

```text
Active: active (running)
```

## 7. CloudWatch Metrics

CloudWatch provides default EC2 metrics such as:

* CPUUtilization
* NetworkIn
* NetworkOut
* StatusCheckFailed
* Disk read/write metrics

The CloudWatch Agent provides additional system-level metrics under the `CWAgent` namespace.

The custom memory metric successfully appeared under:

```text
CWAgent → InstanceId → mem_used_percent
```

## 8. CPU Alarm

A CloudWatch alarm was created for EC2 CPU utilization.

Configuration:

* Metric: CPUUtilization
* Statistic: Average
* Period: 1 minute
* Condition: Greater than 70%
* Evaluation Periods: 1
* Alarm Name: `Task10-EC2-High-CPU`

This alarm helps identify high CPU utilization on the EC2 instance.

## 9. Memory Alarm

A CloudWatch alarm was configured for memory utilization using the CloudWatch Agent metric.

Configuration:

* Metric: mem_used_percent
* Statistic: Average
* Period: 1 minute
* Condition: Greater than 80%
* Evaluation Periods: 1
* Alarm Name: `Task10-EC2-High-Memory`

## 10. CloudWatch Dashboard

A CloudWatch dashboard named:

```text
Task10-EC2-Observability
```

was created.

The dashboard contains monitoring widgets for:

* CPUUtilization
* Memory utilization
* NetworkIn
* NetworkOut
* CloudWatch alarm status

The dashboard provides a centralized view of the EC2 instance health and resource utilization.

## 11. Verification

The following checks were performed:

```bash
free -h
```

The EC2 instance had approximately 1.5 GiB of available memory.

Disk usage was checked using:

```bash
df -h
```

The root filesystem had approximately 16 GiB available.

Docker containers were checked using:

```bash
docker ps -a
```

The CloudWatch Agent service was verified as running.

CloudWatch metrics were also verified from the AWS Management Console.

## 12. Observability Architecture

The implementation follows this monitoring flow:

```text
EC2 Instance
     |
     +---- Default EC2 Metrics
     |          |
     |          v
     |     Amazon CloudWatch
     |
     +---- CloudWatch Agent
                |
                +---- CPU Metrics
                +---- Memory Metrics
                +---- Disk Metrics
                         |
                         v
                    CWAgent Namespace
                         |
                         v
                  CloudWatch Alarms
                         |
                         v
                  CloudWatch Dashboard
```

## 13. Conclusion

AWS CloudWatch observability was successfully implemented for the EC2 environment.

The implementation provides:

* EC2 resource monitoring
* System-level CPU, memory and disk metrics
* Custom CloudWatch metrics
* CPU and memory threshold alarms
* Centralized CloudWatch dashboard monitoring

This setup provides a foundation for detecting resource utilization issues and monitoring the health of the deployed environment.

