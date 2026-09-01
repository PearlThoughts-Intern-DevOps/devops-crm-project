# AWS & GCP Cloud Platforms – Learning Documentation

## 1. Introduction

As part of this task, I explored two major cloud platforms, **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**. I studied their core cloud concepts, commonly used services, networking, storage, databases, Kubernetes, serverless computing, monitoring, and their use in DevOps workflows.

The main goal of this learning was to understand how similar cloud requirements can be implemented using different cloud providers and to identify the key differences between AWS and GCP.

---

## 2. AWS Overview

Amazon Web Services (AWS) is a cloud platform that provides services for computing, storage, networking, databases, security, containers, serverless applications, monitoring, and many other workloads.

The important AWS services I explored are:

* EC2
* S3
* VPC
* IAM
* RDS
* EKS
* ECR
* Route 53
* Lambda
* CloudWatch

### EC2 – Compute

Amazon EC2 provides virtual machines in the AWS cloud.

Instead of purchasing and maintaining a physical server, users can create virtual machines with selected CPU, memory, storage, operating system, and networking configuration.

EC2 is useful for running applications, web servers, Docker workloads, CI/CD tools, and other server-based applications.

### S3 – Object Storage

Amazon S3 is an object storage service.

Data is stored as objects inside buckets. It can be used for images, documents, backups, logs, build artifacts, and other unstructured data.

Basic structure:

```text
S3
 |
 └── Bucket
      ├── file1
      ├── file2
      └── backup.zip
```

### VPC – Networking

Amazon VPC provides a virtual networking environment for AWS resources.

It allows resources such as EC2 instances to communicate through configured networks and subnets.

Important VPC concepts include:

* VPC
* Subnets
* Route tables
* Internet Gateway
* Security Groups
* Network ACLs

### IAM – Identity and Access Management

AWS IAM controls access to AWS resources.

It can be used to manage users, roles, policies, and permissions.

A key security principle is **least privilege**, where users and workloads receive only the permissions they require.

For example:

```text
EC2
 ↓
IAM Role
 ↓
Permission
 ↓
S3
```

### RDS – Managed Database

Amazon RDS is a managed relational database service.

It supports database engines such as PostgreSQL, MySQL, MariaDB, Oracle, and SQL Server.

RDS reduces the operational effort required to manage database infrastructure because AWS handles many infrastructure-level tasks such as maintenance, backups, and availability features depending on configuration.

### EKS – Managed Kubernetes

Amazon EKS (Elastic Kubernetes Service) is AWS's managed Kubernetes service.

It allows Kubernetes workloads to run on AWS while AWS manages the Kubernetes control-plane infrastructure.

Conceptually:

```text
EKS
 |
 ├── Kubernetes control plane
 |
 └── Worker compute
       ├── Pod
       └── Pod
```

EKS is useful for running containerized applications using Kubernetes.

### ECR – Container Registry

Amazon ECR (Elastic Container Registry) is a container image registry.

A typical container workflow is:

```text
Source Code
    ↓
Docker Build
    ↓
Docker Image
    ↓
ECR
    ↓
EKS
    ↓
Kubernetes Pod
```

ECR provides a place to store container images that can later be deployed to EKS or other AWS compute environments.

### Route 53 – DNS

Amazon Route 53 is AWS's DNS service.

DNS translates domain names into addresses or routes traffic according to configured DNS records and routing policies.

For example:

```text
novapay.example
       ↓
Route 53
       ↓
Application / Load Balancer
```

### Lambda – Serverless Computing

AWS Lambda is a serverless compute service that runs code in response to events.

For example:

```text
File uploaded to S3
        ↓
      Event
        ↓
     Lambda
        ↓
 Process file
```

The underlying server infrastructure is managed by AWS, so developers can focus mainly on the function code.

### CloudWatch – Monitoring

Amazon CloudWatch provides monitoring and observability capabilities for AWS resources and applications.

It can be used for metrics, logs, dashboards, and alarms.

For example:

```text
EC2
 ↓
Metrics / Logs
 ↓
CloudWatch
 ↓
Dashboard / Alarm
```

---

## 3. GCP Overview

Google Cloud Platform (GCP) is Google's cloud platform. It provides compute, storage, networking, databases, Kubernetes, identity, serverless, monitoring, and other cloud services.

The important GCP services I explored are:

* Compute Engine
* Cloud Storage
* VPC
* Cloud IAM
* Cloud SQL
* GKE
* Artifact Registry
* Cloud DNS
* Cloud Functions
* Cloud Run
* Cloud Monitoring

### Compute Engine – Compute

Google Compute Engine provides virtual machines on Google Cloud.

It is conceptually similar to AWS EC2.

```text
GCP
 ↓
Compute Engine
 ↓
Virtual Machine
 ↓
Operating System
 ↓
Application
```

It can be used for web servers, application servers, Docker workloads, CI/CD tools, and other workloads that require virtual machines.

### Cloud Storage – Object Storage

Google Cloud Storage is GCP's object storage service.

Data is stored as objects inside buckets.

```text
Cloud Storage
 |
 └── Bucket
      ├── image.jpg
      ├── report.pdf
      └── backup.zip
```

It can be used for backups, media, documents, artifacts, and other unstructured data.

### VPC – Networking

GCP VPC provides networking for Google Cloud resources.

One important difference from AWS is that a **GCP VPC network is global**, while its **subnets are regional**.

For example:

```text
Global VPC
 |
 ├── Mumbai Subnet
 |     └── VM
 |
 └── Singapore Subnet
       └── VM
```

GCP VPC also provides firewall rules and routing capabilities.

### Cloud IAM – Identity and Access Management

Cloud IAM controls access to GCP resources.

It uses identities/principals, roles, and permissions to determine what users and workloads can do.

Service accounts can be used to provide identities for workloads.

For example:

```text
Compute Engine
      ↓
Service Account
      ↓
IAM Role
      ↓
Permissions
      ↓
Cloud Storage
```

Like AWS IAM, GCP IAM supports the principle of least privilege.

### Cloud SQL – Managed Database

Cloud SQL is GCP's managed relational database service.

It supports database engines such as:

* PostgreSQL
* MySQL
* SQL Server

Cloud SQL reduces the infrastructure management required to run relational databases.

### GKE – Managed Kubernetes

GKE (Google Kubernetes Engine) is Google's managed Kubernetes service.

It allows organizations to run Kubernetes workloads on Google Cloud.

```text
GKE
 |
 ├── Kubernetes cluster
 |
 ├── Node
 |    └── Pod
 |
 └── Node
      └── Pod
```

GKE integrates Kubernetes with other GCP services such as IAM, VPC networking, load balancing, and storage.

### Artifact Registry – Container Registry

Artifact Registry is GCP's managed repository for artifacts, including container images.

A typical workflow is:

```text
Source Code
    ↓
Docker Build
    ↓
Container Image
    ↓
Artifact Registry
    ↓
GKE
    ↓
Kubernetes Pod
```

### Cloud DNS – DNS

Cloud DNS is GCP's managed DNS service.

It provides DNS hosting and allows domain names to be mapped to applications and other services.

```text
Domain
   ↓
Cloud DNS
   ↓
Application / Load Balancer
```

### Cloud Functions – Serverless Functions

Cloud Functions is a serverless compute service that executes code in response to events or requests.

For example:

```text
Cloud Storage
     ↓
File uploaded
     ↓
Event
     ↓
Cloud Function
     ↓
Process file
```

It is conceptually similar to AWS Lambda.

### Cloud Run – Containerized Serverless Computing

Cloud Run is a managed platform for running containerized applications.

Instead of managing virtual machines or Kubernetes clusters directly, a container image can be deployed to Cloud Run.

```text
Docker Image
     ↓
Cloud Run
     ↓
Running Application
```

Cloud Run is useful when an application is packaged as a container and needs a managed serverless execution environment.

### Cloud Monitoring – Monitoring

Cloud Monitoring provides metrics, dashboards, and alerting capabilities for GCP resources and applications.

For example:

```text
Compute Engine
      ↓
Metrics
      ↓
Cloud Monitoring
      ↓
Dashboard / Alert
```

GCP also has **Cloud Logging**, which is used for log management separately from Cloud Monitoring.

---

## 4. AWS and GCP Service Comparison

| Requirement          | AWS        | GCP               |
| -------------------- | ---------- | ----------------- |
| Virtual Machines     | EC2        | Compute Engine    |
| Object Storage       | S3         | Cloud Storage     |
| Networking           | VPC        | VPC               |
| Identity & Access    | IAM        | Cloud IAM         |
| Relational Database  | RDS        | Cloud SQL         |
| Managed Kubernetes   | EKS        | GKE               |
| Container Registry   | ECR        | Artifact Registry |
| DNS                  | Route 53   | Cloud DNS         |
| Serverless Functions | Lambda     | Cloud Functions   |
| Container Serverless | —          | Cloud Run         |
| Monitoring           | CloudWatch | Cloud Monitoring  |

These services provide similar capabilities, but their APIs, resource models, terminology, integrations, and implementation details are different.

---

## 5. Important Differences Between AWS and GCP

### 5.1 Resource Organization

AWS commonly organizes resources around accounts, regions, availability zones, and services.

GCP uses an organization hierarchy that can include:

```text
Organization
    ↓
Folder
    ↓
Project
    ↓
Resources
```

The GCP **Project** is an important boundary for organizing resources, IAM permissions, APIs, and billing.

### 5.2 Networking

One important networking difference is the scope of the VPC.

AWS:

```text
Region
 ↓
VPC
 ↓
Regional Subnets
```

GCP:

```text
Global VPC
 ↓
Regional Subnets
```

Therefore, a GCP VPC can contain subnets in different regions, while an AWS VPC is regional.

### 5.3 Security

AWS uses mechanisms such as **Security Groups** and Network ACLs.

GCP uses **VPC Firewall Rules**.

Both can control network traffic, but they are implemented differently.

AWS Security Groups are associated with network interfaces/instances, while GCP firewall rules are defined at the VPC network level and can target VM instances using mechanisms such as network tags or service accounts.

### 5.4 Kubernetes

AWS provides EKS and GCP provides GKE.

```text
AWS → EKS → Kubernetes

GCP → GKE → Kubernetes
```

Both provide managed Kubernetes, but their integration with the respective cloud provider's networking, IAM, storage, and load-balancing services differs.

### 5.5 Container Images

AWS uses ECR while GCP uses Artifact Registry.

```text
AWS:
Docker → ECR → EKS

GCP:
Docker → Artifact Registry → GKE
```

The overall DevOps workflow is similar even though the services are different.

### 5.6 Serverless

AWS provides Lambda for serverless functions.

GCP provides Cloud Functions for a similar function-oriented model and Cloud Run for running containerized applications in a managed environment.

```text
AWS:
Event → Lambda → Code

GCP:
Event → Cloud Functions → Code

GCP:
Container → Cloud Run → Application
```

---

## 6. AWS and GCP in a DevOps Workflow

Both cloud platforms can support a modern DevOps workflow.

A typical workflow is:

```text
Developer
    ↓
Git Repository
    ↓
CI/CD Pipeline
    ↓
Build & Test
    ↓
Docker Build
    ↓
Container Image
    ↓
Container Registry
    ↓
Kubernetes / Serverless
    ↓
Application
    ↓
Monitoring
```

### AWS implementation

```text
Git Repository
      ↓
CI/CD
      ↓
Docker
      ↓
ECR
      ↓
EKS
      ↓
Application
      ↓
CloudWatch
```

Supporting services can include:

```text
Route 53 → DNS
VPC → Networking
IAM → Access Control
RDS → Database
S3 → Object Storage
```

### GCP implementation

```text
Git Repository
      ↓
CI/CD
      ↓
Docker
      ↓
Artifact Registry
      ↓
GKE
      ↓
Application
      ↓
Cloud Monitoring
```

Supporting services can include:

```text
Cloud DNS → DNS
VPC → Networking
Cloud IAM → Access Control
Cloud SQL → Database
Cloud Storage → Object Storage
```

---

## 7. Terraform and Multi-Cloud Infrastructure

Terraform can be used as Infrastructure as Code to manage infrastructure on both AWS and GCP.

Instead of manually creating resources through cloud consoles, infrastructure can be defined as configuration files.

Conceptually:

```text
Terraform
    |
    ├── AWS Provider
    |      ├── VPC
    |      ├── EC2
    |      └── S3
    |
    └── GCP Provider
           ├── VPC
           ├── Compute Engine
           └── Cloud Storage
```

The general workflow is:

```text
Terraform Configuration
        ↓
terraform plan
        ↓
Review Changes
        ↓
terraform apply
        ↓
Cloud Infrastructure
```

This provides repeatability, version control, and automation for infrastructure management.

---

## 8. Applying This to the Twenty CRM Project (Task 5)

Connecting this back to the Docker setup from Task 5, the local `docker-compose.yml` services map to managed equivalents on either cloud:

```text
Local Docker Compose          AWS                     GCP
--------------------          ---                     ---
server (container)      →     ECR + EKS/ECS      →    Artifact Registry + GKE/Cloud Run
postgres (container)    →     RDS (PostgreSQL)   →    Cloud SQL (PostgreSQL)
redis (container)       →     ElastiCache        →    Memorystore
.env secrets             →    Secrets Manager    →    Secret Manager
```

Of the two, Cloud Run stood out as the fastest path to production for a
single containerized service like this one — no cluster to provision,
scales to zero, and the image just needs to land in Artifact Registry. EKS
or GKE would make more sense if the org later runs multiple services and
wants one orchestration layer instead of managing several standalone
deployments.

---

## 9. Key Learnings

Through this task, I learned that AWS and GCP provide many equivalent cloud capabilities even though their services and implementations are different.

My main learnings include:

* Understanding the difference between physical infrastructure and cloud-managed resources.
* Understanding EC2 and Compute Engine as virtual machine services.
* Understanding S3 and Cloud Storage as object storage services.
* Understanding VPC networking and the difference between AWS and GCP VPC models.
* Understanding IAM and the principle of least privilege.
* Understanding RDS and Cloud SQL as managed relational database services.
* Understanding EKS and GKE as managed Kubernetes services.
* Understanding ECR and Artifact Registry as container image repositories.
* Understanding Route 53 and Cloud DNS as DNS services.
* Understanding Lambda and Cloud Functions as event-driven serverless services.
* Understanding Cloud Run as a managed platform for containerized applications.
* Understanding CloudWatch and Cloud Monitoring as cloud observability services.
* Understanding how containers, Kubernetes, cloud services, and CI/CD work together.
* Understanding how Terraform can be used to manage cloud infrastructure using Infrastructure as Code.
* Understanding how the Twenty CRM Docker setup from Task 5 would map onto managed services on either platform.

---

## 10. Conclusion

AWS and GCP both provide complete cloud platforms for building, deploying, and operating modern applications.

Although many services have similar purposes, the two platforms differ in their resource organization, networking models, IAM implementations, service features, terminology, and integrations.

From a DevOps perspective, both platforms support important practices such as:

```text
Infrastructure as Code
        ↓
CI/CD
        ↓
Containers
        ↓
Kubernetes
        ↓
Cloud Infrastructure
        ↓
Monitoring
```

Learning both platforms helps in understanding cloud-agnostic DevOps concepts while also recognizing the provider-specific tools used to implement them.

LOOM VIDEO LINK:-
[https://www.loom.com/share/6d9fdc7679e94763876bbe69e5b843f9]