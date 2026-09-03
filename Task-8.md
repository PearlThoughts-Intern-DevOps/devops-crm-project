# Task 8: AWS Observability

## Objective

Explore AWS observability services, understand their purpose and usage, and document the key concepts and DevOps use cases learned.

The following five services were studied:
1. Amazon CloudWatch
2. AWS CloudTrail
3. Amazon Managed Grafana
4. Amazon Managed Service for Prometheus
5. AWS X-Ray

---

# 1. Amazon CloudWatch

Amazon CloudWatch is an AWS monitoring and observability service used to monitor AWS resources and applications.

It provides capabilities such as:

- Metrics
- Logs
- Alarms
- Dashboards

## Key Concepts

### Metrics

Metrics are numerical measurements collected over time.

Examples include:

- CPU utilization
- Network activity
- Request count
- Error rate
- Application performance measurements

### Logs

CloudWatch Logs can collect and centralize logs from applications and AWS resources.

Logs can be searched and analyzed to investigate:

- Errors
- Exceptions
- Timeouts
- Application failures

### Alarms

CloudWatch alarms allow thresholds to be defined for metrics.

Example:

```text
IF CPU > 80%
FOR 5 minutes
THEN trigger an alarm
```

### Dashboards

CloudWatch dashboards provide a centralized view of important monitoring information.

---

# 2. AWS CloudTrail

AWS CloudTrail is an auditing and governance service that records activity in an AWS account. Actions taken by a user, role, or an AWS service are recorded as `events` in CloudTrail.

It records actions performed by:

- Users
- IAM roles
- AWS services

Events include actions taken in the AWS Management Console, AWS Command Line Interface, and AWS SDKs and APIs.

## Key Concepts

### Management Events

Management events record management operations on AWS resources.

Examples:

```text
CreateInstance
TerminateInstance
CreateSecurityGroup
AttachRolePolicy
```

These events are useful for understanding changes made to AWS infrastructure.

### Data Events

Data events provide visibility into resource-level data operations when configured for supported services.

```text
Management event → managing an AWS resource
Data event       → accessing/operating on data
```

### Event History

CloudTrail provides Event history that can be searched and filtered to investigate AWS activity.

### Trails

A CloudTrail trail can deliver events to destinations such as:

- Amazon S3
- CloudWatch Logs
- Amazon EventBridge

Trails are useful when maintaining an ongoing audit record.

### CloudTrail Insights

CloudTrail Insights can help identify unusual patterns in API activity, such as unusual API call rates or error rates.

---

# 3. Amazon Managed Grafana

Amazon Managed Grafana is a fully managed Grafana service on AWS used to visualize and analyze observability data.

It can connect to different data sources and present their information through dashboards.

## Key Concepts

### Grafana Workspace

A workspace provides the managed Grafana environment where dashboards, data sources, users, and permissions can be configured.

### Data Sources

Grafana can connect to different observability data sources.

Examples relevant to AWS include:

- Amazon CloudWatch
- Amazon Managed Service for Prometheus
- Other supported data sources

### Dashboards

Grafana dashboards can combine multiple metrics and visualizations into a single monitoring view.

Example:

```text
Application Dashboard

CPU Usage       82%
Request Rate    820 req/min
Error Rate      2%
Latency         240 ms
```
---

# 4. Amazon Managed Service for Prometheus

Amazon Managed Service for Prometheus (AMP) is a fully managed monitoring service based on the open-source Prometheus project.

It is designed for collecting, storing, and querying Prometheus-compatible time-series metrics.

AMP provides a managed AWS environment for Prometheus metrics.

## Key Concepts

### Time-Series Metrics

Prometheus works with measurements that change over time.

Example:

```text
http_requests_total

10:00 -> 1500
10:01 -> 1520
```

### Metrics Endpoint

Applications can expose Prometheus-compatible metrics through an endpoint such as:

```text
/metrics
```


### PromQL

PromQL is Prometheus Query Language. It is used to query and analyze Prometheus metrics.

```text
Prometheus metrics
       ↓
     PromQL
       ↓
Metric query / analysis
```

### Application and Container Monitoring

Prometheus is particularly useful for application-level and container-oriented metrics.

Examples include:

```text
http_requests_total
http_request_duration
container_cpu_usage
container_memory_usage
```

## AMP and Grafana

AMP and Managed Grafana can work together:

`AMP` handles the Prometheus metrics side, while `Grafana` provides visualization.

---

# 5. AWS X-Ray

AWS X-Ray is an application tracing service used to understand how requests travel through application components.

It is especially useful for distributed applications and microservices.

## Distributed Tracing

A trace represents the journey of an individual request through different application components.

Example:

```text
User Request
     ↓
Load Balancer
     ↓
Application
     ↓
API
     ↓
Database
     ↓
Response
```

X-Ray helps visualize and analyze this request path.

### Trace

A trace represents the overall request.

Example:

```text
Trace
Total duration: 1070 ms
```

### Segment

A segment represents work performed by a particular component within the trace.

Example:

```text
API           → 100 ms
Database      → 700 ms
External API  → 270 ms
```

This helps identify which component contributes most to latency.

### Service Map

X-Ray can provide a service map showing relationships between application components.


This helps understand dependencies, request flow, errors, and latency.


---

# 6. Comparison of the Five Services

| Service | Primary Purpose | Key Question |
|---|---|---|
| **Amazon CloudWatch** | Metrics, logs, alarms, monitoring | What is happening? |
| **AWS CloudTrail** | AWS activity auditing | Who did what? |
| **Amazon Managed Grafana** | Visualization and analysis | How do I visualize the data? |
| **Amazon Managed Service for Prometheus** | Prometheus-compatible metrics | What application/container metrics are available? |
| **AWS X-Ray** | Distributed tracing | Where did the request go? |

---

# 7. How the Services Complement Each Other

These services are not direct replacements for each other. They address different observability requirements.

```text
                         AWS APPLICATION
                               │
                ┌──────────────┼──────────────┐
                ↓              ↓              ↓
             Metrics          Logs          Traces
                │              │              │
                ↓              ↓              ↓
           CloudWatch      CloudWatch       X-Ray
                │
                │
                ↓
             Prometheus
                │
                ↓
          Managed Grafana
                │
                ↓
            Dashboards


                    AWS ACCOUNT ACTIVITY
                            │
                            ↓
                       CloudTrail
                            │
                            ↓
                     Audit / Investigation
```

The important distinction is:

- **CloudWatch:** Monitoring, metrics, logs, alarms, and dashboards.
- **CloudTrail:** AWS account/API activity auditing.
- **Managed Grafana:** Visualization and analysis.
- **Managed Prometheus:** Prometheus-compatible time-series metrics.
- **X-Ray:** Distributed request tracing.

---

# 8. Overall Learning

Through this task, I learned the role of different AWS observability services and how they address different monitoring requirements.

The main concepts I learned are:

1. **CloudWatch** provides broad AWS monitoring through metrics, logs, alarms, and dashboards.
2. **CloudTrail** provides an audit trail of activity within an AWS account.
3. **Managed Grafana** provides dashboards and visualization for supported observability data sources.
4. **Managed Prometheus** provides a managed environment for Prometheus-compatible metrics and PromQL-based querying.
5. **X-Ray** provides distributed tracing for understanding request paths, dependencies, latency, and errors.

The main observability concepts can be remembered as:

```text
CloudWatch  → Monitoring
CloudTrail  → Auditing
Prometheus  → Metrics
Grafana     → Visualization
X-Ray       → Tracing
```

---

# 9. Conclusion

AWS provides multiple observability services that work together to provide different views of systems and applications.

CloudWatch helps monitor infrastructure and application behavior, CloudTrail provides visibility into AWS account activity, Managed Prometheus handles Prometheus-compatible metrics, Managed Grafana provides visualization, and X-Ray provides distributed tracing.

Understanding the difference between these services helps DevOps engineers choose the appropriate observability tool based on whether their need.

## Thank you!

