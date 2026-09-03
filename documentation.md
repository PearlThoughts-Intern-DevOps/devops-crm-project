# AWS Observability Services – Task Documentation

## 1. What is Observability in AWS?

**Observability** is the ability to understand the internal state and behavior of an application or infrastructure by analyzing its **metrics, logs, and traces**.

In AWS, observability helps DevOps engineers:

* Detect problems and failures
* Understand application performance
* Troubleshoot issues
* Monitor user experience
* Analyze system behavior
* Identify the root cause of incidents

---

## 2. Observability vs Monitoring

| Monitoring                                      | Observability                                                                 |
| ----------------------------------------------- | ----------------------------------------------------------------------------- |
| Checks whether a system is working              | Helps understand why a system is behaving a certain way                       |
| Mainly focuses on predefined metrics and alerts | Uses metrics, logs, and traces together                                       |
| Answers **"What is wrong?"**                    | Answers **"What is wrong, why, and where?"**                                  |
| Example: CPU is above 80%                       | Example: CPU increased because a particular service is receiving high traffic |

> **In short:** Monitoring detects problems, while observability helps investigate and understand those problems.

---

## 3. AWS Observability Services – Overview

| AWS Service                               | Main Purpose                                |
| ----------------------------------------- | ------------------------------------------- |
| **Amazon CloudWatch**                     | Metrics, monitoring, alarms, and dashboards |
| **CloudWatch Logs**                       | Collect and store logs                      |
| **CloudWatch Logs Insights**              | Query and analyze logs                      |
| **CloudWatch Application Signals**        | Application performance monitoring          |
| **CloudWatch Synthetics**                 | Automated application and website testing   |
| **AWS X-Ray**                             | Distributed request tracing                 |
| **Amazon Managed Service for Prometheus** | Monitor metrics using Prometheus            |
| **Amazon Managed Grafana**                | Create observability dashboards             |
| **Amazon OpenSearch Service**             | Log search and analytics                    |
| **AWS Health Dashboard**                  | AWS service and account health information  |
| **AWS CloudTrail**                        | Track AWS API and user activities           |
| **AWS Config**                            | Track resource configuration and changes    |

---

## 4. AWS Observability Services – Explanation

### 4.1 Amazon CloudWatch

1. Collects metrics from AWS resources and applications.
2. Stores and analyzes monitoring data.
3. Creates alarms when conditions are met.
4. Provides dashboards for visualization.

**Use Case:**
A user can monitor an EC2 instance and receive an alert when CPU usage goes above 80%.

---

### 4.2 CloudWatch Logs

1. Collects application and system logs.
2. Stores logs in log groups and log streams.
3. Allows logs to be searched and analyzed.

**Use Case:**
A developer can check application logs to find why an API is returning errors.

---

### 4.3 CloudWatch Logs Insights

1. Provides a query language for CloudWatch Logs.
2. Searches large amounts of log data.
3. Helps quickly find errors and specific events.

**Use Case:**
A DevOps engineer can search thousands of logs and find all `ERROR` messages.

---

### 4.4 CloudWatch Application Signals

1. Monitors application performance.
2. Tracks important metrics such as latency, errors, and availability.
3. Helps identify unhealthy application components.

**Use Case:**
A user can identify which microservice is causing slow application responses.

---

### 4.5 CloudWatch Synthetics

1. Creates automated tests called **canaries**.
2. Periodically tests websites, APIs, and endpoints.
3. Detects availability and functionality problems.

**Use Case:**
A company can automatically check its website every few minutes and receive an alert if it stops working.

---


### 4.6 AWS X-Ray

1. Tracks requests across distributed applications.
2. Shows the path of a request between services.
3. Helps identify latency and failures.

**Use Case:**
A DevOps engineer can find which microservice or database is making an API request slow.

---

### 4.7 Amazon Managed Service for Prometheus

1. Provides managed Prometheus monitoring.
2. Collects time-series metrics.
3. Commonly used with Kubernetes and Amazon EKS.

**Use Case:**
A DevOps engineer can monitor CPU, memory, and application metrics from an EKS cluster.

---

### 4.8 Amazon Managed Grafana

1. Provides managed Grafana dashboards.
2. Connects to data sources such as Prometheus and CloudWatch.
3. Visualizes metrics and observability data.

**Use Case:**
A user can create a dashboard showing Kubernetes CPU, memory, traffic, and error metrics.

---

### 4.9 Amazon OpenSearch Service

1. Stores and searches large amounts of data.
2. Can be used for log analytics.
3. Provides dashboards for analyzing operational data.

**Use Case:**
A company can centralize application logs and search them to troubleshoot production issues.

---


### 4.10 AWS Health Dashboard

1. Provides information about AWS service health.
2. Shows AWS service events that may affect resources.
3. Provides account-specific health information.

**Use Case:**
A user can check whether an AWS service outage is affecting their application.

---

### 4.11 AWS CloudTrail

1. Records AWS API activity.
2. Shows who performed an action, what happened, and when.
3. Helps with auditing and security investigation.

**Use Case:**
If an EC2 instance is accidentally deleted, CloudTrail can help identify who performed the action.

---

### 4.12 AWS Config

1. Records AWS resource configurations.
2. Tracks configuration changes over time.
3. Helps identify compliance and configuration issues.

**Use Case:**
A user can find out when a security group's configuration was changed.

---

## 5. Overall What I Learned

From this task, I learned that **AWS Observability is a complete approach to understanding applications and infrastructure**, not just checking whether servers are running.

I learned the importance of:

* **Metrics** → CloudWatch and Prometheus
* **Logs** → CloudWatch Logs and OpenSearch
* **Traces** → AWS X-Ray
* **Application monitoring** → Application Signals
* **User experience** → CloudWatch RUM
* **Automated testing** → CloudWatch Synthetics
* **Visualization** → Grafana and CloudWatch Dashboards
* **Auditing** → CloudTrail
* **Configuration tracking** → AWS Config
* **Anomaly detection** → DevOps Guru

### Conclusion

The main learning is that **monitoring tells us that something is wrong, while observability helps us understand what happened, where it happened, and why it happened.**

These services together help DevOps teams **monitor, troubleshoot, and maintain reliable AWS applications**.

