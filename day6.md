Day 6 – AWS & GCP Cloud Computing for DevOps

================================================================================

Executive Summary & Introduction

As part of my DevOps learning journey, cloud computing has become one of the most critical foundational pillars. Prior to this exploration, my focus centered on essential DevOps tools and methodologies:

• Version Control & Collaboration: Git, GitHub
• Containerization & Orchestration: Docker, Docker Compose, Kubernetes
• CI/CD & Automation: Jenkins
• Infrastructure as Code & Configuration Management: Terraform, Ansible
• Code Quality & Security (DevSecOps): SonarQube, Trivy
• Observability & Monitoring: Prometheus, Grafana

Through previous project workflows, I gained direct exposure to core AWS services such as Amazon EC2 and Amazon EKS. For Task 6, I conducted a deep comparative study of both Amazon Web Services (AWS) and Google Cloud Platform (GCP).

The objective was not merely memorizing service names or dashboard icons, but understanding how a DevOps engineer leverages cloud services to:
• Provision and manage scalable infrastructure
• Automate deployment pipelines (CI/CD)
• Implement robust cloud networking and security boundaries
• Monitor system reliability and observability
• Bridge local containerization (such as our Twenty CRM Docker setup) with enterprise cloud environments

--------------------------------------------------------------------------------

1. Core Understanding of Cloud Computing

Before this deep dive, cloud computing felt primarily like renting virtual machines over the internet instead of managing on-premises hardware.

A deeper exploration revealed that modern cloud platforms represent comprehensive ecosystems spanning:
• Compute: Scalable VMs, serverless functions, container runtimes
• Storage: Object, block, and file storage
• Networking: Virtual private clouds, subnets, route tables, load balancers, gateways
• Databases: Managed relational, NoSQL, in-memory, and analytical data stores
• Identity & Access Management (IAM): Granular permission matrices and security roles
• Containers & Kubernetes: Managed orchestration control planes
• Serverless Architectures: Event-driven execution layers
• Observability: Centralized logging, metrics collection, and alerting
• Infrastructure Automation: Native and multi-cloud Infrastructure as Code (IaC)

+-----------------------------------------------------------------------------+
|                            DevOps Engineer View                             |
|                                                                             |
|   +-----------------------+                    +------------------------+   |
|   | Software Architecture |                    | Cloud Infrastructure   |   |
|   |  - Source Code (Git)  |                    |  - Compute (EC2/GCE)   |   |
|   |  - Build & Tests      | === Automated ===> |  - Managed K8s         |   |
|   |  - Containerization   |     Pipelines      |  - Object Storage      |   |
|   |  - DevSecOps Scans    |                    |  - Secure Networking   |   |
|   +-----------------------+                    +------------------------+   |
|                                                                             |
|         Result: Infrastructure Treated as Code, Versioned & Reproducible    |
+-----------------------------------------------------------------------------+

The DevOps Value Proposition
Cloud platforms enable infrastructure to be treated directly as software assets. Rather than manual, error-prone server installations, cloud infrastructure is provisioned dynamically, version-controlled, auditable, monitored continuously, and rapidly reproducible.

--------------------------------------------------------------------------------

2. Amazon Web Services (AWS) Overview

Amazon Web Services (AWS) is a mature, extensive cloud platform offering tightly integrated enterprise services.

A primary architectural strength of AWS is deep cross-service integration:

                          +------------------------+
                          |   Amazon VPC Network   |
                          |                        |
+------------------+      |  +------------------+  |      +-------------------+
|  AWS IAM (Auth)  | ---> |  |   Amazon EC2     |  | ---> |   Amazon S3       |
|  Least Privilege |      |  |   Compute Host   |  |      |   Object Storage  |
+------------------+      |  +--------+---------+  |      +-------------------+
                          |           |            |
                          |           v            |
                          |  +------------------+  |      +-------------------+
                          |  |   Amazon RDS     |  |      | Amazon CloudWatch |
                          |  |   Private DB     |  |      | Observability     |
                          |  +------------------+  |      +---------+---------+
                          +------------------------+                ^
                                      |                             |
                                      +-----------------------------+

An application running on Amazon EC2 seamlessly authenticates via IAM Instance Roles, accesses data in Amazon S3, isolates database traffic inside a private VPC subnet targeting RDS, and streams metrics to Amazon CloudWatch without hardcoded credentials or public exposure.

--------------------------------------------------------------------------------

3. AWS Global Infrastructure: Regions & Availability Zones

AWS organizes its global footprint into Regions and Availability Zones (AZs):

3.1 Regions
A Region is a distinct geographical area (e.g., ap-south-1 Mumbai, ap-south-2 Hyderabad, ap-southeast-1 Singapore, eu-central-1 Frankfurt, us-east-1 N. Virginia).

Choosing the appropriate region impacts:
• Network Latency: Proximity to end-users (e.g., Indian traffic routed to Mumbai/Hyderabad).
• Compliance & Data Sovereignty: Legal requirements governing data locality.
• Cost Structures: Pricing variances across geographical zones.
• Service Availability: Progressive rollout of specialized cloud features.

3.2 Availability Zones (AZs)
An Availability Zone consists of one or more discrete data centers with redundant power, networking, and connectivity within an AWS Region.

Key Architectural Insight:
High Availability (HA) is not merely running multiple copies of an application; it requires distributing workloads across physically isolated Availability Zones so that localized hardware, utility, or facility disruptions do not degrade the overall system.

--------------------------------------------------------------------------------

4. Deep Dive into AWS Services

4.1 Amazon EC2 (Elastic Compute Cloud)
Virtual server infrastructure offering full control over operating systems, dependencies, and network parameters.

• DevOps Use Cases: Deploying backend services, running Jenkins automation controllers/agents, hosting Docker runtimes, self-hosting tooling, staging environments.
• Operational Workflow:
  1. Image selection (AMI — Ubuntu/Amazon Linux/Debian).
  2. Instance sizing (vCPU/Memory optimization).
  3. Security Group definition (Ingress/Egress firewall rules).
  4. SSH key pair authentication.
  5. Automated provisioning via cloud-init or Ansible.
  6. Service hardening, process management (systemd/Docker), and metric streaming.

4.2 Amazon S3 (Simple Storage Service)
Highly durable, scalable object storage organized into unique buckets.

• DevOps Use Cases:
  - Build artifact archiving (packaged tarballs, release binaries)
  - Application assets and media
  - Database backup dumps
  - Centralized log cold storage
  - Remote Terraform State Locking & Storage (paired with DynamoDB)
  - Static website and single-page app (SPA) hosting

4.3 AWS IAM (Identity and Access Management)
Controls authentication (who you are) and authorization (what you can do).

• Core Primitives: Users, User Groups, IAM Roles, IAM Policies (JSON permission documents).
• Principle of Least Privilege: Entities receive strictly the permissions necessary for their designated workload and nothing more.
• DevOps Relevance: Securing CI/CD pipelines (e.g., using OpenID Connect / temporary role assumption for GitHub Actions and Jenkins instead of long-lived static access keys).

4.4 Amazon VPC (Virtual Private Cloud)
Logically isolated virtual networks providing granular control over network topology.

• Key Components: Public Subnets, Private Subnets, Internet Gateways (IGW), NAT Gateways, Route Tables, Security Groups (stateful), Network ACLs (stateless).

+------------------------------------------------------------------------------------+
|                                 Amazon VPC (10.0.0.0/16)                           |
|                                                                                    |
|  [ Internet Gateway (IGW) ] <== Ingress Internet Traffic                           |
|            |                                                                       |
|            v                                                                       |
|  +---------------------------------------+  +-----------------------------------+  |
|  | Public Subnet (10.0.1.0/24)           |  | Private Subnet (10.0.2.0/24)      |  |
|  |                                       |  |                                   |  |
|  |  +---------------------------------+  |  |  +-----------------------------+  |  |
|  |  | Application Load Balancer (ALB) |  |  |  | Database / Backend Services|  |  |
|  |  +----------------+----------------+  |  |  | (No direct Public Ingress)  |  |  |
|  |                   |                   |  |  +--------------^--------------+  |  |
|  |                   | (Routed Traffic)  |  |                 |                 |  |
|  |                   +-------------------+--+-----------------+                 |  |
|  |                                       |  |                                   |  |
|  |  [ NAT Gateway ] ====================>|==| (Outbound Egress for Updates)     |  |
|  +---------------------------------------+  +-----------------------------------+  |
+------------------------------------------------------------------------------------+

4.5 Amazon EKS (Elastic Kubernetes Service)
AWS-managed Kubernetes control plane ensuring high availability and integration with AWS IAM and VPC CNI.

• DevOps Workflow:
  - Containerization of applications (e.g., Twenty CRM)
  - Packaging into Kubernetes manifests / Helm charts
  - Deploying Pods, Deployments, Services, Ingress Controllers
  - Elastic scaling via Horizontal Pod Autoscaler (HPA) and Cluster Autoscaler

4.6 AWS Lambda
Serverless, event-driven compute executing code in response to triggers without infrastructure management.

• Triggers: S3 file uploads, Amazon API Gateway calls, EventBridge cron events, DynamoDB streams.
• Architectural Shift: Moves transient, event-based tasks away from running full-time EC2 instances, optimizing compute cost to zero when idle.

4.7 Amazon CloudWatch
Comprehensive observability platform for metrics, log aggregation, and automated alarm triggers.

• DevOps Value: Monitors server CPU/memory, tracks HTTP 5xx error spikes, triggers autoscaling events, and forwards alerts to incident channels.

4.8 AWS CloudFormation
Native declarative Infrastructure as Code (IaC) templating engine.

• Comparison to Terraform: CloudFormation is deeply integrated into AWS native features; Terraform provides cross-cloud and provider-agnostic modularity.

--------------------------------------------------------------------------------

5. End-to-End Hands-On DevOps & CI/CD Pipeline Workflow

Connecting individual cloud building blocks into an automated deployment pipeline:

+---------------+
| Developer Git |
| Commit & Push |
+-------+-------+
        |
        v
+---------------+
| GitHub Repo   |
+-------+-------+
        |  (Webhook Trigger)
        v
+-------------------------------------------------------------+
| Jenkins Automated CI/CD Pipeline Engine                     |
|                                                             |
|   1. Checkout SCM                                           |
|          |                                                  |
|          v                                                  |
|   2. SonarQube Code Quality & Static Analysis (SAST)        |
|          |                                                  |
|          v                                                  |
|   3. Docker Build (Multi-Stage Optimized Artifact)          |
|          |                                                  |
|          v                                                  |
|   4. Trivy Container Image Security Vulnerability Scan      |
|          |                                                  |
|          v                                                  |
|   5. Push Image to Container Registry (ECR / Docker Hub)    |
|          |                                                  |
|          v                                                  |
|   6. Deploy Manifests to Kubernetes Cluster (AWS EKS / GKE) |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
| Cloud Runtime & Observability Platform                      |
|                                                             |
|   - Workloads: Pods, Services, Ingress                      |
|   - Metrics Collection: Prometheus                          |
|   - Visual Dashboards & Alerts: Grafana / CloudWatch        |
+-------------------------------------------------------------+

--------------------------------------------------------------------------------

6. Google Cloud Platform (GCP) Overview

Google Cloud Platform (GCP) is Google's enterprise cloud ecosystem, engineered around container-native infrastructure, developer velocity, global fiber networking, and advanced data analytics.

--------------------------------------------------------------------------------

7. GCP Resource Organization Hierarchy

Unlike AWS where accounts are often partitioned flatly or managed via AWS Organizations, GCP organizes all assets into a strict, inheritable resource hierarchy:

                      +-----------------------------+
                      |      Organization Node      |
                      |    (example.com domain)     |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      |           Folders           |
                      |   [ Engineering / Prod ]    |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      |          Projects           |
                      |   - devops-crm-dev          |
                      |   - devops-crm-stage        |
                      |   - devops-crm-prod         |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      |          Resources          |
                      |   (GCE VMs, GCS, GKE, VPC)  |
                      +-----------------------------+

• Projects: The fundamental operational unit in GCP. Every VM, bucket, or GKE cluster belongs to a single project.
• Inheritance: IAM roles assigned at the Folder or Organization level propagate down to all enclosed projects.

--------------------------------------------------------------------------------

8. Deep Dive into GCP Services

8.1 Google Compute Engine (GCE)
Scalable virtual machines equivalent to Amazon EC2. Features custom machine types (tailored vCPU/RAM ratios) and rapid live migration.

8.2 Google Cloud Storage (GCS)
Unified object storage offering worldwide buckets, granular IAM, and lifecycle policies. Equivalent to Amazon S3.

8.3 Google Cloud IAM
Provides centralized access control binding Members (Google accounts, service accounts) to Roles (collections of granular permissions) across the resource hierarchy.

8.4 Google Cloud VPC (Global Virtual Private Cloud)
A key architectural difference: GCP VPCs are global resources, whereas AWS VPCs are bound to a single region. In GCP, subnets are regional, enabling multi-region VM communication over Google’s private internal backbone without complex inter-region peering.

8.5 Google Kubernetes Engine (GKE)
The industry-leading managed Kubernetes service (originating from Google's internal Borg system). Offers Autopilot (fully managed nodes and control plane) and Standard cluster modes.

8.6 Google Cloud Run
A managed serverless container runtime that executes container images directly via HTTP requests.
• Relevance: For applications like containerized web backends or microservices, Cloud Run abstracts cluster management entirely, scaling down to zero when idle and rapidly scaling up with incoming traffic.

8.7 Google Cloud Monitoring (formerly Stackdriver)
Provides built-in dashboards, metrics exploration, and alerting integrated directly with GCP services and GKE.

8.8 Google Cloud Build
Cloud-native serverless CI/CD automation tool capable of pulling source code, executing multi-step Docker builds, running security checks, and deploying artifacts.

--------------------------------------------------------------------------------

9. Comprehensive AWS vs. GCP Service Mapping

| Capability / Domain      | Amazon Web Services (AWS)     | Google Cloud Platform (GCP)     | DevOps Functional Role                  |
|--------------------------|-------------------------------|---------------------------------|------------------------------------------|
| Virtual Compute          | Amazon EC2                    | Google Compute Engine (GCE)     | Infrastructure VMs, self-hosted tools    |
| Object Storage           | Amazon S3                     | Google Cloud Storage (GCS)      | Backups, artifacts, Terraform state      |
| Identity & Access        | AWS IAM                       | Google Cloud IAM                | Role-Based Access Control (RBAC)         |
| Virtual Networking       | Amazon VPC (Regional)         | Google VPC (Global)             | Network isolation, subnets, gateways     |
| Managed Kubernetes       | Amazon EKS                    | Google Kubernetes Engine (GKE)  | Containerized application orchestration  |
| Serverless Containers    | AWS App Runner / Fargate      | Google Cloud Run                | Zero-ops container execution             |
| Serverless Functions     | AWS Lambda                    | Google Cloud Functions          | Event-driven micro-tasks & hooks         |
| Relational Database      | Amazon RDS / Aurora           | Google Cloud SQL / Spanner      | Managed transactional persistence        |
| Observability            | Amazon CloudWatch             | Google Cloud Monitoring         | Metrics, log aggregation, alerting       |
| Native IaC               | AWS CloudFormation            | Google Cloud Deployment Manager | Declarative infrastructure provisioning  |
| Native CI/CD             | AWS CodePipeline / CodeBuild  | Google Cloud Build              | Managed build and release automation     |

--------------------------------------------------------------------------------

10. Comparative DevOps Analysis: AWS vs. GCP

+------------------------------------+------------------------------------+
|             AWS Matrix             |             GCP Matrix             |
+------------------------------------+------------------------------------+
| - Immense market share & ecosystem | - Container-first engineering DNA  |
| - Fine-grained, exhaustive IAM     | - Intuitive project hierarchy      |
| - Regional VPC architecture        | - Global VPC default architecture  |
| - Vast service variety             | - Superior managed K8s (GKE)       |
| - Standard enterprise ecosystem    | - Simplified serverless (Cloud Run)|
+------------------------------------+------------------------------------+

Core DevOps Portability
The core competencies required for modern software delivery remain provider-agnostic:
• Writing declarative Dockerfiles translates across both platforms.
• Building Kubernetes manifests / Helm charts runs identically on EKS and GKE.
• Authoring Terraform (HCL) allows uniform declarative workflow automation across both providers.

--------------------------------------------------------------------------------

11. Cloud Networking Principles

Modern cloud architectures demand strict separation of public ingress and private application tiers:

1. Edge Ingress: Traffic enters via an Application Load Balancer or Cloud CDN.
2. Public Subnet: Hosts only load balancers, reverse proxies, and NAT Gateways.
3. Private Application Subnet: Compute workloads (EC2, GCE, EKS Pods) operate without public IP addresses, routing outbound traffic through NAT for patching.
4. Isolated Data Subnet: Databases (RDS, Cloud SQL) are strictly unreachable from the public internet, accessible only from the application security group/firewall tag.

--------------------------------------------------------------------------------

12. Cloud Security & DevSecOps Implementation

Cloud security requires a multi-layered defense strategy:

• Identity Defense: Enforce MFA, role-based temporary session credentials, and eliminate root account usage.
• Least Privilege: Craft policies granting only exact API actions (e.g., s3:GetObject on a single bucket rather than s3:*).
• Network Boundaries: Deny-by-default firewall rules; expose only port 443/80 through managed load balancers.
• Pipeline DevSecOps: Integrate SonarQube for code quality/vulnerabilities and Trivy for base image CVE scanning before container images are pushed to registries.
• Secrets Management: Use AWS Secrets Manager or GCP Secret Manager rather than baking credentials into configuration files or container images.

--------------------------------------------------------------------------------

13. Practical Connection to Twenty CRM Containerization (Day 5 Task)

In Day 5, I containerized the Twenty CRM application using a multi-stage Docker build, non-root user execution, persistent storage volumes, health checks, and Docker Compose orchestration.

This directly prepares the application for cloud deployment:

+-----------------------------------------------------------------------------------+
|                        Day 5: Local Multi-Stage Container                         |
|                                                                                   |
|  [Dockerfile] ---> [crm-app Container] + [twenty-server] (Docker Compose Local)   |
+-----------------------------------------+-----------------------------------------+
                                          |
                      Cloud Deployment Pathways Explored
                                          |
        +---------------------------------+---------------------------------+
        |                                                                   |
        v                                                                   v
+-------------------------------+                         +-------------------------------+
|         AWS EKS / EC2         |                         |         GCP GKE / Run         |
|                               |                         |                               |
| - Push image to AWS ECR       |                         | - Push image to Google Artifact|
| - Deploy Helm chart on EKS    |                         |   Registry                    |
| - Attach EBS / EFS storage    |                         | - Deploy to GKE or Cloud Run  |
| - Route via AWS ALB Controller|                         | - Attach Cloud SQL / Storage  |
+-------------------------------+                         +-------------------------------+

The multi-stage optimization from Day 5 ensures lightweight images, minimal attack surfaces, and rapid pulling across cloud nodes in both AWS and GCP.

--------------------------------------------------------------------------------

14. Reflection on Knowledge Portability

Learning GCP after acquiring foundational AWS knowledge highlighted that cloud concepts are fundamentally transferable:

• Understanding EC2 made Compute Engine instantly clear.
• Understanding S3 made Google Cloud Storage intuitive.
• Understanding EKS made GKE familiar.
• Understanding AWS IAM translated directly to GCP Cloud IAM.

DevOps engineers who master foundational Linux, networking, containerization, and IaC can readily navigate any major cloud provider.

--------------------------------------------------------------------------------

15. Future Hands-On Learning Roadmap

AWS Deep-Dive Goals
[ ] Implement multi-tier VPCs with Terraform (Public/Private subnets, NAT Gateways).
[ ] Configure automated IAM role assumption for GitHub Actions using OIDC.
[ ] Build production EKS cluster pipelines with Helm, Ingress-NGINX, and Cert-Manager.
[ ] Implement AWS CloudWatch custom metrics and synthetic alarms.

GCP Deep-Dive Goals
[ ] Provision GKE Autopilot clusters using Terraform Google Provider.
[ ] Deploy microservices to Google Cloud Run with automated Cloud Build triggers.
[ ] Configure global HTTP(S) Load Balancing with Google-managed SSL certificates.
[ ] Set up Cloud Monitoring alerting policies connected to Slack/PagerDuty.

--------------------------------------------------------------------------------

16. Key Takeaways

1. Cloud is an Ecosystem: It extends far beyond simple VM provisioning to managed orchestration, storage, security, and networking.
2. Architectural Parity: AWS and GCP provide equivalent enterprise capabilities with nuances in networking topology and resource hierarchies.
3. Decoupled Architecture: Separating storage (S3/GCS) from compute (EC2/GCE) enables resilient, stateless application scaling.
4. Security is Job Zero: IAM and the Principle of Least Privilege are paramount across all cloud platforms.
5. Observability Closes the Loop: Continuous monitoring with Prometheus, Grafana, CloudWatch, and Cloud Monitoring ensures operational health post-deployment.
6. Toolchain Continuity: Containerization and Infrastructure as Code form the portable bridge connecting local development to multi-cloud production.

--------------------------------------------------------------------------------

Conclusion

Task 6 provided a comprehensive comparative understanding of AWS and GCP from an engineering perspective. By bridging my existing hands-on experience with Docker, Kubernetes, Jenkins, Trivy, SonarQube, and Prometheus/Grafana with enterprise cloud platforms, I have established a clear mental model of how modern software delivery pipelines operate in the cloud.

As I progress in my DevOps internship, I will continue applying these cloud computing fundamentals through hands-on Infrastructure as Code, Kubernetes deployments, and cloud-native observability workflows.
