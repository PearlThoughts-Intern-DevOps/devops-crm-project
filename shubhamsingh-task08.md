# AWS Observability - Task 8 Documentation

**Author:** Shubham Singh  
**Branch:**  shubhamsingh-task08 
**Date:** 03-September 2026

---

## What is AWS Observability?

AWS Observability is the ability to **monitor, trace, and understand** what's happening inside your cloud infrastructure and applications. It answers three key questions:

- **What is happening?** → Metrics & Logs
- **Why is it happening?** → Traces & Events
- **What changed?** → Audit & Config Tracking

AWS provides a full suite of managed services to achieve observability without managing your own monitoring infrastructure.

---

## AWS Observability Services

### 1. Amazon CloudWatch

**Purpose:** The core monitoring and observability service in AWS.

**What it does:**
- Collects **metrics** (CPU, memory, network, disk usage) from AWS resources
- Aggregates and stores **logs** from EC2, Lambda, ECS, and other services
- Creates **alarms** that trigger notifications or auto-scaling based on thresholds
- Builds **dashboards** to visualize your infrastructure health in real-time

**Use Case:**  
Set an alarm when EC2 CPU usage exceeds 80% and automatically notify the team via SNS email.

**Key Concepts:**
- **Log Groups & Log Streams** – organized containers for application logs
- **Metrics & Namespaces** – categorized data points over time
- **CloudWatch Alarms** – automated responses to threshold breaches
- **CloudWatch Insights** – SQL-like query engine to search and analyze logs

---

### 2. AWS CloudTrail

**Purpose:** Records all API activity across your AWS account for auditing and compliance.

**What it does:**
- Logs **every API call** made to AWS services (via Console, CLI, or SDK)
- Tracks **who did what, when, and from where**
- Stores trail logs in **S3** for long-term retention
- Integrates with CloudWatch for real-time alerting on suspicious activity

**Use Case:**  
Detect if an IAM user deleted an S3 bucket or modified a security group — CloudTrail captures the user, timestamp, and IP address.

**Key Concepts:**
- **Management Events** – control plane operations (create/delete/modify)
- **Data Events** – data plane operations (S3 object access, Lambda invocations)
- **Insight Events** – unusual API activity detection

---

### 3. AWS X-Ray

**Purpose:** Distributed tracing service for debugging and analyzing microservices and serverless applications.

**What it does:**
- Traces **end-to-end request flow** across multiple AWS services
- Identifies **bottlenecks and latency** in your application
- Generates a **service map** showing how services communicate
- Pinpoints which service or component caused an error or slowdown

**Use Case:**  
A user reports the checkout page is slow. X-Ray traces the request across API Gateway → Lambda → DynamoDB and shows that DynamoDB queries are taking 2+ seconds.

**Key Concepts:**
- **Segments & Subsegments** – breakdown of time spent in each service
- **Traces** – full end-to-end journey of a request
- **Service Map** – visual graph of service dependencies and health
- **Sampling** – controls how many requests are traced to manage cost

---

### 4. Amazon Managed Grafana

**Purpose:** Fully managed Grafana service for building rich observability dashboards.

**What it does:**
- Visualizes data from **CloudWatch, Prometheus, X-Ray, and other sources**
- Provides pre-built and custom **dashboards** without managing Grafana servers
- Supports **team collaboration** with role-based access control
- Connects to multiple data sources in a single dashboard

**Use Case:**  
Build a unified dashboard showing application metrics from Prometheus, logs from CloudWatch, and traces from X-Ray — all in one view.

**Key Concepts:**
- **Data Sources** – CloudWatch, Prometheus, Elasticsearch, etc.
- **Panels & Dashboards** – visual components (graphs, tables, gauges)
- **Alerts** – notification rules based on dashboard data

---

### 5. Amazon Managed Service for Prometheus (AMP)

**Purpose:** Managed Prometheus-compatible monitoring for containerized workloads.

**What it does:**
- Collects **metrics from Kubernetes/EKS clusters** without managing Prometheus servers
- Stores metrics at scale with **automatic scaling and high availability**
- Uses **PromQL** (Prometheus Query Language) for querying metrics
- Integrates natively with **Amazon Managed Grafana** for visualization

**Use Case:**  
Monitor CPU, memory, and pod health across an EKS cluster without setting up and maintaining your own Prometheus server.

**Key Concepts:**
- **Workspaces** – isolated environments for metrics storage
- **Remote Write** – how applications send metrics to AMP
- **PromQL** – query language to filter and aggregate metrics

---

### 6. AWS Health Dashboard

**Purpose:** Provides visibility into the health of AWS services and how they affect your account.

**What it does:**
- Shows **real-time status** of all AWS services globally
- Sends **personalized alerts** when AWS issues affect your specific resources
- Tracks **planned maintenance** and upcoming changes
- Integrates with **EventBridge** for automated responses to health events

**Use Case:**  
Receive an automatic notification when AWS reports an outage in `ap-south-1` (Mumbai) region affecting your RDS instances.

**Two Views:**
- **Service Health** – global status of all AWS services
- **Your Account Health** – issues specific to your AWS resources

---

### 7. VPC Flow Logs

**Purpose:** Captures network traffic information for your VPC (Virtual Private Cloud).

**What it does:**
- Logs **all IP traffic** going to and from network interfaces in your VPC
- Helps **diagnose connectivity issues** (why is traffic being blocked?)
- Supports **security analysis** to detect unusual or unauthorized traffic patterns
- Sends logs to **CloudWatch Logs or S3**

**Use Case:**  
Investigate why an EC2 instance cannot connect to the internet — Flow Logs show that outbound traffic is being REJECTED by the security group.

**Key Concepts:**
- **ACCEPT/REJECT** – whether traffic was allowed or blocked
- **Flow Log Fields** – source IP, destination IP, port, protocol, bytes transferred
- **Capture Levels** – VPC level, subnet level, or ENI level

---

### 8. AWS Config

**Purpose:** Continuously tracks and records AWS resource configurations and changes over time.

**What it does:**
- Maintains a **history of configuration changes** for all AWS resources
- Evaluates resources against **compliance rules** (e.g., S3 buckets must not be public)
- Sends **alerts when non-compliant** resources are detected
- Provides a **timeline view** of what changed and when

**Use Case:**  
Enforce a rule that all EC2 instances must have a specific tag (`Environment: Production`). AWS Config flags and reports any instances that don't comply.

**Key Concepts:**
- **Configuration Items** – snapshot of a resource's configuration at a point in time
- **Config Rules** – AWS-managed or custom compliance checks
- **Conformance Packs** – bundles of Config rules for a specific standard (e.g., PCI-DSS)
- **Remediation** – automatic fix actions when non-compliance is detected

---

## Summary Comparison Table

| Service | Primary Use | Data Type | Best For |
|---|---|---|---|
| **CloudWatch** | Monitoring & Alerting | Metrics, Logs, Alarms | General infrastructure monitoring |
| **CloudTrail** | Audit & Compliance | API event logs | Security & access auditing |
| **X-Ray** | Distributed Tracing | Request traces | Debugging microservices/serverless |
| **Managed Grafana** | Visualization | Dashboards | Unified observability dashboards |
| **Managed Prometheus** | Container Metrics | Time-series metrics | Kubernetes/EKS monitoring |
| **Health Dashboard** | AWS Service Status | Health events | Proactive AWS issue awareness |
| **VPC Flow Logs** | Network Monitoring | IP traffic logs | Network security & troubleshooting |
| **AWS Config** | Config Compliance | Config history | Governance & compliance |

---

## Key Takeaways

1. **CloudWatch is the foundation** — most other services integrate with it for alerts and log storage.
2. **CloudTrail is essential for security** — always enable it across all regions in production accounts.
3. **X-Ray is critical for microservices** — helps find the exact service causing latency or errors.
4. **Prometheus + Grafana = container observability** — the standard stack for Kubernetes environments.
5. **AWS Config ensures compliance** — use it to enforce organizational policies automatically.
6. **VPC Flow Logs are your network eyes** — invaluable for troubleshooting connectivity and security.

---

## References

- [Amazon CloudWatch Docs](https://docs.aws.amazon.com/cloudwatch/)
- [AWS CloudTrail Docs](https://docs.aws.amazon.com/cloudtrail/)
- [AWS X-Ray Docs](https://docs.aws.amazon.com/xray/)
- [Amazon Managed Grafana Docs](https://docs.aws.amazon.com/grafana/)
- [Amazon Managed Prometheus Docs](https://docs.aws.amazon.com/prometheus/)
- [AWS Health Dashboard](https://health.aws.amazon.com/)
- [VPC Flow Logs Docs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [AWS Config Docs](https://docs.aws.amazon.com/config/)
