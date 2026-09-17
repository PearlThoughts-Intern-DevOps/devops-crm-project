# Task 8 – AWS Observability

## 1. Introduction

AWS Observability is the practice of collecting, monitoring, and analyzing information about applications, infrastructure, networks, and AWS account activity.

The main observability signals are:

- **Metrics** – Numerical measurements such as CPU utilization, latency, request counts, and error rates.
- **Logs** – Detailed records of application and system activity.
- **Traces** – End-to-end information showing how requests travel through distributed applications.
- **Events and configuration data** – Information about AWS activity, resource changes, and configuration state.

During this task, I explored the major AWS observability services and learned how they are used for monitoring, troubleshooting, performance analysis, security, and compliance.

---

# 2. Amazon CloudWatch

Amazon CloudWatch is the primary AWS monitoring and observability service. It provides monitoring capabilities for AWS resources, applications, and services.

### Main uses

- Monitor application and infrastructure performance.
- Collect and analyze metrics.
- Collect and analyze logs.
- Create alarms based on metric thresholds.
- Build monitoring dashboards.
- Monitor application health.

### CloudWatch Metrics

Metrics are numerical measurements used to understand the performance and health of resources and applications.

Examples include:

- CPU utilization
- Network traffic
- Request counts
- Latency
- Error rates

Metrics can be visualized through graphs and used as inputs for CloudWatch alarms.

**Console exploration:**  
The Metrics section displayed an IAM permission error:

`cloudwatch:ListMetrics`

This indicated that the provided IAM user did not have permission to list metrics.

### CloudWatch Logs

CloudWatch Logs provides centralized storage and analysis of log data.

Logs are organized into:

- **Log Groups** – Containers for related logs.
- **Log Streams** – Sequences of log events from a particular source.

CloudWatch Logs is useful for troubleshooting applications, investigating errors, and analyzing system activity.

**Console exploration:**  
The Logs section displayed an IAM permission error for:

`logs:DescribeLogGroups`

### CloudWatch Alarms

CloudWatch Alarms monitor metrics and compare them against configured thresholds.

Alarm states include:

- **OK** – The monitored condition is normal.
- **ALARM** – The configured threshold has been breached.
- **INSUFFICIENT_DATA** – There is not enough data to determine the state.

Alarms can be used to trigger actions or notifications when monitored conditions change.

**Console exploration:**  
The Alarms section indicated that the IAM user did not have permission to view alarms.

---

# 3. CloudWatch Application Signals

CloudWatch Application Signals is an application performance monitoring capability within CloudWatch.

It helps monitor application and service health and provides visibility into application performance.

### Main uses

- Monitor application performance.
- Monitor service health.
- Understand application dependencies.
- Identify performance problems.
- Define and monitor Service Level Objectives (SLOs).
- Work with related observability data such as metrics, logs, and traces.

### Console exploration

The Application Signals overview page was accessible. The account currently showed no discovered or instrumented services.

The Services section also displayed an error while loading service information.

No application instrumentation or monitoring resources were created.

---

# 4. AWS CloudTrail

AWS CloudTrail records AWS account activity and API activity.

It helps answer questions such as:

- Who performed an action?
- What action was performed?
- When was it performed?
- Where did the request originate?

### Main uses

- Auditing AWS activity.
- Security investigations.
- Troubleshooting.
- Compliance and governance.
- Tracking changes made through AWS APIs and the AWS Console.

### Console exploration

CloudTrail Event History was accessible during exploration.

Event History provides recent AWS management events, including activity from the previous 90 days.

The account currently displayed **0 events**.

No CloudTrail configuration was created during this task.

---

# 5. AWS X-Ray

AWS X-Ray is a distributed tracing service used to analyze and debug applications, especially distributed applications and microservices.

It provides an end-to-end view of requests as they move through different application components and services.

### Main uses

- Trace requests across services.
- Identify performance bottlenecks.
- Troubleshoot application errors.
- Find root causes of performance problems.
- Understand relationships between application components.

### Service Map

X-Ray can provide a service map that helps visualize relationships between services involved in application requests.

### Console exploration

The X-Ray Traces page was explored. The console described X-Ray as a service for analyzing and debugging distributed applications and identifying the root cause of performance issues and errors.

No tracing resources or application instrumentation were created.

---

# 6. AWS Config

AWS Config records and evaluates the configuration of AWS resources.

It helps organizations understand how resources are configured and how their configurations change over time.

### Main uses

- Track resource configuration changes.
- Maintain configuration history.
- Evaluate resource configurations against compliance rules.
- Support security and compliance auditing.
- Troubleshoot configuration-related problems.

### Console exploration

The AWS Config page was accessible, but the account displayed an IAM permission error for:

`config:DescribeConfigurationRecorders`

No AWS Config recorder or configuration rules were created.

---

# 7. VPC Flow Logs

VPC Flow Logs are a network observability feature that captures information about IP traffic going to and from network interfaces in a VPC.

### Main uses

- Network troubleshooting.
- Security investigations.
- Understanding accepted and rejected traffic.
- Identifying unusual network activity.
- Investigating connectivity problems.

Flow Log data can be sent to services such as CloudWatch Logs or Amazon S3 for further analysis.

---

# 8. Amazon Managed Service for Prometheus

Amazon Managed Service for Prometheus is a fully managed monitoring service compatible with the open-source Prometheus project.

It is particularly useful for containerized and Kubernetes-based environments.

### Main uses

- Collect and query metrics.
- Monitor containers and Kubernetes environments.
- Use Prometheus-compatible metrics.
- Query monitoring data using PromQL.
- Avoid managing Prometheus infrastructure manually.

---

# 9. Amazon Managed Grafana

Amazon Managed Grafana is a fully managed Grafana service used to visualize and analyze monitoring data.

It can connect to different data sources and provide centralized observability dashboards.

### Main uses

- Create monitoring dashboards.
- Visualize metrics and observability data.
- Analyze data from multiple sources.
- Provide centralized monitoring views.

---

# 10. Amazon OpenSearch Service

Amazon OpenSearch Service can be used to search, analyze, and visualize large amounts of operational and observability data.

It can help analyze logs, traces, and metrics to investigate application and infrastructure problems.

### Main uses

- Log analysis.
- Observability data analysis.
- Searching large datasets.
- Creating visualizations and dashboards.
- Investigating application and infrastructure issues.

---

# 11. Important Observability Signals

| Signal | Purpose | Example |
|---|---|---|
| **Metrics** | Numerical measurements | CPU utilization, latency |
| **Logs** | Detailed activity records | Application error message |
| **Traces** | End-to-end request tracking | Request moving through microservices |

Using these signals together provides a more complete understanding of system behavior.

---

# 12. How AWS Observability Services Work Together

A simplified observability flow is:

**Applications / AWS Resources / Networks**

↓

**Metrics + Logs + Traces + Events + Configuration Data**

↓

**CloudWatch / X-Ray / CloudTrail / AWS Config / VPC Flow Logs / Prometheus**

↓

**Analysis + Dashboards + Alerts + Troubleshooting**

Services such as Amazon Managed Grafana and Amazon OpenSearch Service can provide additional visualization and analysis capabilities.

---

# 13. Comparison of Major Services

| Service | Primary Purpose |
|---|---|
| **Amazon CloudWatch** | General monitoring, metrics, logs, alarms, and dashboards |
| **CloudWatch Application Signals** | Application performance monitoring |
| **AWS CloudTrail** | AWS API and account activity auditing |
| **AWS X-Ray** | Distributed application tracing |
| **AWS Config** | Resource configuration and compliance |
| **VPC Flow Logs** | Network traffic visibility |
| **Amazon Managed Service for Prometheus** | Prometheus-compatible metrics monitoring |
| **Amazon Managed Grafana** | Monitoring data visualization |
| **Amazon OpenSearch Service** | Search and analysis of observability data |

---

# 14. IAM Permission Limitations Observed

During console exploration, several sections could not be fully viewed because the provided IAM user had restricted permissions.

The following limitations were observed:

- CloudWatch Metrics – `cloudwatch:ListMetrics` denied.
- CloudWatch Logs – `logs:DescribeLogGroups` denied.
- CloudWatch Alarms – Permission to view alarms was denied.
- AWS Config – `config:DescribeConfigurationRecorders` denied.
- CloudWatch Application Signals Services – Service information failed to load.

These restrictions did not prevent understanding the purpose and usage of the services. No permissions were modified and no resources were created to bypass the limitations.

---

# 15. Key Learnings

Through this task, I learned that AWS Observability is not limited to monitoring individual metrics. Different services provide visibility into different aspects of a system:

- **CloudWatch** provides general monitoring and observability.
- **Application Signals** focuses on application performance.
- **CloudTrail** provides visibility into AWS account and API activity.
- **X-Ray** provides distributed tracing.
- **AWS Config** provides resource configuration and compliance visibility.
- **VPC Flow Logs** provide network traffic visibility.
- **Prometheus** provides metrics monitoring, especially for containerized environments.
- **Managed Grafana** provides visualization and dashboards.
- **OpenSearch** provides search and analysis of observability data.

Combining metrics, logs, traces, events, and configuration information helps teams detect issues, troubleshoot problems, understand performance, and improve system reliability.

---

# 16. Conclusion

AWS provides a wide range of observability services that work together to provide visibility into applications, infrastructure, networks, and AWS account activity.

The main takeaway from this task is that effective observability comes from combining multiple types of telemetry rather than relying on a single monitoring tool.

No AWS resources or observability configurations were created during this task. The work focused on understanding the services and exploring the AWS Console within the permissions provided by the IAM account.

