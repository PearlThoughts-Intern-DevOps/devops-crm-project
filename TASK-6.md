# Task 6: AWS & GCP – Cloud Platform Study

## 1. Objective

The objective of this task is to explore and understand the fundamentals of Amazon Web Services (AWS) and Google Cloud Platform (GCP) from a DevOps perspective.

The main focus of this task is to understand commonly used cloud services for compute, networking, identity management, storage, databases, monitoring, containers, serverless applications, and Infrastructure as Code (IaC).

I also studied how commonly used AWS services relate to similar services and concepts available in GCP.

---

# 2. Introduction to AWS

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon. It provides on-demand infrastructure and managed services that can be used to build, deploy, and operate applications without maintaining physical infrastructure.

From a DevOps perspective, AWS provides services that help with:

* Application deployment
* Infrastructure provisioning
* Networking
* Containerization
* Monitoring
* Security and access control
* Database management
* Automation and scaling

Some of the AWS services I studied are:

* EC2
* VPC
* IAM
* RDS
* S3
* CloudWatch
* Lambda
* ECS
* EKS
* CloudFormation

---

# 3. AWS Global Infrastructure

AWS infrastructure is organized into geographical **Regions** and isolated **Availability Zones (AZs)**.

### Region

A Region is a geographical area containing AWS infrastructure.

For example:

* Mumbai (`ap-south-1`)
* Hyderabad (`ap-south-2`)
* Singapore (`ap-southeast-1`)
* Frankfurt (`eu-central-1`)

### Availability Zone

An Availability Zone is an isolated location within an AWS Region.

A production application can be deployed across multiple Availability Zones to improve availability and fault tolerance.

Example:

```text
AWS Region
    |
    +-- Availability Zone 1
    |
    +-- Availability Zone 2
    |
    +-- Availability Zone 3
```

Using multiple Availability Zones helps reduce the impact of a failure affecting a single location.

---

# 4. AWS Services I Studied

## 4.1 Amazon EC2

**Amazon Elastic Compute Cloud (EC2)** provides virtual machines in the AWS cloud.

An EC2 instance can be used to:

* Host web applications
* Run APIs
* Run Docker containers
* Install and configure software
* Run CI/CD tools
* Host development or production workloads

A simplified architecture is:

```text
User
 |
Internet
 |
Load Balancer
 |
EC2 Instance
 |
Application
```

From a DevOps perspective, EC2 is useful when we need control over the operating system, installed packages, networking, and application environment.

---

## 4.2 Amazon VPC

**Amazon Virtual Private Cloud (VPC)** allows us to create an isolated virtual network inside AWS.

Important VPC components include:

* VPC
* Subnets
* Route Tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Network ACLs

A common architecture is:

```text
                 Internet
                    |
              Internet Gateway
                    |
              Public Subnet
                    |
             Load Balancer
                    |
        -------------------------
        |                       |
 Private Subnet            Private Subnet
        |                       |
      EC2                     EC2
        \                       /
         \                     /
              RDS Database
```

VPC is important for controlling network connectivity and separating public and private resources.

---

## 4.3 AWS IAM

**AWS Identity and Access Management (IAM)** controls authentication and authorization.

IAM helps determine:

> Who can access which AWS resources and what actions they can perform?

Important IAM concepts include:

* Users
* Groups
* Roles
* Policies
* Permissions

For example, instead of storing AWS credentials directly inside an EC2 application, an IAM Role can be attached to the EC2 instance.

```text
EC2
 |
IAM Role
 |
Policy
 |
S3 Access
```

A major security principle is **least privilege**, meaning users and applications should receive only the permissions they actually need.

---

## 4.4 Amazon RDS

**Amazon Relational Database Service (RDS)** is a managed relational database service.

It supports database engines such as:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

RDS reduces the amount of manual database administration required for tasks such as backups, patching, and maintenance.

Example:

```text
Application
     |
     |
    RDS
     |
  MySQL/PostgreSQL
```

From a DevOps perspective, RDS can be placed in private subnets and accessed by application servers through controlled network rules.

---

## 4.5 Amazon S3

**Amazon Simple Storage Service (S3)** is an object storage service.

S3 can be used to store:

* Images
* Videos
* Documents
* Backups
* Logs
* Application files
* Static website files

S3 stores objects inside **buckets**.

Example:

```text
Application
     |
     v
    S3
     |
     +-- images/
     +-- backups/
     +-- documents/
```

S3 is highly useful in DevOps for storing build artifacts, backups, static files, and other application data.

---

## 4.6 Amazon CloudWatch

**Amazon CloudWatch** is used for monitoring and observability.

It can be used for:

* Metrics
* Logs
* Alarms
* Dashboards
* Monitoring AWS resources

For example:

```text
EC2
 |
CloudWatch
 |
CPU Utilization
 |
Alarm
 |
Notification
```

CloudWatch can help DevOps engineers identify performance issues and monitor application infrastructure.

---

## 4.7 AWS Lambda

**AWS Lambda** is a serverless compute service.

With Lambda, code can be executed in response to events without manually managing servers.

Example:

```text
Event
  |
  v
Lambda Function
  |
  v
Application Logic
```

Lambda can be triggered by services such as S3, API Gateway, EventBridge, and other AWS services.

From a DevOps perspective, Lambda is useful for event-driven automation and lightweight backend workloads.

---

## 4.8 Amazon ECS

**Amazon Elastic Container Service (ECS)** is a managed container orchestration service.

It can be used to run Docker containers on AWS.

A simplified workflow:

```text
Docker Image
     |
     v
Amazon ECR
     |
     v
Amazon ECS
     |
     v
Running Containers
```

ECS can be used when an application is containerized but the team does not necessarily want to manage Kubernetes.

---

## 4.9 Amazon EKS

**Amazon Elastic Kubernetes Service (EKS)** is AWS's managed Kubernetes service.

Kubernetes can be used to manage:

* Container deployment
* Scaling
* Service discovery
* Rolling updates
* Application availability

Example:

```text
Docker Images
      |
      v
     ECR
      |
      v
     EKS
      |
  Kubernetes
      |
  Containers
```

EKS is useful for organizations that require Kubernetes-based container orchestration.

---

## 4.10 AWS CloudFormation

**AWS CloudFormation** is an Infrastructure as Code (IaC) service.

Instead of manually creating resources, infrastructure can be defined using templates.

For example, infrastructure can describe:

```text
VPC
EC2
Security Group
Load Balancer
S3
RDS
```

This allows infrastructure to be:

* Version controlled
* Reproducible
* Automated
* Consistent

As a DevOps engineer, IaC helps reduce manual configuration and configuration drift.

---

# 5. Introduction to GCP

**Google Cloud Platform (GCP)**, commonly called Google Cloud, is Google's cloud computing platform.

It provides cloud services for:

* Compute
* Networking
* Storage
* Databases
* Containers
* Kubernetes
* Serverless applications
* Monitoring
* Security
* Data and analytics

Although the service names are different from AWS, many GCP services provide similar functionality.

---

# 6. GCP Global Infrastructure

Google Cloud organizes its infrastructure primarily into:

* Regions
* Zones

A **Region** represents a geographical location, while a **Zone** is an isolated deployment area within a region.

Example:

```text
GCP Region
    |
    +-- Zone 1
    |
    +-- Zone 2
    |
    +-- Zone 3
```

Applications can be distributed across multiple zones to improve availability and fault tolerance.

GCP also provides a global network infrastructure that is used by many of its networking and load-balancing services.

---

# 7. GCP Services Related to the AWS Services I Studied

## 7.1 EC2 → Compute Engine

AWS EC2 provides virtual machines.

The closest GCP equivalent is **Compute Engine**.

```text
AWS                     GCP

EC2       ----------->  Compute Engine
```

Both can be used to:

* Run Linux/Windows virtual machines
* Host applications
* Run Docker
* Configure networking
* Install software
* Manage compute workloads

---

## 7.2 VPC → VPC

Both AWS and GCP provide VPC networking.

```text
AWS VPC  ----------->  Google Cloud VPC
```

They provide networking functionality such as:

* Subnets
* Routes
* Firewall/network security controls
* Private connectivity

One important difference is that Google Cloud VPC networks are global resources, whereas AWS VPCs are regional.

---

## 7.3 IAM → Cloud IAM

AWS IAM and Google Cloud IAM provide identity and access management.

```text
AWS IAM  ----------->  Google Cloud IAM
```

Both allow administrators to control:

* Identities
* Roles
* Permissions
* Access to resources

GCP also uses service accounts for workloads and applications.

The core security principle in both platforms is to follow **least privilege**.

---

## 7.4 RDS → Cloud SQL

AWS RDS is a managed relational database service.

The closest GCP equivalent is **Cloud SQL**.

```text
AWS                     GCP

RDS       ----------->  Cloud SQL
```

Both can manage relational databases such as:

* MySQL
* PostgreSQL

They reduce the operational effort required to manage database infrastructure.

---

## 7.5 S3 → Cloud Storage

AWS S3 is an object storage service.

The corresponding GCP service is **Cloud Storage**.

```text
AWS                     GCP

S3        ----------->  Cloud Storage
```

Both can be used for:

* Backups
* Files
* Application assets
* Static content
* Build artifacts

---

## 7.6 CloudWatch → Cloud Monitoring and Cloud Logging

AWS CloudWatch provides monitoring and logging functionality.

In GCP, similar functionality is provided through:

* **Cloud Monitoring**
* **Cloud Logging**

```text
AWS                     GCP

CloudWatch  ----------> Cloud Monitoring
                         Cloud Logging
```

Cloud Monitoring focuses on metrics, dashboards, and alerting, while Cloud Logging provides centralized log management.

---

## 7.7 Lambda → Cloud Functions / Cloud Run

AWS Lambda provides serverless execution.

GCP provides services such as:

* Cloud Functions
* Cloud Run

The exact choice depends on the workload.

```text
AWS Lambda
     |
     +----> GCP Cloud Functions
     |
     +----> GCP Cloud Run
```

Cloud Functions is useful for event-driven functions, while Cloud Run is particularly useful for deploying containerized applications.

Therefore, this is not a strict one-to-one mapping.

---

## 7.8 ECS → Cloud Run / GKE

AWS ECS is a container orchestration service.

In GCP, container workloads can be deployed using services such as:

* Cloud Run
* Google Kubernetes Engine (GKE)

The appropriate service depends on the application's requirements.

For simple managed container deployment, Cloud Run can be a good option.

For Kubernetes-based orchestration, GKE is the more appropriate comparison.

---

## 7.9 EKS → GKE

AWS EKS is a managed Kubernetes service.

The closest GCP equivalent is **Google Kubernetes Engine (GKE)**.

```text
AWS                     GCP

EKS       ----------->  GKE
```

Both provide managed Kubernetes environments for deploying and managing containerized applications.

---

## 7.10 CloudFormation → Infrastructure as Code

AWS CloudFormation is an AWS-native Infrastructure as Code service.

There is not a direct one-to-one GCP equivalent that should simply be called "CloudFormation for GCP."

For multi-cloud Infrastructure as Code, **Terraform** is commonly used.

```text
Terraform
    |
    +---- AWS
    |
    +---- GCP
```

This makes Terraform particularly useful when a DevOps engineer needs to manage infrastructure across multiple cloud providers.

---

# 8. AWS vs GCP Service Mapping

| Category               | AWS                             | GCP                              |
| ---------------------- | ------------------------------- | -------------------------------- |
| Virtual Machine        | EC2                             | Compute Engine                   |
| Virtual Network        | VPC                             | VPC                              |
| Identity & Access      | IAM                             | Cloud IAM                        |
| Managed Relational DB  | RDS                             | Cloud SQL                        |
| Object Storage         | S3                              | Cloud Storage                    |
| Monitoring             | CloudWatch / CloudWatch Metrics | Cloud Monitoring                 |
| Logging                | CloudWatch Logs                 | Cloud Logging                    |
| Serverless Functions   | Lambda                          | Cloud Functions                  |
| Managed Containers     | ECS                             | Cloud Run / GKE                  |
| Managed Kubernetes     | EKS                             | GKE                              |
| Infrastructure as Code | CloudFormation                  | Terraform / Google Cloud tooling |

These mappings represent similar use cases and are not necessarily exact one-to-one equivalents.

---

# 9. AWS vs GCP – Networking

Both platforms provide cloud networking capabilities, but their architecture and terminology differ.

| Concept              | AWS                    | GCP                     |
| -------------------- | ---------------------- | ----------------------- |
| Virtual Network      | VPC                    | VPC                     |
| Subnet               | Regional               | Regional                |
| Firewall/Security    | Security Groups, NACLs | VPC Firewall Rules      |
| Load Balancing       | Elastic Load Balancing | Cloud Load Balancing    |
| DNS                  | Route 53               | Cloud DNS               |
| Private connectivity | VPN, Direct Connect    | VPN, Cloud Interconnect |

A key difference is that an AWS VPC is regional, while a Google Cloud VPC is global.

---

# 10. Compute Comparison

| AWS    | GCP                         | Purpose              |
| ------ | --------------------------- | -------------------- |
| EC2    | Compute Engine              | Virtual machines     |
| ECS    | Cloud Run / GKE             | Containers           |
| EKS    | GKE                         | Managed Kubernetes   |
| Lambda | Cloud Functions / Cloud Run | Serverless workloads |

The choice depends on the application's requirements.

For example:

* VM-level control → EC2 / Compute Engine
* Managed containers → ECS / Cloud Run
* Kubernetes → EKS / GKE
* Event-driven functions → Lambda / Cloud Functions

---

# 11. Storage Comparison

| AWS | GCP             | Type           |
| --- | --------------- | -------------- |
| S3  | Cloud Storage   | Object storage |
| EBS | Persistent Disk | Block storage  |
| EFS | Filestore       | File storage   |

Object storage is useful for files and artifacts, block storage is generally attached to compute workloads, and file storage provides shared filesystem-style access.

---

# 12. Database Comparison

| AWS      | GCP                                           | Purpose                     |
| -------- | --------------------------------------------- | --------------------------- |
| RDS      | Cloud SQL                                     | Managed relational database |
| DynamoDB | Firestore / Bigtable                          | NoSQL workloads             |
| Aurora   | Cloud SQL / Spanner depending on requirements | Managed database workloads  |

The services are not exact equivalents in every scenario, so the architecture and workload requirements should be considered before choosing a service.

---

# 13. Container and Kubernetes Comparison

Containerization allows applications to be packaged with their dependencies.

A typical AWS workflow can be:

```text
Docker
  |
  v
ECR
  |
  v
ECS / EKS
```

A similar GCP workflow can be:

```text
Docker
  |
  v
Artifact Registry
  |
  v
Cloud Run / GKE
```

For Kubernetes:

```text
AWS EKS  <-------->  GCP GKE
```

Both are managed Kubernetes services.

---

# 14. Monitoring and Logging Comparison

Monitoring is important for understanding the health and performance of infrastructure and applications.

| AWS                | GCP                 |
| ------------------ | ------------------- |
| CloudWatch Metrics | Cloud Monitoring    |
| CloudWatch Logs    | Cloud Logging       |
| CloudWatch Alarms  | Monitoring Alerting |
| CloudTrail         | Cloud Audit Logs    |

Monitoring can help identify:

* High CPU utilization
* Memory/resource issues
* Application errors
* Failed requests
* Infrastructure problems

---

# 15. DevOps and CI/CD Perspective

Both AWS and GCP provide services that can be integrated into CI/CD pipelines.

A typical DevOps workflow can look like:

```text
Developer
    |
    v
Git Repository
    |
    v
CI Pipeline
    |
    v
Build
    |
    v
Test
    |
    v
Container Image
    |
    v
Container Registry
    |
    v
Deployment
    |
    v
Cloud Infrastructure
    |
    v
Monitoring
```

For AWS, services such as CodeBuild, CodeDeploy, and CodePipeline can be used for CI/CD.

For GCP, services such as Cloud Build, Cloud Deploy, and Artifact Registry can be used.

Tools such as **GitHub Actions, Jenkins, and Terraform** can also be used with both cloud platforms.

---

# 16. Infrastructure as Code

Infrastructure as Code allows infrastructure to be managed using configuration files instead of manually creating resources.

For AWS:

```text
CloudFormation / Terraform
          |
          v
        AWS
```

For GCP:

```text
Terraform
    |
    v
   GCP
```

Terraform is especially useful for DevOps engineers working with multiple cloud providers because the same IaC approach can be used across AWS and GCP.

Benefits include:

* Automation
* Version control
* Repeatability
* Consistency
* Easier infrastructure changes
* Reduced manual configuration

---

# 17. IAM and Security Comparison

| Area              | AWS                     | GCP                                  |
| ----------------- | ----------------------- | ------------------------------------ |
| IAM               | AWS IAM                 | Cloud IAM                            |
| Workload identity | IAM Roles               | Service Accounts / Workload Identity |
| Secrets           | Secrets Manager         | Secret Manager                       |
| Audit logs        | CloudTrail              | Cloud Audit Logs                     |
| Network security  | Security Groups, NACLs  | VPC Firewall Rules                   |
| Encryption        | AWS encryption services | Google Cloud encryption services     |

Common security practices for both platforms include:

1. Follow least privilege.
2. Avoid hardcoding credentials.
3. Use roles/service accounts for workloads.
4. Store secrets in managed secret stores.
5. Restrict network access.
6. Use HTTPS/TLS.
7. Monitor and audit cloud activity.
8. Keep resources and dependencies updated.

---

# 18. Pricing Overview

AWS and GCP both follow usage-based cloud pricing models for many services.

The cost of a cloud environment depends on factors such as:

* Compute usage
* Storage
* Network traffic
* Database usage
* Number of requests
* Resource size
* Data transfer
* Monitoring/log retention

For DevOps engineers, cost optimization is also an important responsibility.

Some common practices include:

* Removing unused resources
* Choosing appropriate instance sizes
* Using autoscaling
* Managing storage lifecycle policies
* Monitoring network/data-transfer costs
* Setting budgets and alerts
* Reviewing resource utilization regularly

Cloud resources should not be left running unnecessarily because they can continue generating charges.

---

# 19. Key Differences Between AWS and GCP

Some important differences I learned are:

### 1. Service naming

AWS and GCP often provide similar functionality but use different service names.

Example:

```text
EC2          → Compute Engine
S3           → Cloud Storage
RDS          → Cloud SQL
EKS          → GKE
Lambda       → Cloud Functions
```

### 2. Global infrastructure

AWS uses Regions and Availability Zones, while GCP uses Regions and Zones.

### 3. Networking

AWS VPCs are regional, whereas Google Cloud VPC networks are global resources.

### 4. Kubernetes

Both provide managed Kubernetes:

```text
AWS → EKS
GCP → GKE
```

### 5. Infrastructure as Code

AWS provides CloudFormation as an AWS-native IaC service, while Terraform provides a common multi-cloud IaC approach that can manage both AWS and GCP.

### 6. Service ecosystem

Both platforms provide a very large range of services, but the service organization, terminology, and implementation details are different.

---

# 20. What I Learned

Through this task, I learned that AWS and GCP provide similar fundamental cloud capabilities even though their service names and implementations are different.

The main concepts I understood are:

* How cloud Regions and Availability Zones/Zones work
* How virtual machines are provisioned
* How cloud networking is structured
* How IAM controls access
* How managed databases reduce operational effort
* How object storage can be used for application data and artifacts
* How monitoring and logging help operate applications
* How containers can be deployed using managed cloud services
* How managed Kubernetes works
* How serverless computing reduces infrastructure management
* How Infrastructure as Code helps automate cloud infrastructure
* How AWS and GCP services can be mapped based on their use cases
* Why security and cost management are important in cloud environments

From a DevOps perspective, I learned that cloud platforms are not only about running servers. They provide a complete ecosystem for building, deploying, securing, monitoring, and scaling applications.

---

# 21. Practical DevOps Use Cases

## Use Case 1 – Web Application Deployment

A web application can be deployed using:

```text
Users
  |
Load Balancer
  |
EC2 / Compute Engine
  |
Application
  |
RDS / Cloud SQL
```

This provides a basic production-style architecture.

---

## Use Case 2 – Containerized Application

```text
Developer
   |
GitHub
   |
CI Pipeline
   |
Docker Build
   |
Container Registry
   |
ECS/EKS or Cloud Run/GKE
   |
Application
```

This approach is useful for modern containerized applications.

---

## Use Case 3 – Infrastructure Automation

```text
Terraform / CloudFormation
          |
          v
Cloud Infrastructure
          |
   +------+------+
   |      |      |
  VPC    EC2    RDS
```

Infrastructure can be created consistently instead of manually configuring every resource.

---

## Use Case 4 – Monitoring

```text
Application
     |
Infrastructure
     |
Monitoring
     |
Metrics + Logs
     |
Alerts
     |
DevOps Engineer
```

Monitoring helps detect problems before they significantly affect users.

---

# 22. Conclusion

AWS and GCP are powerful cloud platforms that provide the infrastructure and managed services required to build and operate modern applications.

Although their service names and architectures differ, the fundamental concepts are similar:

```text
Compute
Networking
Storage
Identity
Databases
Containers
Kubernetes
Serverless
Monitoring
Security
Automation
```

For a DevOps engineer, understanding these concepts is more important than memorizing service names.

My study of AWS and GCP helped me understand how cloud infrastructure can be provisioned, secured, automated, monitored, and used for application deployment.

The knowledge gained from this task will also help me understand multi-cloud environments and choose appropriate cloud services based on application and operational requirements.

---

# 24. Loom Video

The task explanation was recorded in two parts:

- [Loom Video – Part 1](https://www.loom.com/share/719c944efcdb41f0b0cc94f244100507)
- [Loom Video – Part 2](https://www.loom.com/share/2b41fb2089684008a26711d2e4646b72)
