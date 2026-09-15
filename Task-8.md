# Task 8: AWS Observability

**Name:** Mujtaba Shaikh
**Date:** 03 September 2026

## Introduction

AWS Observability helps us monitor AWS resources and applications, understand system performance, track AWS account activities, and identify application problems.

In this task, I explored the main AWS observability services:

* Amazon CloudWatch
* AWS CloudTrail
* AWS X-Ray

I also explored external observability tools such as Prometheus and Grafana.

---

## 1. Amazon CloudWatch

**Amazon CloudWatch** is an AWS monitoring and observability service. It helps us monitor AWS resources and applications using metrics, logs, alarms, and dashboards.

### CloudWatch Metrics

Metrics are measurements that show the performance and usage of resources.

Examples:

* EC2 CPU utilization
* Network traffic
* Request count
* Application performance metrics

For example, if an EC2 instance is using 70% or more CPU, we can monitor this using CloudWatch metrics.

### CloudWatch Logs

CloudWatch Logs are used to collect and view logs from applications, servers, and AWS services.

Logs can help us identify:

* Application errors
* System issues
* Failed requests
* Other application or service activities

### CloudWatch Alarms

CloudWatch Alarms monitor metrics and can take action when a defined threshold is crossed.

For example:

```text
EC2 CPU Utilization > 70%
            ↓
     CloudWatch Alarm
            ↓
    Send Notification
```

We can use Amazon SNS with CloudWatch alarms to send notifications such as email alerts.

### CloudWatch Dashboards

CloudWatch Dashboards provide a visual way to monitor resources and applications in one place.

For example, a dashboard can display:

* EC2 CPU utilization
* Network usage
* Request metrics
* Other important monitoring information

### Usage of CloudWatch

CloudWatch can be used to:

* Monitor AWS resources
* Monitor application performance
* View logs
* Monitor metrics
* Create alerts using alarms
* Create monitoring dashboards
* Troubleshoot application and infrastructure issues

---

## 2. AWS CloudTrail

**AWS CloudTrail** is an AWS service used to record and track activities performed in an AWS account.

It helps us understand:

* Who performed an action
* What action was performed
* When the action happened
* Which AWS service or resource was involved
* Other details about the API request

### CloudTrail Event History

CloudTrail provides **Event History**, where we can view recent AWS activity and API events.

For example, if someone performs an action on an EC2 instance, CloudTrail can record the related API activity.

Examples of activities that can be tracked include:

* Creating an EC2 instance
* Stopping an EC2 instance
* Deleting an S3 resource
* Changing a Security Group
* Changing IAM policies
* Other supported AWS API activities

### Usage of CloudTrail

CloudTrail is mainly used for:

* AWS account activity tracking
* Auditing
* Security monitoring
* Investigating suspicious activity
* Troubleshooting AWS resource changes

For example, if an EC2 instance was stopped and we don't know who stopped it, we can check CloudTrail Event History to identify the user or role, time, and API action.

### CloudWatch vs CloudTrail

The main difference is:

**CloudWatch → Monitor system and application performance**

**CloudTrail → Track AWS account activity**

For example:

* CloudWatch can show that EC2 CPU utilization is high.
* CloudTrail can show who stopped or modified the EC2 instance.

---

## 3. AWS X-Ray

**AWS X-Ray** is an application tracing service. It helps us understand how requests travel through different parts of an application.

For example:

```text
User
 ↓
Frontend
 ↓
Backend
 ↓
Database
 ↓
Response
```

X-Ray can help us understand the request flow and identify performance problems, errors, and latency.

### Trace Map

X-Ray provides a **Trace Map** that can show the services involved in application requests and their relationships.

If an application request is taking too much time, X-Ray can help identify where the delay is occurring.

For example:

```text
Frontend   → 100 ms
Backend    → 200 ms
Database   → 4 seconds
```

In this example, the database is taking most of the time, so it can be investigated as the possible cause of the delay.

### Usage of X-Ray

X-Ray can be used to:

* Trace application requests
* Understand request flow
* Identify latency
* Find performance problems
* Identify errors
* Understand service dependencies

The application or services need to be configured to send tracing data to X-Ray. If there is no tracing data, the Trace Map may show no services.

---

## 4. External Observability Tools

Apart from AWS-native observability services, external tools such as **Prometheus and Grafana** can also be used for monitoring and observability.

### Prometheus

**Prometheus** is an open-source monitoring and metrics collection system.

It is mainly used to:

* Collect metrics
* Store time-series metrics
* Query metrics
* Monitor applications and infrastructure

For example, Prometheus can collect CPU, memory, network, and application metrics.

### Grafana

**Grafana** is an open-source visualization and dashboarding tool.

It can be used to:

* Visualize metrics
* Create monitoring dashboards
* Display data from different sources
* Analyze system and application performance

Prometheus and Grafana are commonly used together:

```text
Application / Infrastructure
          ↓
      Prometheus
          ↓
      Collect Metrics
          ↓
        Grafana
          ↓
   Visual Dashboards
```

Prometheus and Grafana are **not AWS-native services**. They are external/open-source observability tools that can be integrated with AWS infrastructure.

AWS also provides managed services for these technologies, including **Amazon Managed Service for Prometheus** and **Amazon Managed Grafana**.

---

## Conclusion

In this task, I explored AWS observability and understood how different services are used for different purposes.

* **CloudWatch** is mainly used for monitoring resources and applications through metrics, logs, alarms, and dashboards.
* **CloudTrail** is used to record and track activities and API events performed in an AWS account.
* **X-Ray** is used for application request tracing and helps identify latency, errors, and performance problems.
* **Prometheus and Grafana** are external observability tools that can be used with AWS for metrics collection and visualization.

Overall, I learned how AWS observability helps with monitoring, troubleshooting, performance analysis, security auditing, and maintaining reliable applications.


