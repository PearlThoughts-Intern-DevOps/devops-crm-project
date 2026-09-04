# Task 6 - AWS & GCP

**Name:** Prabhas Nalajala
**Project:** devops-crm-project
**Task:** AWS & GCP

---

## 1. Objective

The objective of this task is to explore **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**, understand their major cloud services, and learn how these services are used in modern DevOps environments.

This document covers the top seven services from AWS and GCP, their purpose, common DevOps use cases, service comparisons, and example cloud-based DevOps workflows.

---

# 2. Introduction to Cloud Computing

Cloud computing provides computing resources and services over the internet instead of requiring organizations to maintain physical infrastructure.

Cloud platforms provide services for:

- Compute
- Storage
- Databases
- Networking
- Security
- Containers
- Kubernetes
- Serverless applications
- Monitoring
- Logging

### Benefits of Cloud Computing

| Benefit | Description |
|---|---|
| **Scalability** | Resources can be increased or decreased according to workload requirements. |
| **High Availability** | Applications can be designed to remain available even when individual resources fail. |
| **Flexibility** | Organizations can choose different services based on their requirements. |
| **Cost Efficiency** | Organizations can pay for the resources they use instead of maintaining physical infrastructure. |
| **Global Infrastructure** | Applications can be deployed across different geographic locations. |
| **Managed Services** | Cloud providers manage many infrastructure and operational tasks. |
| **Automation** | Cloud resources can be provisioned and managed using automation and Infrastructure as Code. |

---

# 3. Amazon Web Services (AWS)

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon.

AWS provides services for compute, storage, databases, networking, security, containers, serverless applications, monitoring, and many other workloads.

---

# 4. Top 7 AWS Services

The following are seven important AWS services that I studied from a DevOps perspective.

| # | AWS Service | Category | Description | DevOps Use |
|---|---|---|---|---|
| 1 | **Amazon EC2** | Compute | Provides virtual servers in the AWS cloud. | Host applications, web servers, backend services, and CI/CD workloads. |
| 2 | **Amazon S3** | Storage | Provides object storage for files and data. | Store backups, build artifacts, logs, and static website content. |
| 3 | **Amazon RDS** | Database | Provides managed relational databases. | Run application databases without managing database infrastructure manually. |
| 4 | **Amazon VPC** | Networking | Provides an isolated virtual network for AWS resources. | Configure subnets, routing, security groups, and network connectivity. |
| 5 | **AWS IAM** | Security | Manages identities, roles, policies, and permissions. | Control secure access to AWS resources. |
| 6 | **Amazon ECS / EKS** | Containers | ECS runs containers and EKS provides managed Kubernetes. | Deploy and manage containerized applications. |
| 7 | **Amazon CloudWatch** | Monitoring | Provides metrics, logs, dashboards, and alarms. | Monitor applications, infrastructure, and system health. |

---

## 4.1 Amazon EC2

**Amazon Elastic Compute Cloud (EC2)** provides virtual servers in AWS.

### Common Uses

- Hosting web applications
- Running backend services
- Hosting development environments
- Running CI/CD workloads
- Running application servers

### Important Concepts

- Instance types
- Amazon Machine Images (AMIs)
- Security groups
- Key pairs
- EBS volumes
- Auto Scaling

### DevOps Relevance

EC2 can be used as infrastructure for hosting applications and running automated workloads.

---

## 4.2 Amazon S3

**Amazon Simple Storage Service (S3)** is an object storage service.

### Common Uses

- Application files
- Backups
- Logs
- Static website content
- Build artifacts

### Important Concepts

- Buckets
- Objects
- Storage classes
- Versioning
- Lifecycle policies
- Access policies

### DevOps Relevance

S3 can be used to store build artifacts, backups, logs, and static application files.

---

## 4.3 Amazon RDS

**Amazon Relational Database Service (RDS)** is a managed relational database service.

### Supported Database Engines

- PostgreSQL
- MySQL
- MariaDB
- Oracle
- SQL Server

### DevOps Relevance

RDS reduces the amount of infrastructure administration required for relational databases by providing managed database capabilities.

---

## 4.4 Amazon VPC

**Amazon Virtual Private Cloud (VPC)** provides an isolated virtual network for AWS resources.

### Important Components

| Component | Purpose |
|---|---|
| VPC | Provides the virtual network |
| Subnet | Divides the network into smaller segments |
| Route Table | Controls traffic routing |
| Internet Gateway | Provides internet connectivity |
| NAT Gateway | Allows private resources to access external networks |
| Security Group | Controls traffic to resources |
| Network ACL | Provides subnet-level traffic control |

### DevOps Relevance

VPC is important for designing secure and controlled application infrastructure.

---

## 4.5 AWS IAM

**AWS Identity and Access Management (IAM)** controls access to AWS resources.

### IAM Components

| Component | Purpose |
|---|---|
| Users | Represents individual identities |
| Groups | Organizes users |
| Roles | Provides permissions to trusted entities |
| Policies | Define permissions |
| Permissions | Define allowed actions |

### Security Principle

The **principle of least privilege** should be followed.

Users and services should receive only the permissions required to perform their tasks.

---

## 4.6 Amazon ECS / EKS

### Amazon ECS

Amazon Elastic Container Service (ECS) is a managed container orchestration service.

It can be used to run Docker containers.

### Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is AWS's managed Kubernetes service.

### DevOps Relevance

ECS and EKS can be used to deploy, scale, and manage containerized applications.

---

## 4.7 Amazon CloudWatch

**Amazon CloudWatch** provides monitoring and observability.

### Capabilities

| Capability | Purpose |
|---|---|
| Metrics | Monitor resource and application performance |
| Logs | Collect application and system logs |
| Alarms | Detect specific conditions |
| Dashboards | Visualize monitoring information |

### DevOps Relevance

CloudWatch helps DevOps engineers monitor applications, troubleshoot issues, and create alerts.

---

# 5. Google Cloud Platform (GCP)

Google Cloud Platform (GCP) is Google's cloud computing platform.

GCP provides services for compute, storage, databases, networking, security, containers, Kubernetes, serverless applications, monitoring, and logging.

---

# 6. Top 7 GCP Services

The following are seven important GCP services that I studied from a DevOps perspective.

| # | GCP Service | Category | Description | DevOps Use |
|---|---|---|---|---|
| 1 | **Compute Engine** | Compute | Provides virtual machines in Google Cloud. | Host applications, web servers, and backend services. |
| 2 | **Cloud Storage** | Storage | Provides object storage for files and data. | Store backups, build artifacts, logs, and static content. |
| 3 | **Cloud SQL** | Database | Provides managed relational databases. | Run application databases without managing infrastructure manually. |
| 4 | **VPC** | Networking | Provides networking for Google Cloud resources. | Configure networks, subnets, routes, and firewall rules. |
| 5 | **Cloud IAM** | Security | Manages identities, roles, and permissions. | Control secure access to Google Cloud resources. |
| 6 | **Cloud Run / GKE** | Containers | Cloud Run runs containers as a managed service and GKE provides managed Kubernetes. | Deploy and manage containerized applications. |
| 7 | **Cloud Monitoring** | Monitoring | Provides metrics, dashboards, alerts, and monitoring capabilities. | Monitor applications and infrastructure. |

---

## 6.1 Compute Engine

**Google Compute Engine** provides virtual machines in Google Cloud.

### Common Uses

- Web servers
- Application hosting
- Backend services
- Development environments

### DevOps Relevance

Compute Engine can be used to host applications and infrastructure workloads.

It provides similar functionality to Amazon EC2.

---

## 6.2 Cloud Storage

**Google Cloud Storage** is an object storage service.

### Common Uses

- Application files
- Backups
- Logs
- Static content
- Data storage
- Build artifacts

### DevOps Relevance

Cloud Storage can be used to store application artifacts, backups, and other objects.

It provides similar functionality to Amazon S3.

---

## 6.3 Cloud SQL

**Cloud SQL** is a managed relational database service.

### Supported Databases

- MySQL
- PostgreSQL
- SQL Server

### DevOps Relevance

Cloud SQL provides managed databases and reduces the infrastructure administration required for database workloads.

---

## 6.4 GCP VPC

**Google Cloud VPC** provides networking capabilities for Google Cloud resources.

### Important Components

| Component | Purpose |
|---|---|
| VPC Network | Provides the cloud network |
| Subnet | Divides the network into segments |
| Routes | Controls network traffic |
| Firewall Rules | Controls network access |
| Load Balancing | Distributes application traffic |

### DevOps Relevance

VPC is used to design secure network architectures and control communication between cloud resources.

---

## 6.5 Cloud IAM

**Google Cloud IAM** manages identities, roles, and permissions.

### Important Concepts

| Concept | Purpose |
|---|---|
| Identity | Represents a user or service |
| Role | Provides a collection of permissions |
| Permission | Defines an allowed action |
| Policy | Assigns roles to identities |

### DevOps Relevance

Cloud IAM is important for controlling access to infrastructure and applications.

The principle of least privilege should be followed.

---

## 6.6 Cloud Run / GKE

### Cloud Run

Cloud Run is a managed service for running containerized applications.

It allows applications packaged as containers to be deployed without directly managing servers.

### Google Kubernetes Engine

GKE is Google's managed Kubernetes service.

It provides Kubernetes infrastructure for deploying and managing containerized applications.

### DevOps Relevance

Cloud Run and GKE are useful for deploying modern containerized applications.

---

## 6.7 Cloud Monitoring

**Google Cloud Monitoring** provides monitoring and observability.

### Capabilities

- Metrics
- Dashboards
- Alerts
- Resource monitoring
- Application monitoring

### DevOps Relevance

Cloud Monitoring helps identify performance issues, monitor infrastructure, and maintain application availability.

---

# 7. AWS vs GCP Service Comparison

The following table shows services that provide similar functionality. These services are not necessarily identical because each cloud provider has its own architecture and features.

| Category | AWS | GCP | Purpose |
|---|---|---|---|
| **Virtual Machines** | EC2 | Compute Engine | Run virtual machines |
| **Object Storage** | S3 | Cloud Storage | Store objects and files |
| **Relational Database** | RDS | Cloud SQL | Managed relational databases |
| **Networking** | VPC | VPC | Cloud networking |
| **Identity & Access** | IAM | Cloud IAM | Manage identities and permissions |
| **Containers** | ECS / EKS | Cloud Run / GKE | Run containerized applications |
| **Monitoring** | CloudWatch | Cloud Monitoring | Monitor applications and infrastructure |

---

# 8. Quick Service Mapping

| AWS | GCP | Main Function |
|---|---|---|
| EC2 | Compute Engine | Virtual Machines |
| S3 | Cloud Storage | Object Storage |
| RDS | Cloud SQL | Relational Database |
| VPC | VPC | Networking |
| IAM | Cloud IAM | Security and Access |
| ECS / EKS | Cloud Run / GKE | Containers and Kubernetes |
| CloudWatch | Cloud Monitoring | Monitoring |

---

# 9. AWS DevOps Workflow

A typical AWS-based DevOps workflow can be:

```text
Developer
    |
    v
GitHub
    |
    v
GitHub Actions
    |
    v
Docker Build
    |
    v
Amazon ECR
    |
    v
ECS / EKS
    |
    v
Load Balancer
    |
    v
Application
    |
    v
CloudWatch
