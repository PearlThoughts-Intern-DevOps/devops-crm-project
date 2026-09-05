# AWS Observability Services

## 1. Introduction

Observability is the ability to understand what is happening inside an
application or infrastructure by examining the telemetry it produces. A
practical way to understand observability is through three core pillars:

- **Metrics and monitoring** tell us what is happening.
- **Logs** help explain what happened and why by showing recorded events.
- **Traces** show where a request travelled and where time was spent or errors
  occurred across components.

For an AWS-hosted CRM application, these pillars can be combined with
visualization, Prometheus-compatible monitoring, and audit logging to build a
complete operational view.

## 2. Amazon CloudWatch

Amazon CloudWatch is AWS's main monitoring and observability service. It
collects, monitors, and visualizes operational information from AWS resources
and applications.

### 2.1 CloudWatch Metrics

A metric is a time-series measurement of a resource or application.

Examples for an EC2-hosted CRM application include:

- `CPUUtilization` — percentage of EC2 CPU being used.
- `NetworkIn` and `NetworkOut` — network traffic entering or leaving the
  instance.
- EBS read/write metrics — activity of attached EBS volumes.
- Custom application metrics — number of CRM requests or failed operations.

A metric consists of values recorded over time. This allows us to answer
questions such as: **Is CPU usage becoming unusually high?**

#### Namespace

A namespace is a container or category that groups related CloudWatch metrics.

Examples include:

- `AWS/EC2` — EC2 metrics.
- `AWS/RDS` — RDS metrics.
- `AWS/EBS` — EBS metrics.
- `CRM/Application` — a possible custom namespace for CRM metrics.

```text
AWS/EC2
├── CPUUtilization
├── NetworkIn
└── NetworkOut
```

#### Dimensions

A dimension identifies the resource associated with a metric. For example, the
`InstanceId` dimension distinguishes the `CPUUtilization` metric of one EC2
instance from another.

#### Statistics

CloudWatch can aggregate datapoints using statistics such as:

- Average
- Minimum
- Maximum
- Sum
- SampleCount

For CPU monitoring, Average is useful for general utilization, while Maximum
can reveal short spikes.

#### Period

The period determines the time interval over which CloudWatch aggregates
datapoints, such as one minute or five minutes.

### 2.2 CloudWatch Alarms

A CloudWatch alarm watches a metric or supported query and changes state when
its configured condition is met.

Example:

| Setting | Value |
| --- | --- |
| Metric | `CPUUtilization` |
| Threshold | Greater than 80% |
| Period | 5 minutes |
| Datapoints to alarm | 2 out of 3 |

This alarm enters the `ALARM` state when at least two of the three evaluated
datapoints breach the threshold.

Typical alarm states are:

- `OK` — the condition is not breaching.
- `ALARM` — the configured threshold or condition is breaching.
- `INSUFFICIENT_DATA` — enough data is not available to determine the state.

Alarm actions can connect to services such as Amazon SNS for notifications or
Amazon EC2 Auto Scaling for scaling actions.

#### Datapoints to alarm

If an alarm uses “2 out of 3,” CloudWatch evaluates three datapoints and
requires at least two of them to breach the threshold before entering `ALARM`.
This approach helps prevent one temporary spike from creating unnecessary
alerts.

#### Missing-data treatment

CloudWatch lets us decide how missing datapoints affect alarm evaluation. The
correct choice depends on whether missing data is normal or indicates a failure
for that particular metric.

### 2.3 CloudWatch Logs

Metrics tell us that a problem exists; logs often provide the details needed to
investigate it.

A log event contains a timestamp and message. Related events from the same
source form a log stream, and log streams are organized inside a log group.

```text
Log Group: /crm/application
├── Log Stream: ec2-instance-1
│   ├── Application started
│   ├── Request received
│   └── Database connection error
└── Log Stream: ec2-instance-2
```

For an EC2-hosted CRM application, logs might include:

- application logs;
- Docker or container logs;
- Nginx access and error logs;
- operating-system logs;
- authentication errors; and
- database connection failures.

The CloudWatch Agent can collect additional host-level metrics and logs from
EC2 instances and on-premises servers.

#### CloudWatch Logs Insights

CloudWatch Logs Insights lets engineers query log data to investigate errors,
patterns, and operational problems.

```text
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

This query helps answer: **What were the 20 most recent application errors?**

### 2.4 CloudWatch Dashboards

A dashboard combines graphs, metrics, alarms, and other operational information
into a single visual view.

A CRM operations dashboard could show:

```text
┌─────────────────────────────────────────────┐
│            CRM Operations Dashboard         │
├──────────────────────┬──────────────────────┤
│ CPU Utilization      │ Memory Usage         │
│ Network Traffic      │ Disk Usage           │
│ Application Errors   │ Request Count        │
│ Alarm Status         │ Application Health   │
└──────────────────────┴──────────────────────┘
```

Dashboards are particularly useful during deployments and incident
troubleshooting because important signals can be viewed together.

## 3. AWS X-Ray — Distributed Tracing

AWS X-Ray provides distributed tracing. It collects information about requests
handled by an application and can show downstream calls to AWS resources,
microservices, databases, and web APIs.

Metrics might tell us that the CRM application is slow. Logs might report that
a database operation took longer than expected. Tracing shows the request path:

```text
User Request
    |
    v
Load Balancer
    |
    v
CRM Application
    |
    +------> Database
    |
    +------> External API
```

A trace helps determine which component introduced latency or returned an
error.

### Important tracing concepts

- **Trace:** the end-to-end journey of a request through the system.
- **Segment:** tracing information produced by a component handling the request.
- **Subsegment:** more detailed information about work performed within a
  segment, such as a database or external API call.

### Why X-Ray is useful

X-Ray helps with:

- finding slow dependencies;
- investigating request failures;
- understanding distributed application dependencies;
- locating latency bottlenecks; and
- performing root-cause analysis.

AWS also supports OpenTelemetry-based instrumentation through AWS Distro for
OpenTelemetry (ADOT). ADOT can collect telemetry and send it to AWS
observability services, including X-Ray.

## 4. Amazon Managed Service for Prometheus

Amazon Managed Service for Prometheus (AMP) is a managed,
Prometheus-compatible monitoring service designed to ingest, store, and query
Prometheus metrics at scale.

Instead of operating all Prometheus backend infrastructure, AWS manages the
underlying service. AMP is particularly useful for:

- Amazon EKS;
- Amazon ECS;
- Kubernetes applications;
- microservices; and
- applications exposing Prometheus-compatible metrics.

### Core architecture

```text
Application / Containers
          |
          | Prometheus metrics
          v
Collector / Scraper
          |
          | Remote write
          v
Amazon Managed Service for Prometheus
          |
          | PromQL queries
          v
Amazon Managed Grafana
```

### Workspace

An AMP workspace is a logical environment used to ingest, store, and query
Prometheus metrics.

### PromQL

Prometheus uses PromQL, the Prometheus Query Language, to query time-series
metrics. For example, the following conceptual query calculates the per-second
request rate over five minutes:

```promql
rate(http_requests_total[5m])
```

### Why use AMP?

- Prometheus-compatible APIs and data model.
- Managed scalability and availability.
- PromQL querying.
- Integration with Amazon Managed Grafana.
- Support for high-volume container and Kubernetes metrics.
- Reduced operational burden compared with managing a Prometheus backend.

AMP does not automatically instrument every application. A collector or scraper
must still discover metric endpoints and send their data to the AMP workspace.

## 5. Amazon Managed Grafana

Amazon Managed Grafana (AMG) is AWS's managed service for running Grafana
workspaces. Grafana is primarily used to query, visualize, correlate, and
explore telemetry through dashboards.

AWS manages the provisioning, scaling, and maintenance of the Grafana
workspace. A workspace can connect to AWS data sources including CloudWatch,
AWS X-Ray, and AMP, as well as other supported sources.

### Example architecture

```text
CloudWatch Metrics ─────────┐
CloudWatch Logs ────────────┤
AWS X-Ray ──────────────────┼──> Amazon Managed Grafana ──> Dashboards
AMP / Prometheus Metrics ───┘
```

### What Grafana adds

CloudWatch already provides dashboards, but Grafana is valuable when teams
need:

- rich, flexible dashboards;
- multiple data sources in one visualization platform;
- Prometheus and PromQL-based dashboards;
- shared operational dashboards; and
- correlation of metrics, logs, and traces from supported sources.

### Workspace

A Grafana workspace is a logically isolated, managed Grafana server in which
dashboards and visualizations are created.

### Typical workflow

1. Create an Amazon Managed Grafana workspace.
2. Configure authentication and authorization.
3. Add CloudWatch, AMP, or another supported data source.
4. Create dashboard panels.
5. Define and run queries.
6. Visualize system and application health.

Grafana is generally a visualization and analysis layer. The connected data
source, such as CloudWatch or AMP, remains the main telemetry store.

## 6. AWS CloudTrail — Account Activity and Audit Trail

CloudTrail is different from application monitoring. It records AWS account
activity and is mainly used for auditing, governance, security investigations,
compliance, and operational troubleshooting.

It can record actions made through:

- the AWS Management Console;
- AWS CLI;
- AWS SDKs;
- AWS APIs; and
- AWS services acting in an account.

A CloudTrail event can help answer:

- **Who** performed the action?
- **What** action was performed?
- **When** did it happen?
- **Which** AWS resource was affected?
- **From where** did the request originate?

### Example scenario

Suppose an EC2 instance unexpectedly stops:

- CloudWatch might show that metrics stopped or the instance became unhealthy.
- CloudTrail can show whether an EC2 stop API request occurred and which
  identity initiated it.

### Important CloudTrail concepts

#### Event history

CloudTrail Event history provides searchable recent management-event history in
a Region. AWS documents that it covers the past 90 days of management events.

#### Trail

A trail provides ongoing delivery of selected CloudTrail events, commonly to an
Amazon S3 bucket. It can also deliver events to CloudWatch Logs and integrate
with EventBridge.

#### Event types

CloudTrail event categories include:

- management events;
- data events;
- network activity events; and
- Insights events.

Not every category is logged by default, so the trail configuration matters.
High-volume categories should be enabled only for a clear use case.

#### CloudTrail Lake

CloudTrail Lake provides event data stores and SQL-based querying for AWS
activity data. It is useful for deeper investigations, auditing, and long-term
analysis.

## 7. CloudWatch vs. CloudTrail

| Amazon CloudWatch | AWS CloudTrail |
| --- | --- |
| Focuses on resource/application observability and operations | Focuses on AWS account/API activity and auditing |
| Monitors metrics, logs, alarms, dashboards, and other telemetry | Records actions performed by users, roles, and AWS services |
| Answers “How is the system behaving?” | Answers “Who or what changed something in AWS?” |
| Example: EC2 CPU reached 90% | Example: an identity called an EC2 stop API |
| Used for monitoring, alerting, and troubleshooting | Used for auditing, governance, compliance, and investigations |

CloudWatch and CloudTrail are complementary services, not alternatives.

## 8. CloudWatch vs. Prometheus vs. Grafana

| Service | Main responsibility | Simple meaning |
| --- | --- | --- |
| Amazon CloudWatch | AWS monitoring and observability | Collect, monitor, query, and alert on AWS/application telemetry |
| Amazon Managed Service for Prometheus | Prometheus-compatible metric storage and querying | Store and query Prometheus metrics at scale |
| Amazon Managed Grafana | Visualization and analytics | Build dashboards using multiple telemetry sources |

A common design is:

```text
Prometheus-compatible metrics
            |
            v
Amazon Managed Service for Prometheus
            |
            v
Amazon Managed Grafana
            |
            v
Operations Dashboard
```

CloudWatch can also be a Grafana data source, allowing AWS-native metrics and
logs to be visualized alongside Prometheus telemetry.

## 9. Three Observability Pillars

| Pillar | AWS service or capability | Main question |
| --- | --- | --- |
| Metrics and monitoring | Amazon CloudWatch, AMP | What is happening? |
| Logging | CloudWatch Logs | What events explain the behavior? |
| Tracing | AWS X-Ray, OpenTelemetry | Where did the request go, and where is the delay or error? |

A strong observability strategy uses these signals together rather than relying
on only one:

```text
CloudWatch Alarm
"CPU or error rate is high"
          |
          v
CloudWatch Logs
"Which errors occurred?"
          |
          v
X-Ray Trace
"Which dependency or request path is slow?"
          |
          v
Grafana / CloudWatch Dashboard
"What is the wider system picture?"
```

## 10. Practical Twenty CRM Observability Architecture

For a Twenty CRM application deployed on EC2, a learning architecture could be:

```text
                         +-----------------------+
Users ------------------>| Twenty CRM on EC2     |
                         +-----------+-----------+
                                     |
             +-----------------------+-----------------------+
             |                       |                       |
             v                       v                       v
    CloudWatch Metrics      CloudWatch Logs            X-Ray / OTel
    CPU / Network /         App / Docker /             Request traces
    host metrics            system logs
             |                       |                       |
             +-----------------------+-----------------------+
                                     |
                                     v
                         Dashboards / Investigation
                                     |
                         +-----------+-----------+
                         |                       |
                         v                       v
              CloudWatch Dashboard      Managed Grafana

AWS account/API activity -----------------------------> CloudTrail
Prometheus-compatible metrics -----------> AMP -------> Managed Grafana
```

This design provides:

- CloudWatch for AWS metrics, logs, dashboards, and alarms;
- X-Ray or OpenTelemetry for request tracing;
- AMP for Prometheus-compatible metrics;
- Managed Grafana for shared visualization; and
- CloudTrail for AWS API auditing and change investigation.

## 11. Example Incident Investigation

Imagine that users report the CRM is slow.

### Step 1 — CloudWatch Metrics

Check CPU, network, host and application metrics, and current alarm states.

### Step 2 — CloudWatch Logs

Search application and system logs for errors, timeouts, and repeated failures.

### Step 3 — X-Ray or distributed tracing

Inspect traces to determine whether latency is in the application, database, or
another downstream dependency.

### Step 4 — Grafana or CloudWatch dashboards

Correlate trends across the available telemetry sources and time window.

### Step 5 — CloudTrail

If the issue followed a possible AWS configuration change, inspect account
activity to determine what changed and which identity initiated the action.

This is the major benefit of observability: instead of guessing, engineers use
telemetry to narrow down the cause.

## 12. Key Learning Summary

- CloudWatch Metrics measure system and application behavior over time.
- Namespaces group related CloudWatch metrics; EC2 metrics use `AWS/EC2`.
- CloudWatch Alarms evaluate telemetry and can trigger notifications or actions.
- CloudWatch Logs centralizes log events and supports Logs Insights queries.
- CloudWatch Dashboards visualize AWS resources and applications.
- AWS X-Ray provides distributed tracing and identifies latency or errors across
  dependencies.
- AMP provides a managed Prometheus-compatible metric backend and PromQL.
- Managed Grafana provides managed dashboards across multiple data sources.
- CloudTrail records AWS account and API activity for audit, governance,
  security, and operational investigations.
- Combining metrics, logs, traces, audit events, and dashboards provides a much
  stronger understanding of system health than any single signal.

## Official Documentation

- [Amazon CloudWatch documentation](https://docs.aws.amazon.com/cloudwatch/)
- [AWS X-Ray documentation](https://docs.aws.amazon.com/xray/)
- [Amazon Managed Service for Prometheus documentation](https://docs.aws.amazon.com/prometheus/)
- [Amazon Managed Grafana documentation](https://docs.aws.amazon.com/grafana/)
- [AWS CloudTrail documentation](https://docs.aws.amazon.com/cloudtrail/)

> AWS features, quotas, Regions, retention periods, and pricing can change.
> Verify current details in the official AWS documentation before implementing
> a production solution.
