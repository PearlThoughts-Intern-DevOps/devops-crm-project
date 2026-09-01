# Task 6: AWS & GCP — Cloud Platforms Overview

**Author:** Shubham Singh
**Branch:** `shubhamsingh-task6`
**Repository:** `devops-crm-project`
**Loom Video:** [Add your Loom link here]

---

## Table of Contents

1. [What is Cloud Computing?](#1-what-is-cloud-computing)
2. [Amazon Web Services (AWS)](#2-amazon-web-services-aws)
3. [Google Cloud Platform (GCP)](#3-google-cloud-platform-gcp)
4. [AWS vs GCP — Service Comparison](#4-aws-vs-gcp--service-comparison)
5. [Key Architectural Differences](#5-key-architectural-differences)
6. [Similarities Between AWS and GCP](#6-similarities-between-aws-and-gcp)
7. [AWS and GCP in DevOps](#7-aws-and-gcp-in-devops)
8. [When to Use AWS vs GCP](#8-when-to-use-aws-vs-gcp)
9. [My Learnings and Takeaways](#9-my-learnings-and-takeaways)

---

## 1. What is Cloud Computing?

Cloud computing is the delivery of computing resources — servers, storage, databases, networking, and software — over the internet on demand. Instead of owning and maintaining physical hardware, organisations use cloud providers and pay only for what they consume.

**Core cloud service categories:**

| Category | Examples |
|---|---|
| Compute | Virtual machines, serverless functions, containers |
| Storage | Object storage, block storage, file systems |
| Networking | VPC, load balancers, CDN, DNS |
| Databases | Relational (SQL) and non-relational (NoSQL) |
| Security & IAM | Access control, key management, audit logs |
| Monitoring | Metrics, logs, tracing, alerting |
| DevOps Tooling | CI/CD pipelines, container registries, IaC |

The three major cloud providers are **AWS**, **GCP**, and **Microsoft Azure**. This document focuses on AWS and GCP.

---

## 2. Amazon Web Services (AWS)

### Overview

AWS was launched publicly in **2006** and is the global market leader with approximately **32% market share**. It offers 200+ managed services and is known for its breadth, enterprise maturity, and the largest geographic footprint (33+ regions, 105+ availability zones).

### Core AWS Services

| Category | Service | Description |
|---|---|---|
| Compute | EC2 | On-demand virtual machines with many instance types |
| Serverless | Lambda | Run code in response to events — no server management |
| Containers | ECS / EKS | Managed Docker (ECS) and managed Kubernetes (EKS) |
| Object Storage | S3 | Scalable, durable blob/object storage |
| Relational DB | RDS | Managed MySQL, PostgreSQL, SQL Server, Oracle |
| NoSQL DB | DynamoDB | Serverless key-value and document database |
| Data Warehouse | Redshift | Columnar analytics database for large-scale queries |
| Networking | VPC | Regional isolated network with subnet and routing control |
| IAM | IAM | JSON-policy-based identity and access management |
| Monitoring | CloudWatch | Unified metrics, logs, dashboards, and alarms |
| CI/CD | CodePipeline + CodeBuild | Source-to-deploy automation pipeline |
| Container Registry | ECR | Private Docker image registry |
| CDN | CloudFront | Global edge content delivery network |

### AWS Strengths

- Largest service catalogue — a managed service exists for almost every use case
- Widest geographic footprint — most regions and availability zones globally
- Largest enterprise compliance posture (HIPAA, PCI-DSS, FedRAMP, SOC 2, ISO 27001)
- Biggest talent pool — AWS certifications are the most common cloud credentials
- Strongest third-party ecosystem and marketplace integrations

---

## 3. Google Cloud Platform (GCP)

### Overview

GCP was opened publicly in **2011** and holds approximately **11% market share**. It runs on the same global infrastructure powering Google Search, YouTube, and Gmail. GCP is especially strong in Kubernetes (Google invented it), big-data analytics, AI/ML, and global networking.

### Core GCP Services

| Category | Service | Description |
|---|---|---|
| Compute | Compute Engine | VMs with standard or fully custom vCPU + RAM configurations |
| Serverless | Cloud Functions / Cloud Run | Event-driven functions and containerised serverless apps |
| Containers | GKE | Industry-leading managed Kubernetes — Google built K8s |
| Object Storage | Cloud Storage | Globally scoped, strongly consistent object storage |
| Relational DB | Cloud SQL | Managed MySQL, PostgreSQL, SQL Server |
| NoSQL DB | Firestore / Bigtable | Document DB for apps; wide-column DB for petabyte-scale data |
| Data Warehouse | BigQuery | Fully serverless SQL analytics — no cluster provisioning needed |
| Networking | VPC (Global) | A single VPC that spans all regions automatically |
| IAM | Cloud IAM | Role-binding model with Org → Folder → Project hierarchy |
| Monitoring | Cloud Monitoring | Metrics, dashboards, and alerting |
| Logging | Cloud Logging | Centralised log storage and structured search |
| CI/CD | Cloud Build | Fully managed build and deploy pipeline |
| Container Registry | Artifact Registry | Universal image and package registry |

### GCP Strengths

- Best managed Kubernetes — GKE Autopilot removes all node management burden
- BigQuery is serverless — no cluster provisioning or management required
- Global VPC — one network spans all regions with no extra peering config
- Superior AI/ML tooling (Vertex AI, TPUs, Google's ML research heritage)
- Automatic sustained-use discounts — no upfront reservation required
- Cleaner IAM hierarchy for enterprise multi-team environments

---

## 4. AWS vs GCP — Service Comparison

### Service Mapping

| Category | AWS | GCP Equivalent |
|---|---|---|
| Virtual Machines | EC2 | Compute Engine |
| Serverless Functions | Lambda | Cloud Functions |
| Serverless Containers | Fargate | Cloud Run |
| Managed Kubernetes | EKS | GKE |
| Object Storage | S3 | Cloud Storage |
| Block Storage | EBS | Persistent Disk |
| Managed Relational DB | RDS | Cloud SQL |
| NoSQL (General) | DynamoDB | Firestore |
| NoSQL (Extreme Scale) | DynamoDB (heavy config) | Bigtable |
| Data Warehouse | Redshift | BigQuery |
| Networking | VPC (Regional) | VPC (Global) |
| IAM | IAM | Cloud IAM |
| Load Balancer | ELB / ALB / NLB | Cloud Load Balancing |
| DNS | Route 53 | Cloud DNS |
| CDN | CloudFront | Cloud CDN |
| Metrics | CloudWatch Metrics | Cloud Monitoring |
| Logs | CloudWatch Logs | Cloud Logging |
| Tracing | AWS X-Ray | Cloud Trace |
| Message Queue | SQS | Pub/Sub |
| Container Registry | ECR | Artifact Registry |
| Build Service | CodeBuild | Cloud Build |
| Secrets | Secrets Manager | Secret Manager |
| Key Management | KMS | Cloud KMS |

---

## 5. Key Architectural Differences

### 5.1 Networking — Regional VPC (AWS) vs Global VPC (GCP)

This is the most significant architectural difference between the two platforms.

| Feature | AWS VPC | GCP VPC |
|---|---|---|
| VPC Scope | Regional — one VPC per region | Global — one VPC spans all regions |
| Subnet Scope | Availability-Zone level | Regional level |
| Cross-Region Traffic | Requires VPC Peering or Transit Gateway | Resources in the same VPC communicate natively |
| Cross-Region Cost | Extra setup cost + data transfer charges | No extra networking cost within the same VPC |

```
AWS (Regional VPC):
  Mumbai VPC  ←── peering required ──→  US-East VPC
  (separate networks, extra config + cost)

GCP (Global VPC):
         ONE VPC
        /        \
  Mumbai         US-East
  subnet         subnet
  (same VPC — resources communicate directly, no peering)
```

**Practical impact:** A GCP app deployed in Mumbai, Singapore, and Frankfurt shares one VPC and communicates natively. The equivalent AWS setup needs three VPCs, peering connections, additional routing, and ongoing data-transfer costs.

---

### 5.2 Compute — EC2 vs Compute Engine

| Feature | AWS EC2 | GCP Compute Engine |
|---|---|---|
| Machine Sizes | Fixed instance families (t3, m5, c5…) | Fixed types OR custom (choose exact vCPU + RAM) |
| Billing | Per second after 60s minimum | Per second from second 1 |
| Spot/Preemptible | Spot Instances (2-min interruption notice) | Preemptible VMs (max 24-hour lifetime) |
| Physical Maintenance | VM is rebooted by AWS | Live migration — VM stays running while host is serviced |
| SSH Access | Download a .pem key pair manually | gcloud CLI auto-injects keys on first connection |
| Firewall | Security Groups per network interface | Firewall rules applied via network tags on VMs |

**Key difference — Live Migration:** When Google needs to service the physical host your VM runs on, the VM is silently moved to another host while it keeps running. AWS reboots your VM. This means infrastructure maintenance in GCP causes zero downtime.

**Key difference — Custom Machine Types:** In AWS you pick from predefined instance sizes. In GCP you specify exactly how many vCPUs and how much RAM you need and pay for precisely that.

---

### 5.3 IAM — JSON Policies (AWS) vs Role Bindings (GCP)

| Feature | AWS IAM | GCP Cloud IAM |
|---|---|---|
| Permission Format | JSON policy documents | Role bindings: who + role + which resource |
| Organisational Model | Flat account model; AWS Organisations adds hierarchy | Native Org → Folder → Project → Resource tree |
| Permission Inheritance | Manual via SCPs and cross-account roles | Automatic — parent permissions flow to children |
| Complexity | High — JSON policy edge cases | Lower — predefined roles cover most scenarios |

---

### 5.4 Object Storage — S3 vs Cloud Storage

| Feature | AWS S3 | GCP Cloud Storage |
|---|---|---|
| Bucket Scope | Regional | Global namespace |
| Cold Storage Retrieval | Hours (Glacier standard) | Milliseconds (Coldline) |
| Storage Tiers | Standard, IA, Glacier, Glacier Instant | Standard, Nearline, Coldline, Archive |
| Strong Consistency | Yes — since 2020 | Always — from launch |

**Key difference — Cold Storage:** AWS Glacier requires hours to retrieve archived data (unless paying for expedited retrieval). GCP Coldline gives millisecond retrieval — you pay a higher per-GB cost but there is no waiting.

---

### 5.5 Monitoring and Logging

| Feature | AWS | GCP |
|---|---|---|
| Metrics | CloudWatch Metrics | Cloud Monitoring |
| Logs | CloudWatch Logs (same service as metrics) | Cloud Logging (separate dedicated service) |
| Tracing | AWS X-Ray | Cloud Trace |
| Kubernetes Integration | Requires manual config for EKS | Native auto-integration with GKE |

In AWS, metrics and logs live in one service (CloudWatch). In GCP they are split into two separate services — Cloud Monitoring for metrics and Cloud Logging for logs. This is more organised but means more places to check when debugging.

---

### 5.6 NoSQL — DynamoDB vs Firestore / Bigtable

AWS consolidates NoSQL into one general-purpose service. GCP splits the workload across two purpose-built databases.

| Feature | DynamoDB (AWS) | Firestore (GCP) | Bigtable (GCP) |
|---|---|---|---|
| Type | Key-value + Document | Document (MongoDB-like) | Wide-column |
| Best For | General-purpose NoSQL | Mobile/web apps, real-time sync | IoT, time-series, extreme analytics |
| Query Flexibility | Limited (key/GSI only) | Rich flexible queries | Row-key lookups only |
| Pricing | Per read/write unit | Per read/write operation | Per provisioned node |
| Scale | Massive | Massive | Extreme (Gmail-scale) |

---

## 6. Similarities Between AWS and GCP

Despite their architectural differences, both platforms share the same fundamental capabilities:

| Capability | Both AWS and GCP Provide |
|---|---|
| Service Categories | Compute, storage, networking, databases, IAM, monitoring, CI/CD, containers, serverless |
| Global Infrastructure | Multiple regions and availability zones for redundancy and low-latency placement |
| Managed Services | Fully managed databases, Kubernetes, message queues — no OS patching required |
| IaC Compatibility | Full Terraform, Pulumi support alongside native IaC tooling |
| Security Compliance | ISO 27001, SOC 2, PCI-DSS, HIPAA-eligible architecture support |
| Serverless Compute | Event-driven functions (Lambda / Cloud Functions) and container serverless (Fargate / Cloud Run) |
| Kubernetes | Managed Kubernetes clusters (EKS / GKE) with autoscaling |
| Pay-as-you-go | Consumption-based pricing with commitment discounts |
| CLI & API | Feature-complete CLIs (`aws` / `gcloud`) and REST APIs for full automation |
| Monitoring | Native metrics, log aggregation, alerting, and distributed tracing |

---

## 7. AWS and GCP in DevOps

Both platforms are central to modern DevOps practice. A cloud-native CI/CD pipeline uses cloud services at every stage.

### Typical DevOps Pipeline Flow

```
Developer commits code
        │
        ▼
   Git push / PR
        │
        ▼
  CI Pipeline triggers
        │
   ┌────┼────┐
   ▼    ▼    ▼
 Lint  Test  Security Scan
        │
        ▼
  Docker Build
        │
        ▼
  Container Registry
  (ECR or Artifact Registry)
        │
        ▼
  Deploy to Kubernetes
  (EKS or GKE)
        │
        ▼
  Load Balancer routes traffic
        │
        ▼
  Monitoring + Logging
  (CloudWatch or Cloud Monitoring + Cloud Logging)
```

### AWS DevOps Toolchain

| Stage | AWS Service |
|---|---|
| Source Control | CodeCommit / GitHub integration |
| CI Pipeline | CodePipeline + CodeBuild |
| Container Build | CodeBuild → Docker image |
| Image Registry | ECR |
| Container Orchestration | EKS (Kubernetes) or ECS (Fargate) |
| Load Balancing | Application Load Balancer (ALB) |
| Infrastructure as Code | CloudFormation or Terraform |
| Monitoring | CloudWatch Metrics + CloudWatch Logs |
| Secrets & Config | Secrets Manager + SSM Parameter Store |

### GCP DevOps Toolchain

| Stage | GCP Service |
|---|---|
| Source Control | Cloud Source Repositories / GitHub integration |
| CI/CD Pipeline | Cloud Build with triggers |
| Container Build | Cloud Build → Docker image |
| Image Registry | Artifact Registry |
| Container Orchestration | GKE (Kubernetes) or Cloud Run |
| Load Balancing | Cloud Load Balancing (global HTTP(S) LB) |
| Infrastructure as Code | Deployment Manager or Terraform |
| Monitoring | Cloud Monitoring (metrics) + Cloud Logging (logs) |
| Secrets & Config | Secret Manager |

### GitOps with Kubernetes (Both Platforms)

Both EKS and GKE support GitOps workflows using ArgoCD or Flux:

- Desired cluster state is declared in Git as Kubernetes manifests or Helm charts
- ArgoCD continuously compares the live cluster state with the Git source of truth
- Any drift is automatically corrected — Git is the single source of truth
- Rollbacks are a `git revert` — no special tooling required

---

## 8. When to Use AWS vs GCP

| Scenario | Recommended | Reason |
|---|---|---|
| General enterprise workloads | AWS | Widest service catalogue and compliance posture |
| Team already on AWS | AWS | Existing skills, tooling, and runbooks |
| Managed Kubernetes at scale | GCP | GKE Autopilot is the easiest fully managed K8s |
| Serverless data warehouse / analytics | GCP | BigQuery — no cluster management, pay-per-query |
| AI / ML workloads | GCP | Vertex AI, TPUs, Google's foundational ML research |
| Global multi-region app (low config) | GCP | Global VPC eliminates cross-region peering complexity |
| Cost-optimised VMs (no upfront commit) | GCP | Automatic sustained-use discounts |
| Right-sized VMs (unusual CPU/RAM ratio) | GCP | Custom machine types match workload exactly |
| Widest third-party integrations | AWS | Largest marketplace and ISV ecosystem |
| Multi-cloud (both needed) | Both | Terraform and containers bridge both platforms |

---

## 9. My Learnings and Takeaways

Through this task I explored both AWS and GCP hands-on and formed a clear understanding of where each platform excels and why.

**1. The differences are architectural, not just syntactic**
AWS and GCP don't just differ in CLI commands and service names — they reflect fundamentally different design philosophies. AWS is built for breadth and control; GCP is built for clean architecture and Google-scale defaults.

**2. GCP's Global VPC changes how you think about networking**
In AWS, the first question is "which region is my VPC in?" In GCP, that question doesn't exist — the VPC is always global and subnets are regional. For multi-region applications this eliminates a significant layer of configuration and cost.

**3. GKE is the best managed Kubernetes available**
Since Google invented Kubernetes (from their internal Borg system), GKE has native advantages — especially GKE Autopilot, which removes node provisioning, scaling, and patching entirely. As someone working with EKS on Wanderlust, this comparison was immediately practical.

**4. BigQuery vs Redshift — serverless wins on simplicity**
BigQuery requires zero cluster management. You write SQL and query petabytes of data. Redshift requires provisioning clusters, choosing node types, and ongoing maintenance. For analytics workloads, BigQuery's serverless model is a genuine operational advantage.

**5. AWS wins for DevOps job market demand**
AWS knowledge is more in demand in the current job market. However, GCP expertise — especially GKE and BigQuery — is increasingly valued as companies adopt multi-cloud strategies. Understanding both platforms and their equivalences is a real competitive advantage.

**6. Custom machine types in GCP directly reduce costs**
Being able to specify exactly 6 vCPUs and 20 GB RAM instead of being forced into an 8 vCPU / 32 GB instance means paying for exactly what the workload needs — a practical cost optimisation tool that AWS doesn't offer natively.

**7. IAM philosophy matters at scale**
AWS IAM's JSON policy model is powerful but complex. GCP's role-binding model with an automatic Org → Folder → Project inheritance hierarchy is simpler to reason about for enterprise multi-team environments. Understanding both prepares me for real-world cloud security work.

---

## References

- [AWS Documentation](https://docs.aws.amazon.com)
- [GCP Documentation](https://cloud.google.com/docs)
- [GKE Autopilot Overview](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [BigQuery Overview](https://cloud.google.com/bigquery)
- [Kubernetes Official Site](https://kubernetes.io) — originated from Google's Borg system
- [AWS vs GCP — Pricing Calculator](https://cloud.google.com/products/calculator)

---

*Prepared by Shubham Singh | MCA 2026 | Garden City University, Bangalore*
*Branch: `shubhamsingh-task6` | Repository: `devops-crm-project`*
