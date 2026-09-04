# Task 8: AWS Observability

## Overview

This task focused on exploring AWS observability and understanding how AWS can be used to monitor infrastructure, collect application and operating-system telemetry, create alerts, and audit activity in an AWS account.

The hands-on work in this task focused on an existing EC2 instance named `task-8-web-v2` and covered:

- Amazon CloudWatch
- CloudWatch Metrics and Dashboards
- CloudWatch Agent for internal monitoring
- CloudWatch Logs
- CloudWatch Alarms
- Amazon SNS notifications
- AWS CloudTrail

The exercises helped me understand the difference between monitoring system health, collecting application telemetry, generating alerts, and auditing AWS account activity.

---

## 1. Amazon CloudWatch

### What I learned

Amazon CloudWatch is AWS's built-in monitoring service for collecting and viewing metrics, logs, and events from AWS resources and applications.

For EC2 instances, CloudWatch can provide metrics such as:

- CPU utilization
- Network activity
- Disk read/write activity

These metrics can be used to understand whether an instance is idle, under heavy load, or consuming significant network or disk resources.

### Monitoring Target

I used the existing EC2 instance:

```text
task-8
```

as the monitoring target.

---

## 1. CloudWatch Metrics and Dashboard

### Creating a Dashboard

I created a CloudWatch dashboard named:

```text
crm
```

I added the EC2 `CPUUtilization` metric for the `task-8` instance.

The dashboard was configured to display a 15-minute time range.

### Testing CPU Monitoring

To verify that CloudWatch was detecting changes in the instance's CPU usage, I connected to the EC2 instance and generated CPU load with:

```bash
yarn twenty docker:start
```

I allowed the process to run for several minutes and observed the CPU utilization increase on the CloudWatch dashboard.

After confirming the CPU spike, I stopped the process with:

```text
yarn twenty docker:stop
```

### Monitoring Flow

```text
EC2 Instance -> CPUUtilization Metric -> CloudWatch -> CloudWatch Dashboard -> Observed CPU Spike

```

### Key Learning

This exercise demonstrated how CloudWatch can be used to monitor infrastructure metrics in real time and visualize those metrics through dashboards.

---

## 2. External vs Internal Monitoring

A key concept I learned is the difference between metrics AWS can observe automatically and information that exists inside the server's operating system.

### External Monitoring

Basic EC2 monitoring can provide metrics such as:

- CPU utilization
- Network usage

### Internal Monitoring

Useful information also exists inside the operating system, including:

- Memory usage
- Swap usage
- Filesystem information
- Application logs

For this type of internal monitoring, the CloudWatch Agent can be installed on the EC2 instance.

---

## 3. CloudWatch Agent

### What I learned

The **CloudWatch Agent** is software that runs inside the server and collects operating-system and application-level information that is not available through the basic EC2 monitoring metrics.

The agent is configured using a JSON configuration file that specifies which metrics and logs should be collected.

A typical setup is:

1. Create an IAM role with the permissions required by the agent.
2. Install the CloudWatch Agent on the EC2 instance.
3. Configure the agent using a JSON configuration file.
4. Start and enable the agent.
5. Verify that metrics and logs are appearing in CloudWatch.

---

## 4. IAM Permissions for CloudWatch Monitoring

The monitoring role used for the EC2 instance was:

```text
monitoring-role
```

The role was configured with permissions that allow the CloudWatch Agent to send log data to CloudWatch Logs.

Example CloudWatch Logs policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": ["arn:aws:logs:*:*:*"]
    }
  ]
}
```


### Key Learning

This helped me understand that monitoring software still needs appropriate IAM permissions to interact with AWS services. IAM controls what the EC2 instance and its monitoring agent are allowed to access.

---

## 5. CloudWatch Agent Installation and Configuration

The CloudWatch Agent was installed on the monitoring EC2 instance using the commands from the exercise:

```bash
ssh task-8
sudo dnf upgrade
sudo dnf install amazon-cloudwatch-agent
```

The CloudWatch Agent configuration file was created at:

```text
/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

The configuration used was:

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
            "file_path": "/var/log/task-8.log",
            "log_group_name": "task-8-monitoring",
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
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "swap": {
        "measurement": ["swap_used_percent"]
      }
    }
  }
}
```

### What the Configuration Collects

The configuration:

- Collects metrics every **60 seconds**
- Runs the agent as the `root` user
- Collects memory utilization using `mem_used_percent`
- Collects swap utilization using `swap_used_percent`
- Adds useful EC2 dimensions such as instance ID and instance type
- Collects `/var/log/monitoring.log`
- Sends the application log to the `monitoring` log group
- Creates a log stream using the EC2 instance ID

### Starting the Agent

After saving the configuration, the service was started and enabled:

```bash
sudo systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent
```

Enabling the service allows the agent to start automatically with the system.

---

## 6. CloudWatch Logs and Application Log Collection

After configuring the CloudWatch Agent, the PatientPing application output was redirected to the log file monitored by the agent.

```bash
cd ~/mohitsingh-pre-internship-repo>
 yarn install
yarn twenty docker:start
yarn twenty dev
 docker logs -f twenty-app-dev 2>&1 | sudo tee -a /var/log/monitoring.log
```

The CloudWatch Agent reads this file and forwards the log entries to CloudWatch Logs.

### CloudWatch Log Group

The log group used for this exercise was:

```text
monitoring
```

Inside the log group, the log stream was associated with the EC2 instance ID.

This allowed the application logs to be viewed from the AWS Console without having to SSH into the EC2 instance every time.

### End-to-End Log Flow

```text
twenty CRM Application -> /var/log/task-8.log ->CloudWatch Agent -> CloudWatch Logs -> task-8-monitoring -> EC2 Instance Log Stream ->
```

### Key Learning

This exercise showed how application logs generated inside an EC2 instance can be centralized in CloudWatch. It also demonstrated the difference between automatically available EC2 metrics and telemetry that needs an in-instance agent.

---

## 7 CloudWatch Alarms

### What I learned

CloudWatch Alarms allow a metric to be evaluated continuously against a defined condition. When the condition is met, the alarm can trigger an action such as sending a notification.

This is useful because engineers do not need to manually watch a dashboard for every possible problem.

### Alarm Configuration

For this exercise, I created an alarm for the EC2 `CPUUtilization` metric.

The configuration was:

- **Metric:** `CPUUtilization`
- **Statistic:** Average
- **Period:** 1 minute
- **Threshold type:** Static
- **Condition:** CPU utilization greater than 10%

The alarm was named:

```text
cpu-alarm
```

Description:

```text
Alert when CPU exceeds 10%
```

---

## 8 Amazon SNS Notification

The CloudWatch Alarm was connected to an Amazon Simple Notification Service (SNS) topic.

The topic was named:

```text
cpu-alerts
```

An email endpoint was configured so that the alarm could send an email notification when the alarm entered the `In alarm` state.

### Alerting Flow

```text
EC2 Instance -> CPUUtilization-> CloudWatch Alarm->SNS Topic-> task-8-alerts-> Email Notification
```

### Key Learning

CloudWatch Alarms provide the alerting layer on top of CloudWatch metrics, while SNS provides a mechanism for delivering the notification.

---

## 9 Testing the CloudWatch Alarm

After creating the alarm, I tested the alerting workflow by generating CPU load on the EC2 instance.

First, the SNS email subscription was confirmed using the confirmation link sent by AWS.

I then connected to the EC2 instance and generated CPU load:

```bash
ssh task-8

yarn twenty docker:start
```

The process was allowed to run for several minutes so that CloudWatch could collect enough metric data and evaluate the alarm condition.

Once CPU utilization exceeded the configured 20% threshold, the CloudWatch alarm could transition into the alarm state and send the notification through SNS.

After verifying the test, the CPU load was stopped with:

```text
yarn twenty docker:stop
```

### Important Observation: Insufficient Data

A newly created alarm may initially show:

```text
Insufficient data
```

This does not necessarily mean that the alarm is broken. It can occur because the alarm has not yet collected enough metric data to make a decision.

After enough data points are available, the alarm can evaluate whether it is in a normal or alarm state.

---

## 10.AWS CloudTrail

### What I learned

CloudWatch focuses on monitoring infrastructure and applications, while **AWS CloudTrail** records AWS API activity within an AWS account.

CloudTrail events can provide information such as:

- Who made the API call
- Which API operation was performed
- When the operation occurred
- Whether it was a read or write operation
- Which resources were affected

Examples of API operations include:

```text
DescribeAlarms
CreateInstance
```

### Why CloudTrail is useful

CloudTrail is useful for:

- Auditing AWS activity
- Investigating unexpected changes
- Troubleshooting AWS operations
- Security investigations
- Understanding who changed a resource

For example, if a VPC setting unexpectedly changes, CloudTrail can help identify which user or AWS identity made the relevant API call and when it occurred.

### CloudWatch vs CloudTrail

| Service    | Main Purpose                                                         |
| ---------- | -------------------------------------------------------------------- |
| CloudWatch | Monitor metrics, logs, alarms, and application/infrastructure health |
| CloudTrail | Record AWS account/API activity and changes                          |

A simple way to remember the distinction is:

```text
CloudWatch → How is my system behaving?
CloudTrail  → Who did what in my AWS account?
```

### Organization Trails

CloudTrail also supports Organization Trails, which can be used to collect activity across multiple AWS accounts in an organization.

### Key Learning

CloudTrail adds an audit and activity layer to observability. It is useful when the question is not only whether something is working, but also **who changed something, what they changed, and when it happened**.

## 11 Key Learnings

The main lessons from this task were:

1. **Metrics, logs, and account activity provide different types of visibility.**
2. **CloudWatch can monitor infrastructure metrics and provide dashboards and alarms.**
3. **The CloudWatch Agent can collect information from inside an operating system, including memory, swap, and application logs.**
4. **IAM permissions are required for monitoring software to access and publish the required AWS resources.**
5. **CloudWatch Logs provides centralized access to application and system logs.**
6. **CloudWatch Alarms turn metrics into actionable alerts.**
7. **SNS can deliver CloudWatch alarm notifications through an email subscription.**
8. **CloudTrail is focused on AWS account/API activity and auditing rather than application health.**
9. **Observability is most useful when metrics, logs, alerts, and audit information are considered together.**

---

## 12 Cost Awareness

The exercises also highlighted that AWS observability features can have different pricing considerations.

Examples noted during the exercises included:

- Basic CloudWatch metrics for EC2 were available without an additional charge in the exercise.
- CloudWatch dashboards can incur a monthly charge, so unused test dashboards should be removed during cleanup.
- CloudWatch Logs can incur charges for log ingestion and storage.
- CloudWatch Alarms have free-tier considerations, and SNS notifications can also have usage-based pricing.
- CloudTrail has pricing considerations depending on the type and volume of events being recorded.

When experimenting with AWS monitoring services, resources that are no longer needed should be removed to avoid unnecessary charges.

---

## 13 Conclusion

This task gave me practical experience with AWS observability by monitoring an EC2 instance and building a basic monitoring and alerting workflow.

I worked with CloudWatch metrics and dashboards, configured the CloudWatch Agent for internal monitoring and application log collection, created a CPU-based CloudWatch Alarm, connected the alarm to SNS for email notification, and explored CloudTrail for AWS account activity auditing.

The main takeaway is that observability is not just about checking whether a server is running. A useful observability setup provides visibility into:

```text
System Health   → CloudWatch Metrics
Internal State  → CloudWatch Agent
Application Data → CloudWatch Logs
Alerts          → CloudWatch Alarms + SNS
Account Activity → CloudTrail
```

Together, these capabilities provide a more complete view of an AWS environment and make it easier to detect, troubleshoot, and investigate problems.

---

### Documentation

```text
docs/aws-observability.md
```

---

## References

- AWS CloudWatch documentation: https://docs.aws.amazon.com/AmazonCloudWatch/
- AWS CloudTrail documentation: https://docs.aws.amazon.com/awscloudtrail/
- AWS IAM documentation: https://docs.aws.amazon.com/IAM/
- Amazon SNS documentation: https://docs.aws.amazon.com/sns/
