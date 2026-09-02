# Task 6: AWS & GCP Cloud Platforms

## 1. Objective

The objective of this task was to explore AWS and GCP cloud platforms, understand their major services, and learn how these services can be used in a DevOps workflow.

The focus was mainly on compute, storage, networking, IAM, containers, databases, CI/CD, and monitoring.

---

# 2. AWS

## 2.1 Overview

Amazon Web Services (AWS) is a cloud platform that provides a large number of services for computing, storage, networking, databases, security, monitoring, application development, and other workloads.

For DevOps, AWS provides services that can be combined to build, deploy, operate, monitor, and scale applications.

---

## 2.2 Important AWS Services

### Amazon EC2

Amazon EC2 provides virtual machines in the AWS cloud.

It can be used when we need control over the operating system, installed software, networking, and server configuration.

Common DevOps use cases include:

- Hosting applications
- Running Docker containers
- Running Jenkins or other CI/CD tools
- Configuring custom server environments

---

### Amazon S3

Amazon S3 is an object storage service.

It can be used for:

- Application files
- Backups
- Logs
- Static website content
- Build artifacts

S3 provides highly durable storage and can be integrated with many other AWS services.

---

### Amazon VPC

Amazon VPC provides an isolated virtual network for AWS resources.

Important networking components include:

- Subnets
- Route tables
- Internet gateways
- NAT gateways
- Security groups
- Network ACLs

A VPC allows applications and infrastructure to be organized into controlled network environments.

---

### AWS IAM

AWS Identity and Access Management (IAM) controls access to AWS resources.

IAM can be used to manage:

- Users
- Groups
- Roles
- Policies
- Permissions

A key security principle is least privilege, where identities receive only the permissions they require.

---

### Amazon ECS

Amazon Elastic Container Service (ECS) is a managed container orchestration service.

It can be used to run Docker containers without manually managing the underlying container orchestration system.

A typical workflow is:

Docker Image → Amazon ECR → ECS → Running Container

ECS is useful when we want container orchestration while staying within AWS's native container ecosystem.

---

### Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is AWS's managed Kubernetes service.

It is useful when an organization wants to use Kubernetes for container orchestration while having AWS manage the Kubernetes control plane.

Typical workflow:

Docker Image → Amazon ECR → EKS → Kubernetes Pods

ECS and EKS are alternative approaches for container orchestration rather than services that must normally be used together.

---

### Amazon ECR

Amazon Elastic Container Registry (ECR) is a managed container image registry.

It can store Docker and other OCI-compatible container images.

A CI/CD pipeline can build an image and push it to ECR before deploying the image to ECS or EKS.

---

### Amazon RDS

Amazon Relational Database Service (RDS) is a managed relational database service.

It supports common relational database engines and handles many database administration tasks.

It can be used by applications running on EC2, ECS, EKS, and other AWS compute services.

---

### Amazon CloudWatch

Amazon CloudWatch provides monitoring and observability capabilities.

It can be used for:

- Metrics
- Logs
- Dashboards
- Alarms
- Application and infrastructure monitoring

For DevOps, CloudWatch can help identify application or infrastructure problems after deployment.

---
# 3. GCP
## 3.1 Overview

Google Cloud Platform (GCP) is Google's cloud platform and provides services for compute, storage, networking, databases, containers, security, monitoring, analytics, and application development.

GCP organizes resources using projects, with resources deployed across regions and zones.

## 2.2 Important GCP Services
### Compute Engine

Compute Engine provides virtual machines running on Google's infrastructure.

It is comparable to Amazon EC2.

Common use cases include:

- Hosting applications
- Running custom server environments
- Running Docker workloads
- Building infrastructure for development and testing

### Cloud Storage

Cloud Storage is GCP's object storage service.

It can be used for:

- Application files
- Backups
- Static assets
- Logs
- Build artifacts

It is comparable to Amazon S3.

### Google Cloud VPC

Google Cloud VPC provides networking for resources running in GCP.

It allows cloud resources to communicate using controlled network configurations.

Networking concepts include:

- VPC networks
- Subnets
- Routes
- Firewall rules

### Cloud IAM

Cloud IAM manages access to GCP resources.

It provides:

- Identities
- Roles
- Permissions
- Access control

IAM should follow the principle of least privilege so that users and services receive only the permissions required for their tasks.

### Google Kubernetes Engine (GKE)

GKE is Google's managed Kubernetes service.

It can be used to deploy and manage containerized applications using Kubernetes.

Typical workflow:

Docker Image → Artifact Registry → GKE → Kubernetes Pods

GKE is useful when Kubernetes-based orchestration is required.

### Cloud Run

Cloud Run is a fully managed platform for running containerized applications.

It allows developers to deploy containers without managing servers or a Kubernetes cluster directly.

A simplified workflow is:

Docker Image → Artifact Registry → Cloud Run → Application

Cloud Run is useful for applications where we want a simpler managed container deployment model.

### Cloud SQL

Cloud SQL is a managed relational database service.

It can be used by applications running on Compute Engine, GKE, Cloud Run, and other GCP services.

### Artifact Registry

Artifact Registry is used to store application and container artifacts.

For containerized applications, a Docker image can be built and pushed to Artifact Registry before being deployed to services such as GKE or Cloud Run.

### Cloud Build

Cloud Build is a service for building software and container images.

It can be integrated into CI/CD workflows to automate application builds.

### Cloud Deploy

Cloud Deploy is a managed delivery service that can be used to automate application deployment workflows.

It can be integrated with GKE and other supported deployment targets.

### Cloud Monitoring and Cloud Logging

Cloud Monitoring provides monitoring capabilities such as metrics, dashboards, and alerts.

Cloud Logging provides centralized logging for applications and infrastructure.

Together, they help with observing applications after deployment.

# 4. AWS vs GCP

| Requirement | AWS | GCP |
|---|---|---|
| Virtual Machines | EC2 | Compute Engine |
| Object Storage | S3 | Cloud Storage |
| Kubernetes | EKS | GKE |
| Managed Containers | ECS / Fargate | Cloud Run |
| Container Registry | ECR | Artifact Registry |
| Relational Database | RDS | Cloud SQL |
| IAM | AWS IAM | Cloud IAM |
| Networking | VPC | VPC |
| Monitoring | CloudWatch | Cloud Monitoring |
| Logging | CloudWatch Logs | Cloud Logging |
| CI/CD Build | CodeBuild | Cloud Build |
| Deployment | CodeDeploy / CodePipeline | Cloud Deploy |
| CLI | AWS CLI | gcloud CLI |

The services are not identical internally, but these provide useful functional comparisons when learning the two platforms.

---

# 7. Key Learnings

Through this task, I learned:

- The basic concepts of cloud computing.
- The difference between IaaS, PaaS, and managed cloud services.
- The role of regions, availability zones, and zones.
- How AWS provides compute, storage, networking, IAM, containers, databases, and monitoring services.
- How GCP provides equivalent capabilities through its own services.
- The purpose of container registries such as ECR and Artifact Registry.
- The difference between ECS and EKS in AWS.
- The role of GKE and Cloud Run in GCP.
- How IAM is used for cloud security and access control.
- How monitoring and logging support production operations.
- How cloud services can be combined with Docker and CI/CD to create a DevOps deployment workflow.

---

# 8. Conclusion

AWS and GCP provide a broad set of managed services that can support the complete application lifecycle.

The most important learning from this task is understanding the complete flow:

    Code
      ↓
    CI/CD
      ↓
    Docker Image
      ↓
    Container Registry
      ↓
    Compute / Container Platform
      ↓
    Networking
      ↓
    Database / Storage
      ↓
    Monitoring & Logging