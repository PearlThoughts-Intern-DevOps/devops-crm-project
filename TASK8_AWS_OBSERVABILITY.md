# Task 8: AWS Observability — What I Explored and Learned

## 1. What "observability" means in AWS

Observability is the ability to understand what's happening inside a
system from the outside — through metrics, logs, and traces — without
having to guess. This connects directly to the EC2 deployment from Task
7: once an app is running on a remote instance you can't just watch a
local terminal for, you need these services to know whether it's
healthy, what it's doing, and why something broke.

AWS's observability services generally fall into three categories:
**metrics** (numbers over time — CPU, request count), **logs** (raw
event records), and **traces** (the path a single request takes across
multiple services).

## 2. Core AWS Observability services

| Service | Category | Purpose |
|---|---|---|
| **CloudWatch** | Metrics, Logs, Alarms | The central observability service — collects metrics from almost every AWS resource (EC2 CPU, network, disk), stores application/system logs (CloudWatch Logs), and can trigger alarms/notifications when thresholds are crossed |
| **CloudWatch Logs** | Logs | Centralized log storage and search — the EC2 instance from Task 7 could ship its `docker-compose logs` output here instead of only being visible via SSH |
| **CloudWatch Alarms** | Alerting | Watches a metric (e.g., CPU > 80%) and triggers an action (SNS notification, auto-scaling, etc.) when it crosses a threshold |
| **CloudWatch Dashboards** | Visualization | Custom visual dashboards combining multiple metrics/logs into one view |
| **CloudTrail** | Audit logging | Records every API call made in an AWS account — who did what, when, from where. This is about *account activity*, not application behavior — e.g., it would show that an EC2 instance was launched or terminated, and by which IAM user |
| **X-Ray** | Distributed tracing | Traces a single request as it moves across multiple services (e.g., API Gateway → Lambda → DynamoDB), showing where time is spent and where errors occur — most valuable in microservice/serverless architectures |
| **AWS Config** | Configuration tracking | Records and tracks configuration *changes* to AWS resources over time — useful for compliance and understanding "what changed and when," distinct from CloudTrail's API-call-level audit |
| **Health Dashboard** | Service health | Shows the operational status of AWS services themselves (outages, degradations) — this is about AWS's health, not your application's |
| **CloudWatch Synthetics** | Synthetic monitoring | Runs scripted "canary" requests against your endpoints on a schedule to catch outages proactively, before a real user does |
| **CloudWatch Application Insights** | Application-level monitoring | Automatically detects problems in common application patterns (e.g., .NET, Java apps) using CloudWatch data underneath |

## 3. How these connect to Task 7's EC2 deployment

Looking back at the EC2 deployment, several observability gaps become
obvious in hindsight:
- All debugging was done by manually SSH-ing in and running
  `docker-compose logs` — **CloudWatch Logs** would let those logs be
  searched and retained centrally without needing an active SSH session.
- Memory pressure was checked manually with `free -h` — a **CloudWatch
  Alarm** on the instance's memory/CPU metrics would proactively flag
  this instead of requiring manual checking.
- The instance getting unexpectedly terminated (a real issue from Task
  7) is exactly the kind of event **CloudTrail** would explain — it logs
  the `TerminateInstances` API call, including which principal (user,
  role, or automated policy) triggered it and when.

## 4. Key distinctions worth remembering

- **CloudWatch vs CloudTrail**: CloudWatch is about *what your
  application/infrastructure is doing* (metrics, logs, performance).
  CloudTrail is about *what actions were taken on your AWS account*
  (who launched/terminated/modified something). They answer different
  questions and are often used together.
- **CloudTrail vs AWS Config**: CloudTrail logs the *event* of an API
  call happening. Config tracks the *resulting state* of a resource over
  time and can show a timeline of configuration changes, not just that
  a change-triggering call was made.
- **X-Ray's niche**: it's specifically for tracing requests *across*
  multiple services/functions — not useful for a single monolithic app
  like the EC2 deployment in Task 7, but essential once an architecture
  splits into Lambda functions, microservices, or API Gateway-fronted
  services.

## 5. What I learned

- Observability tooling isn't one service — it's a layered set of tools
  each answering a different question (what happened to my app? what
  happened to my account? what's the health of AWS itself? how did a
  request flow across services?).
- Retroactively applying this to Task 7's EC2 work highlighted concrete
  gaps — manual SSH-based debugging and monitoring works for a single
  short-lived instance, but doesn't scale, and CloudWatch/CloudTrail
  would have directly answered questions I had to debug manually (like
  the unexpected instance termination).
- The distinction between infrastructure-level observability
  (CloudWatch) and account-level audit (CloudTrail) is a foundational
  mental model for working with AWS safely and diagnosably at any scale.