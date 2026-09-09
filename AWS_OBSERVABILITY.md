# AWS Observability

## Introduction

I researched AWS Observability and learned that it is used to monitor AWS resources and applications.

It helps us understand whether our application is working properly and helps us find problems when something goes wrong.

The main things we can monitor are:

- Metrics
- Logs
- Traces
- Events

---

## 1. Amazon CloudWatch

Amazon CloudWatch is the main monitoring service in AWS.

It helps us monitor AWS resources such as EC2, databases, and applications.

### What I learned:

- It collects monitoring information.
- We can check resource performance.
- We can create alarms.
- We can view information using dashboards.

### Example:

We can use CloudWatch to check the CPU usage of an EC2 instance.

---

## 2. CloudWatch Metrics

Metrics are numbers that show the performance of a resource.

For example, an EC2 instance can have metrics such as:

- CPU utilization
- Network traffic
- Disk-related information

### What I learned:

Metrics help us understand how our AWS resources are performing.

---

## 3. CloudWatch Logs

CloudWatch Logs is used to collect and store logs.

Logs help us understand what is happening inside an application or system.

### What I learned:

If an application has an error, we can check its logs to understand what went wrong.

### Example:

Application logs from an EC2 server can be sent to CloudWatch Logs.

---

## 4. CloudWatch Alarms

CloudWatch Alarms are used to monitor a metric and alert us when it reaches a particular condition.

### Example:

If the CPU usage of an EC2 instance becomes very high, we can create an alarm for it.

### What I learned:

Alarms help us detect problems without continuously checking the resources manually.

---

## 5. CloudWatch Dashboards

CloudWatch Dashboards provide a visual way to monitor resources.

We can add different metrics to a dashboard and see them in one place.

### What I learned:

Dashboards make monitoring easier because we can see important information together.

---

## 6. AWS X-Ray

AWS X-Ray is used for tracing requests in an application.

It helps us understand how a request travels through different services.

### What I learned:

X-Ray can help find which part of an application is causing a problem or taking more time.

---

## 7. AWS CloudTrail

AWS CloudTrail records activities performed in an AWS account.

It helps us know what actions were performed and when they were performed.

### What I learned:

CloudTrail is useful for tracking and auditing activities in AWS.

### Example:

If someone makes a change to an AWS resource, CloudTrail can help us check the activity.

---

## 8. AWS Config

AWS Config is used to check and track the configuration of AWS resources.

### What I learned:

It helps us understand how our AWS resources are configured and keeps a history of configuration changes.

---

## 9. VPC Flow Logs

VPC Flow Logs are used to collect information about network traffic in a VPC.

### What I learned:

They can help us troubleshoot network connectivity problems and understand network traffic.

---

# Difference Between Logs, Metrics and Traces

| Type | Meaning |
|---|---|
| Metrics | Numbers that show performance |
| Logs | Detailed information about events |
| Traces | Shows the path of a request |

For example:

**Metrics** → CPU usage is 80%

**Logs** → Application shows an error

**Traces** → Shows which service caused a slow request

---

# What I Learned

From this research, I understood that observability helps DevOps engineers monitor applications and infrastructure.

I learned that:

- CloudWatch is mainly used for monitoring.
- Metrics help us check performance.
- Logs help us troubleshoot problems.
- Alarms help us detect problems.
- Dashboards help us view monitoring information.
- X-Ray is used for tracing requests.
- CloudTrail helps track AWS activities.
- AWS Config helps track resource configuration.
- VPC Flow Logs help with network troubleshooting.

---

# Conclusion

AWS provides different services for monitoring and understanding applications and infrastructure.
