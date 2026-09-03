# Task 8: AWS Observability Documentation

**Author:** P.Harish
**Date:** September 03, 2026
**Loom Video Link:** [https://www.loom.com/share/bea4e0a087824f1b99d15c718e05c534]

---

## Part 1: The 3 Pillars of Observability

Observability is the practice of understanding the internal health and behavior of a system by analyzing its outputs. It goes beyond basic monitoring, which primarily indicates whether a server or service is available. Observability provides deeper visibility into system performance, events, and request behavior.

The three primary pillars of observability are **Metrics**, **Logs**, and **Traces**.

### 1. Metrics

**What it is:**
Numerical data measured over time to represent the performance and health of a system.

**Examples:**
- CPU utilization is at 85%.
- There were 45 HTTP 500 errors in the last 5 minutes.

**Practical Application:**
Amazon CloudWatch was used to track EC2 CPU utilization and create custom metrics for application latency.

### 2. Logs

**What it is:**
Discrete, timestamped text records that describe events occurring within a system or application.

**Example:**

[ERROR] 14:02:11 - Database connection timeout for user ID 102.


**Practical Application:**
The CloudWatch Agent was installed to stream Apache web server logs directly into CloudWatch Log Groups for centralized viewing and analysis.

### 3. Traces

**What it is:**
The complete journey of a single user request as it moves through multiple services or components within an application.

**Example:**

User
↓
API Gateway
↓
Auth Service
↓
Database
↓
API Gateway
↓
User


Tracing helps identify where bottlenecks, delays, or errors occur during the request lifecycle.

**Explored:**
AWS X-Ray was explored to understand distributed tracing and how trace data can be used to analyze request flows.

---

## Part 2: Core AWS Native Tools Explored

### 1. Amazon CloudWatch — Metrics and Logs

Amazon CloudWatch is the central AWS service used for observability and monitoring.

The following CloudWatch capabilities were studied and used:
- Metrics
- Log Groups
- Metric Filters
- Alarms
- Custom Metrics

**Log Groups and Metric Filters**

Server logs were streamed into CloudWatch Log Groups for centralized access and analysis.

Metric Filters can be used to identify specific patterns in log data. For example, in a production environment, a Metric Filter could detect occurrences of the word `ERROR` and increment a metric such as:

App_Errors


This allows information contained in logs to be converted into measurable metrics.

**Alarms**

A CloudWatch Alarm was configured for the custom metric:

PaymentLatency


The configured threshold was:

PaymentLatency > 200 ms


To validate the alarm, a latency value of 500 ms was simulated. Since the value exceeded the configured threshold, the alarm transitioned to the **In Alarm** state.

### 2. AWS X-Ray — Traces

AWS X-Ray was explored to understand distributed tracing and application request analysis.

**Service Map**

X-Ray provides a Service Map that helps visualize the components involved in an application and their relationships. This can be used to identify potential bottlenecks or performance issues.

**What I Learned**

The following concepts were explored:
- Distributed tracing
- Request flow across services
- Trace data
- Service Map
- Identifying bottlenecks and errors

> **Note:** X-Ray was explored as part of the theoretical learning for this task. No hands-on X-Ray implementation was performed.

### 3. AWS CloudTrail — Audit Trail

AWS CloudTrail was explored as an auditing and security service.

CloudTrail records API activity within an AWS account and can be used for security, compliance, and operational investigations.

For example, if an EC2 instance is unexpectedly terminated, CloudTrail can be used to identify the corresponding API activity, such as:

TerminateInstances


This helps determine who performed the action and when it occurred.

---

## Part 3: Practical Implementation Summary

The practical implementation focused on applying AWS observability concepts using Amazon CloudWatch with a web application hosted on an EC2 instance.

### Architecture

| Component | Implementation |
|---|---|
| Compute | EC2 Instance |
| Operating System | Amazon Linux 2023 |
| Web Server | Apache HTTP Server |
| Monitoring Agent | CloudWatch Agent |
| System Metrics | CloudWatch |
| Server Logs | Apache access logs |
| Custom Application | FakePaymentApp |
| Custom Metric | PaymentLatency |

### Practical Components

**EC2 and Apache HTTP Server**

An EC2 instance running Amazon Linux 2023 was configured with an Apache HTTP Server to provide the web application environment.

**CloudWatch Agent**

The CloudWatch Agent was installed to collect system metrics and Apache access logs and forward them to Amazon CloudWatch.

**Custom Metrics**

A simulated FakePaymentApp was used to publish a custom `PaymentLatency` metric through the AWS CLI.

**CloudWatch Alarm**

A CloudWatch Alarm was configured to monitor the `PaymentLatency` metric.

The threshold was:

PaymentLatency > 200 ms


A value of 500 ms was simulated to verify the alarm behavior. The alarm transitioned to the **In Alarm** state when the threshold was exceeded.

---

## Part 4: Practical Observability Workflow

The practical implementation demonstrated the following observability workflow:

EC2 Instance
|
+---- System Metrics ----> CloudWatch Metrics
|
+---- Apache Logs -------> CloudWatch Log Groups
|
+---- PaymentLatency ----> CloudWatch Custom Metric
|
v
CloudWatch Alarm
|
v
In Alarm State


This practical implementation provided hands-on experience with collecting metrics and logs, creating custom metrics, and configuring CloudWatch alarms.

---

## Part 5: Key Learning Outcomes

- Metrics provide numerical measurements of system performance.
- Logs provide detailed records of system and application events.
- Traces provide visibility into the complete journey of a request.
- CloudWatch provides centralized monitoring for metrics and logs.
- CloudWatch Agent can collect system metrics and application logs from EC2.
- CloudWatch Log Groups provide centralized access to application and server logs.
- Metric Filters can convert log patterns into measurable metrics.
- CloudWatch Alarms can detect when a metric exceeds a configured threshold.
- Custom metrics can be used to monitor application-specific performance data such as PaymentLatency.
- AWS X-Ray provides distributed tracing and Service Map visualization.
- AWS CloudTrail provides visibility into AWS API activity for auditing and security purposes.

---

## Conclusion

This task provided an understanding of AWS observability using Amazon CloudWatch, AWS X-Ray, and AWS CloudTrail, with practical implementation focused on Amazon CloudWatch.

The three pillars of observability — Metrics, Logs, and Traces — were studied to understand how system health, application events, and request flows can be monitored.

Hands-on work was performed with CloudWatch using an EC2 instance, Apache HTTP Server, CloudWatch Agent, custom PaymentLatency metrics, and CloudWatch Alarms.

AWS X-Ray and CloudTrail were explored to understand distributed tracing and AWS API auditing respectively.