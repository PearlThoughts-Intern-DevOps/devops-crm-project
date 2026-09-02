# Task 6: AWS & GCP Cloud Platforms

**Name:** Varad Ahir  
**Task:** 6 - AWS & GCP  
**Topic:** Cloud Platforms and DevOps Services

---

## 1. Introduction to Cloud Computing

Cloud computing means using computing resources such as servers, storage, databases, networking, and software over the internet instead of managing physical infrastructure directly.

Cloud platforms help organizations:
- Deploy applications quickly
- Scale resources when required
- Reduce infrastructure management
- Improve availability and reliability
- Automate deployments and operations
- Pay for resources based on usage

The two cloud platforms explored in this task are **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**.

---

# 2. Amazon Web Services (AWS)

AWS is Amazon's cloud computing platform. It provides services for compute, storage, databases, networking, security, monitoring, containers, serverless applications, and many other workloads.

AWS provides a large collection of cloud services that can be combined to build and operate applications.

## Important AWS Services

| Service | Purpose |
|---|---|
| EC2 | Provides virtual servers in the cloud |
| S3 | Object storage for files, backups, and application data |
| RDS | Managed relational databases |
| Lambda | Runs code without managing servers |
| VPC | Provides isolated cloud networking |
| IAM | Manages users, roles, permissions, and access |
| CloudWatch | Monitoring, metrics, logs, alarms, and dashboards |
| ECR | Stores and manages Docker/container images |
| ECS | Runs and manages containers |
| EKS | Managed Kubernetes service |
| Route 53 | DNS and domain management |

### EC2

Amazon EC2 provides resizable virtual servers in the cloud. It can be used to host websites, applications, APIs, development environments, and other workloads.

For DevOps, EC2 can be used to deploy Linux servers, Jenkins, Docker, application servers, and other infrastructure.

### S3

Amazon S3 is object storage. It can store files such as images, documents, backups, logs, and application assets.

### RDS

Amazon RDS is a managed relational database service. It supports database engines such as MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server.

### Lambda

AWS Lambda is a serverless compute service. It runs code without requiring the user to manage servers.

### VPC

Amazon VPC provides networking for AWS resources. It allows configuration of subnets, route tables, security groups, internet connectivity, and other networking components.

### IAM

AWS Identity and Access Management (IAM) controls who can access AWS resources and what actions they are allowed to perform.

### CloudWatch

Amazon CloudWatch provides monitoring and observability. It can collect metrics and logs and can create alarms and dashboards for AWS resources and applications.

---

# 3. Google Cloud Platform (GCP)

Google Cloud Platform (GCP), also called Google Cloud, is Google's cloud computing platform.

It provides services for compute, storage, databases, containers, Kubernetes, networking, security, monitoring, analytics, and application deployment.

Google Cloud organizes resources using concepts such as projects, regions, and zones.

## Important GCP Services

| Service | Purpose |
|---|---|
| Compute Engine | Provides virtual machines |
| Cloud Storage | Object storage |
| Cloud SQL | Managed relational databases |
| Cloud Run | Fully managed platform for running containers |
| VPC | Cloud networking |
| Cloud IAM | Access and permission management |
| Cloud Monitoring | Monitoring and observability |
| Artifact Registry | Stores software packages and container images |
| GKE | Managed Kubernetes service |
| Cloud DNS | DNS management |

### Compute Engine

Compute Engine provides virtual machines running on Google's infrastructure.

It can be used for application servers, development environments, backend systems, and other workloads requiring virtual machines.

### Cloud Storage

Cloud Storage provides scalable object storage. It can be used to store application files, backups, media, logs, and other objects.

### Cloud SQL

Cloud SQL is a fully managed relational database service supporting MySQL, PostgreSQL, and SQL Server.

### Cloud Run

Cloud Run is a fully managed platform for running containerized applications. It can automatically scale applications and can scale to zero when there are no requests.

This makes Cloud Run useful for APIs, web applications, microservices, and container-based workloads.

### VPC

Google Cloud VPC provides networking for cloud resources. It can be used to control communication between virtual machines, applications, and other cloud services.

### Cloud IAM

Cloud IAM manages access to Google Cloud resources by controlling permissions for users, groups, and service accounts.

### GKE

Google Kubernetes Engine (GKE) is Google's managed Kubernetes service. It can be used to deploy, manage, and scale containerized applications using Kubernetes.

---

# 4. AWS vs GCP

| Area | AWS | GCP |
|---|---|---|
| Virtual Machines | EC2 | Compute Engine |
| Object Storage | S3 | Cloud Storage |
| Relational Database | RDS | Cloud SQL |
| Containers | ECS / EKS | GKE / Cloud Run |
| Serverless Compute | Lambda | Cloud Run / Cloud Functions |
| Networking | VPC | VPC |
| Identity & Access | IAM | Cloud IAM |
| Monitoring | CloudWatch | Cloud Monitoring |
| Container Registry | ECR | Artifact Registry |
| DNS | Route 53 | Cloud DNS |

Both platforms provide similar fundamental cloud capabilities, but their services, interfaces, pricing models, integrations, and implementations are different.

---

# 5. AWS and GCP for DevOps

AWS and GCP can both be used throughout the DevOps lifecycle.

### Infrastructure

Virtual machines can be created using:
- AWS EC2
- Google Compute Engine

### Containers

Docker containers can be stored and deployed using:
- AWS ECR + ECS/EKS
- Google Artifact Registry + GKE/Cloud Run

### CI/CD

Cloud services can be integrated with CI/CD pipelines to:
1. Build application code
2. Run tests
3. Build Docker images
4. Store container images
5. Deploy applications
6. Monitor deployments

### Monitoring

AWS CloudWatch and Google Cloud Monitoring can be used to monitor infrastructure and applications.

### Security

AWS IAM and Google Cloud IAM provide identity and access management so that users and services receive only the permissions they require.

### Infrastructure as Code

Cloud infrastructure can also be managed using Infrastructure as Code tools such as Terraform and CloudFormation.

---

# 6. My Understanding

From exploring AWS and GCP, I understood that cloud platforms provide ready-to-use infrastructure and managed services instead of requiring organizations to maintain all physical infrastructure themselves.

I learned that:

- EC2 and Compute Engine provide virtual machines.
- S3 and Cloud Storage provide object storage.
- RDS and Cloud SQL provide managed relational databases.
- AWS Lambda provides serverless execution.
- Cloud Run provides a managed way to run containers.
- VPC is important for cloud networking.
- IAM is important for security and access control.
- CloudWatch and Cloud Monitoring help with monitoring and observability.
- EKS and GKE provide managed Kubernetes.
- Container registries such as ECR and Artifact Registry store container images.

I also understood that a DevOps engineer needs to understand compute, networking, storage, security, containers, monitoring, and automation rather than focusing on only one cloud service.

---

# 7. AWS and GCP in a DevOps Workflow

A typical cloud-based DevOps workflow can look like:

```text
Developer
   |
   v
Git Repository
   |
   v
CI/CD Pipeline
   |
   +----> Build
   |
   +----> Test
   |
   +----> Docker Image
   |
   v
Container Registry
   |
   v
Cloud Deployment
   |
   +----> AWS ECS/EKS/EC2
   |
   +----> GCP Cloud Run/GKE/Compute Engine
   |
   v
Monitoring & Logging

