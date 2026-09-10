# AWS Observability — Documentation

**Author:** Vikash Yadav

This document covers each AWS Observability service in detail: what it is,
why it exists, its key components, how it works, and when to use it.

---

## 1. Amazon CloudWatch

CloudWatch is AWS's core monitoring and observability platform. It has four
main components, each solving a different problem.

### 1.1 CloudWatch Metrics

**What it is:** Time-series numeric data collected from AWS resources and
applications.

**Key points:**
- Every AWS service automatically publishes metrics — e.g. EC2 publishes
  `CPUUtilization`, `NetworkIn`, `NetworkOut`, `DiskReadOps`; RDS publishes
  `FreeStorageSpace`, `DatabaseConnections`; Lambda publishes `Duration`,
  `Errors`, `Throttles`.
- Metrics live inside **namespaces** (`AWS/EC2`, `AWS/RDS`, `AWS/Lambda`) so
  they don't collide across services.
- Default EC2 metrics are collected every 5 minutes ("basic monitoring");
  enabling "detailed monitoring" drops this to 1-minute intervals (small
  extra cost).
- You can publish **custom metrics** from your own app — e.g. "orders
  processed per minute", "queue depth" — using the CLI (`aws cloudwatch
  put-metric-data`) or an SDK.
- Data is stored with automatic resolution decay: high-resolution data for
  a short window, aggregated down to lower resolution for long-term storage
  (up to 15 months).

**When to use:** Any time you need a number over time — CPU, memory,
latency, request count, custom business metrics.

### 1.2 CloudWatch Alarms

**What it is:** A watcher on a metric that triggers an action when a
threshold condition is met.

**Key points:**
- Define: which metric, the threshold (e.g. `CPUUtilization > 80`), the
  evaluation period (e.g. "for 3 out of 5 datapoints"), and the action.
- Three states: `OK`, `ALARM`, `INSUFFICIENT_DATA` (not enough data yet to
  evaluate).
- Actions: notify via **SNS** (email/SMS/Slack via integration), trigger
  **Auto Scaling** (add/remove instances), or take an **EC2 action**
  (stop, terminate, reboot, or recover the instance).
- **Composite alarms** let you combine multiple alarms with AND/OR logic
  (e.g. only alert if CPU is high *and* request count is high, to reduce
  noise).

**When to use:** Whenever a metric crossing a threshold should trigger a
human notification or an automated response.

### 1.3 CloudWatch Logs

**What it is:** Centralized storage for log data from applications, AWS
services, and infrastructure.

**Key points:**
- Structure: **Log Group** (a category, e.g. `/ec2/my-app`) → **Log
  Stream** (one stream per source, e.g. per instance or per container).
- Sources: the **CloudWatch agent** on EC2, Lambda (automatic), ECS/EKS
  (via awslogs driver), VPC Flow Logs, API Gateway, and custom app logs
  pushed via SDK/CLI.
- **Retention** is configurable per log group: from 1 day up to 10 years,
  or "never expire" (which can get expensive — set retention deliberately).
- **CloudWatch Logs Insights** is a query language for searching/filtering/
  aggregating log data without downloading raw files, e.g.:
  ```
  fields @timestamp, @message
  | filter @message like /ERROR/
  | sort @timestamp desc
  | limit 20
  ```
- **Metric Filters** can turn a pattern in your logs into a CloudWatch
  metric (e.g. count how many times "OutOfMemoryError" appears, then alarm
  on it).

**When to use:** Debugging, searching historical application behavior,
building alerts off log patterns.

### 1.4 CloudWatch Dashboards

**What it is:** Customizable visual boards combining widgets (graphs,
numbers, text, alarm status) from multiple metrics/logs sources into a
single screen.

**Key points:**
- Widgets can pull from different namespaces/services on the same
  dashboard — e.g. EC2 CPU next to RDS connections next to a Lambda error
  count.
- Dashboards can be shared (read-only) with people who don't have full
  console access.
- Can be built manually in the console or defined as JSON (useful for
  version-controlling dashboards as code).

**When to use:** A single "is everything healthy?" view for a team, or a
NOC/status-board style screen.

---

## 2. AWS X-Ray

**What it is:** A distributed tracing service — it follows a single request
as it moves across multiple services and shows exactly where time was
spent and where it failed.

**Key points:**
- Produces a **trace**: a timeline of "segments" (one per service the
  request touched) and "subsegments" (calls within a service, e.g. a
  database query).
- Produces a **Service Map** — an auto-generated visual graph of your
  architecture, with average latency and error rate shown on each node and
  edge.
- Requires **instrumentation**: adding the X-Ray SDK to your application
  code (or increasingly, using ADOT — see below — instead of the
  AWS-specific SDK).
- Works well with Lambda, API Gateway, ECS, EKS, and EC2.
- Helps answer questions plain logs/metrics can't: "this request took 3
  seconds — was it the database, the downstream API, or the Lambda cold
  start?"

**When to use:** Microservice or multi-hop architectures where a single
slow/failed request needs to be traced across service boundaries. Not very
useful for a single monolithic app with no downstream calls.

---

## 3. AWS CloudTrail

**What it is:** An audit log of every API call made in your AWS account —
who did it, when, from where, and with what result.

**Key points:**
- Captures calls made via the **Console, CLI, SDKs**, and calls made by
  **other AWS services on your behalf**.
- **Event history** (last 90 days) is available by default with zero
  setup, directly in the console.
- Creating a **Trail** enables continuous logging beyond 90 days, delivered
  to an S3 bucket (and optionally to CloudWatch Logs for real-time
  alerting).
- Two event types: **Management events** (control-plane actions like
  creating/deleting resources — logged by default) and **Data events**
  (data-plane actions like S3 object reads/writes or Lambda invocations —
  higher volume, must be enabled explicitly, costs more).
- Common use: detect and alert on dangerous actions, e.g. "someone opened
  port 22 to 0.0.0.0/0" or "root account was used to log in."

**When to use:** Security investigations, compliance requirements,
answering "who changed/deleted this resource and when?"

---

## 4. AWS Config

**What it is:** A service that continuously records the **configuration**
of your AWS resources and tracks how that configuration changes over time.

**Key points:**
- Maintains a **configuration history** and **configuration snapshots** for
  supported resource types (EC2, security groups, S3 buckets, IAM roles,
  etc.) — you can see exactly what a resource's settings looked like at any
  point in the past, and diff between two points in time.
- **Config Rules** continuously evaluate resources against a desired state
  and mark them **compliant/non-compliant** — e.g. "all S3 buckets must
  have encryption enabled," "no security group should allow unrestricted
  SSH."
- Can trigger automatic remediation via **SSM Automation documents** when a
  resource goes non-compliant.
- Different from CloudTrail: CloudTrail tells you *who made an API call*;
  Config tells you *what the resource's actual configuration is/was*, and
  whether it complies with your rules.

**When to use:** Compliance auditing, governance, drift detection (making
sure resources stay in the state they're supposed to be in).

---

## 5. VPC Flow Logs

**What it is:** Logging of IP traffic metadata flowing to and from network
interfaces (ENIs) inside a VPC.

**Key points:**
- Captures: source/destination IP, source/destination port, protocol,
  packet/byte counts, and whether the traffic was `ACCEPT`ed or `REJECT`ed
  (by a security group or NACL).
- Does **not** capture packet contents/payload — metadata only.
- Can be enabled at the VPC, subnet, or individual ENI level.
- Destination options: **CloudWatch Logs** (for querying with Logs
  Insights) or **S3** (cheaper, better for long-term storage/analysis with
  Athena).
- Very useful for network troubleshooting — e.g. "is my app unable to
  reach the database because of a security group, or because of something
  else entirely?" A `REJECT` entry confirms it's the network layer.

**When to use:** Network troubleshooting, security analysis (spotting
unexpected traffic to/from unusual IPs), verifying security group/NACL
behavior.

---

## 6. Amazon Managed Service for Prometheus & Amazon Managed Grafana

**What they are:** Fully managed versions of the popular open-source
Prometheus (metrics database) and Grafana (dashboarding) tools.

### 6.1 Amazon Managed Service for Prometheus (AMP)
- A Prometheus-compatible metrics backend that AWS operates and scales for
  you — no need to run, patch, or scale your own Prometheus servers.
- Ingests metrics using the standard Prometheus remote-write protocol, so
  existing Prometheus exporters/instrumentation work without changes.
- Good fit for teams running Kubernetes (EKS) who already use
  Prometheus-style metrics.

### 6.2 Amazon Managed Grafana (AMG)
- A fully managed Grafana instance/workspace.
- Comes with native data source plugins for CloudWatch, Managed
  Prometheus, X-Ray, and many third-party sources — so you can build one
  set of dashboards pulling from multiple backends at once.
- Handles authentication (via IAM Identity Center or SSO), scaling, and
  patching for you.

**When to use:** When a team wants open-source-standard tooling (avoiding
AWS-specific dashboard/query syntax) or is migrating an existing
Prometheus/Grafana setup onto AWS without a rewrite.

---

## 7. AWS Distro for OpenTelemetry (ADOT)

**What it is:** AWS's own supported distribution of the open-source
**OpenTelemetry** project — a vendor-neutral standard for collecting
metrics, logs, and traces.

**Key points:**
- Instead of instrumenting your app separately for CloudWatch and X-Ray
  (AWS-specific SDKs), you instrument it **once** using the OpenTelemetry
  standard.
- The ADOT Collector then routes that telemetry data to CloudWatch, X-Ray,
  Amazon Managed Prometheus, or even third-party observability platforms
  (Datadog, New Relic, etc.) — your application code doesn't need to change
  if you switch backends later.
- Supports auto-instrumentation for many popular languages/frameworks,
  reducing the amount of manual code changes needed.
- This is the direction AWS is steering new projects toward, since it
  avoids vendor lock-in at the application-code level.

**When to use:** New projects, or when you want the flexibility to change
observability backends later without re-instrumenting your whole
application.

---

## 8. How it all fits together

| Service | Pillar | Core Question Answered |
|---|---|---|
| CloudWatch Metrics | Metrics | Is this resource healthy right now? |
| CloudWatch Alarms | Alerting | Should someone/something react to this metric? |
| CloudWatch Logs | Logs | What exactly happened / was printed? |
| CloudWatch Dashboards | Visualization | One screen for overall system health |
| AWS X-Ray | Tracing | Which service in a multi-hop request was slow/failed? |
| AWS CloudTrail | Audit | Who made this API call, and when? |
| AWS Config | Compliance | Has this resource's configuration drifted from policy? |
| VPC Flow Logs | Network | Is traffic being allowed/blocked as expected? |
| Managed Prometheus/Grafana | Metrics + Dashboards | Open-source-standard stack, fully managed |
| ADOT | Instrumentation | Vendor-neutral way to collect telemetry once |

---

## 9. Key takeaways

- CloudWatch is the umbrella for day-to-day monitoring (metrics, alarms,
  logs, dashboards) — it's where most observability work happens.
- CloudTrail and Config are about **accountability and compliance**, not
  performance — easy to confuse with CloudWatch at first.
- X-Ray matters most once an architecture has multiple hops; not very
  useful for a single monolith.
- VPC Flow Logs are the go-to tool for network-layer troubleshooting.
- Managed Prometheus/Grafana and ADOT exist for teams that want
  open-source-standard, vendor-neutral tooling instead of being fully
  locked into AWS-native services.