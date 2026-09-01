# Task 6 – AWS & GCP

## 1. Introduction

Cloud computing is an important part of modern DevOps because it provides on-demand access to computing, storage, networking, databases, security, and monitoring services.

As part of Task 6, I explored two major cloud platforms:

* Amazon Web Services (AWS)
* Google Cloud Platform (GCP)

The objective was to understand the fundamentals of cloud computing, learn about commonly used AWS and GCP services, understand their DevOps use cases, and compare the platforms from a practical DevOps perspective.

---

## 2. Understanding Cloud Computing

Cloud computing is the delivery of computing resources and services over the internet. Instead of purchasing and maintaining all physical infrastructure, organizations can provision resources from cloud providers according to their requirements.

Common cloud resources include:

* Compute
* Storage
* Databases
* Networking
* Identity and access management
* Security
* Monitoring
* Containers
* Serverless services

### Traditional Infrastructure vs Cloud

With traditional infrastructure, an organization may need to purchase and maintain physical servers, storage, networking equipment, data-center facilities, power, cooling, and hardware.

With cloud computing, infrastructure can be provisioned on demand and scaled according to workload requirements.

A simplified model is:

```text
                    Cloud Platform
                         |
        +----------------+----------------+
        |                |                |
     Compute          Storage          Database
        |                |                |
       VMs             Objects        SQL / NoSQL
        |
    Application
```

### Benefits of Cloud Computing

The major benefits I identified are:

* On-demand infrastructure
* Scalability
* High availability
* Global infrastructure
* Usage-based pricing
* Managed services
* Automation
* Infrastructure as Code
* Faster application deployment

From a DevOps perspective, cloud platforms provide the infrastructure on which automated build, deployment, monitoring, and scaling processes can operate.

---

# 3. Amazon Web Services (AWS)

## 3.1 AWS Overview

Amazon Web Services (AWS) is Amazon's cloud computing platform. It provides services for computing, storage, databases, networking, identity, security, containers, serverless applications, monitoring, and many other workloads.

The main AWS services I explored are:

| Category   | Service    | Purpose                         |
| ---------- | ---------- | ------------------------------- |
| Compute    | EC2        | Virtual servers                 |
| Storage    | S3         | Object storage                  |
| Database   | RDS        | Managed relational databases    |
| Networking | VPC        | Virtual network                 |
| Identity   | IAM        | Identity and access management  |
| Serverless | Lambda     | Event-driven serverless compute |
| Containers | ECS        | Managed container orchestration |
| Kubernetes | EKS        | Managed Kubernetes              |
| Monitoring | CloudWatch | Metrics, logs, and monitoring   |

## 3.2 Amazon EC2

Amazon Elastic Compute Cloud (EC2) provides virtual servers in AWS.

An EC2 instance can host web applications, APIs, backend services, and containerized workloads.

A simplified DevOps deployment flow is:

```text
Developer
    |
    v
Git Repository
    |
    v
CI/CD Pipeline
    |
    v
Build / Test
    |
    v
Application or Container
    |
    v
AWS EC2
    |
    v
Running Application
```

### DevOps relevance

EC2 is useful when engineers need control over the operating system, installed software, runtime environment, networking, and application configuration.

---

## 3.3 Amazon S3

Amazon Simple Storage Service (S3) is an object storage service.

Objects are stored inside buckets.

Common use cases include:

* Backups
* Application assets
* Documents
* Logs
* Data files
* Build artifacts

```text
S3
 |
 +-- Bucket
      |
      +-- application.zip
      +-- backup.tar.gz
      +-- image.png
      +-- logs/
```

### DevOps relevance

S3 is useful when applications need scalable object storage rather than a traditional filesystem or relational database.

---

## 3.4 Amazon RDS

Amazon Relational Database Service (RDS) is a managed relational database service.

It supports database engines including PostgreSQL, MySQL, MariaDB, Oracle, and SQL Server.

Instead of manually maintaining database infrastructure, RDS provides managed capabilities for operating relational databases.

### DevOps relevance

Managed database services can reduce infrastructure-management overhead while providing capabilities such as backups, maintenance, monitoring, and high-availability options.

---

## 3.5 Amazon VPC

Amazon Virtual Private Cloud (VPC) provides a logically isolated networking environment in AWS.

Important components include:

* Subnets
* Route tables
* Internet gateways
* Security groups
* Network connectivity

A simplified application architecture could be:

```text
                    Internet
                       |
                       v
                 Load Balancer
                       |
                 Application
                       |
                Private Network
                       |
                    Database
```

### DevOps relevance

Cloud networking is important for controlling how application components communicate and for reducing unnecessary exposure to the public internet.

For example, a database can be placed in a private network while only the required application entry points are publicly accessible.

---

## 3.6 AWS IAM

AWS Identity and Access Management (IAM) controls access to AWS resources.

IAM helps answer:

> Who can access a resource, and what are they allowed to do?

A simplified model is:

```text
Identity
   |
   v
Authentication
   |
   v
Authorization
   |
   v
AWS Resource
```

### Least Privilege

A key security principle is least privilege.

Instead of giving every identity administrator access:

```text
Developer    -> Required permissions
CI/CD        -> Deployment permissions
Application  -> Runtime permissions
```

Each identity should receive only the permissions required for its responsibilities.

---

## 3.7 AWS Lambda

AWS Lambda is a serverless compute service that runs code without requiring users to manage the underlying servers directly.

A simplified event-driven flow is:

```text
Event
  |
  v
Lambda Function
  |
  v
Code Execution
  |
  v
Result
```

Lambda can be useful for event-driven processing, automation, APIs, background processing, and scheduled workloads.

---

## 3.8 AWS ECS and EKS

### Amazon ECS

Amazon Elastic Container Service (ECS) is a managed container orchestration service used to run and manage containers on AWS.

### Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is AWS's managed Kubernetes service.

The relationship can be viewed as:

```text
Docker
   |
   v
Container
   |
   +------> ECS
   |
   +------> Kubernetes
                |
                v
               EKS
```

### DevOps relevance

These services allow containerized applications to be operated using managed cloud infrastructure.

This connects directly with Docker and Kubernetes concepts used in modern DevOps workflows.

---

## 3.9 Amazon CloudWatch

Amazon CloudWatch provides monitoring and observability capabilities for AWS resources and applications.

It can be used for:

* Metrics
* Logs
* Monitoring
* Alerts
* Operational visibility

```text
Application
     |
     v
AWS Resource
     |
     v
CloudWatch
   /     
Metrics   Logs
```

Monitoring is important because deployment is not the end of the DevOps lifecycle. Applications must also be observed after deployment.

---

# 4. Google Cloud Platform (GCP)

## 4.1 GCP Overview

Google Cloud Platform (GCP), commonly referred to as Google Cloud, is Google's cloud computing platform.

It provides services for computing, storage, databases, networking, identity, security, containers, Kubernetes, serverless applications, analytics, and monitoring.

The main GCP services I explored are:

| Category   | Service          | Purpose                        |
| ---------- | ---------------- | ------------------------------ |
| Compute    | Compute Engine   | Virtual machines               |
| Storage    | Cloud Storage    | Object storage                 |
| Database   | Cloud SQL        | Managed relational databases   |
| Networking | VPC              | Virtual networking             |
| Identity   | Cloud IAM        | Identity and access management |
| Containers | Cloud Run        | Managed container platform     |
| Kubernetes | GKE              | Managed Kubernetes             |
| Monitoring | Cloud Monitoring | Monitoring and observability   |
| Analytics  | BigQuery         | Data analytics and warehousing |

## 4.2 Google Compute Engine

Compute Engine provides configurable virtual machines running on Google's infrastructure.

It is conceptually similar to AWS EC2:

```text
AWS                         GCP

EC2        <----------->    Compute Engine
```

Compute Engine can host web applications, APIs, backend services, and other workloads.

---

## 4.3 Google Cloud Storage

Cloud Storage is Google's object storage service.

Objects are stored inside buckets.

```text
Cloud Storage
     |
     +-- Bucket
          |
          +-- image.png
          +-- backup.zip
          +-- application.tar.gz
```

It is conceptually similar to Amazon S3:

```text
AWS                         GCP

S3         <----------->    Cloud Storage
```

Cloud Storage can be used for backups, application assets, data files, and other object-storage requirements.

---

## 4.4 Cloud SQL

Cloud SQL is Google's managed relational database service.

It supports database engines including MySQL, PostgreSQL, and SQL Server.

It is conceptually similar to AWS RDS:

```text
AWS                         GCP

RDS        <----------->    Cloud SQL
```

Managed database services reduce the operational effort involved in maintaining database infrastructure.

---

## 4.5 Google Cloud VPC

Google Cloud VPC provides networking capabilities for cloud resources.

A simplified architecture is:

```text
                    Internet
                       |
                       v
                 Load Balancer
                       |
                       v
                 Application
                       |
                       v
                    Database
```

VPC networking allows organizations to control connectivity between cloud resources.

Networking configuration is an important part of cloud security and application architecture.

---

## 4.6 Google Cloud IAM

Cloud IAM controls access to Google Cloud resources using identities and roles.

A simplified model is:

```text
User / Workload
      |
      v
     IAM
      |
      v
     Role
      |
      v
Cloud Resource
```

Google Cloud also provides service accounts for applications and workloads.

Service accounts allow workloads to authenticate to cloud services without using personal user credentials.

---

## 4.7 Cloud Run

Cloud Run is a fully managed platform for running containerized applications.

A simplified workflow is:

```text
Dockerfile
    |
    v
Docker Image
    |
    v
Cloud Run
    |
    v
Running Application
```

Cloud Run is useful when developers want to deploy containers without managing the underlying server infrastructure or a Kubernetes cluster directly.

It is important to note that Cloud Run and AWS Lambda are not exact equivalents. Cloud Run focuses on running containerized applications, while Lambda primarily runs functions in response to events.

---

## 4.8 Google Kubernetes Engine (GKE)

Google Kubernetes Engine (GKE) is Google's managed Kubernetes service.

The relationship can be understood as:

```text
Docker
   |
   v
Container
   |
   v
Kubernetes
   |
   v
GKE
```

GKE can be used to deploy and manage containerized applications using Kubernetes.

---

## 4.9 Cloud Monitoring

Google Cloud provides monitoring and observability capabilities through Cloud Monitoring.

It can be used to observe:

* Application performance
* Infrastructure metrics
* Service health
* Alerts
* Operational information

Conceptually:

```text
AWS                         GCP

CloudWatch  <----------->   Cloud Monitoring
```

---

# 5. Important Cloud Concepts

## 5.1 Regions and Zones

Cloud providers distribute infrastructure across geographical locations.

A region represents a geographical area containing cloud infrastructure. Within regions, cloud providers use isolated locations to support availability and fault tolerance.

The terminology differs between providers, but the general concept is:

```text
Cloud Provider
     |
     +-- Region
           |
           +-- Zone / Isolated Location
           +-- Zone / Isolated Location
           +-- Zone / Isolated Location
```

Using multiple infrastructure locations can improve application availability and fault tolerance.

---

## 5.2 Scalability

Cloud environments make it easier to scale resources according to workload requirements.

### Vertical Scaling

Increasing the capacity of a single machine:

```text
2 CPU / 4 GB RAM
        |
        v
8 CPU / 16 GB RAM
```

### Horizontal Scaling

Adding additional application instances:

```text
             Load Balancer
             /     |     
            v      v      v
          App 1  App 2  App 3
```

Horizontal scaling can improve availability and allow applications to handle increased traffic.

---

## 5.3 Shared Responsibility Model

Cloud security is shared between the cloud provider and the customer.

The provider is responsible for security of the underlying cloud infrastructure, while customers remain responsible for areas such as:

* Application security
* Data protection
* Identity and permissions
* Configuration
* Operating systems where applicable
* Secrets and credentials

The exact responsibilities depend on the service being used.

A managed service can reduce some operational responsibilities, but it does not remove the customer's responsibility for secure configuration and data.

---

## 5.4 Infrastructure as Code

Infrastructure as Code (IaC) means defining infrastructure using code or configuration files rather than manually creating every resource.

A typical workflow is:

```text
Infrastructure Definition
          |
          v
     Version Control
          |
          v
       Review
          |
          v
        CI/CD
          |
          v
      Cloud Resources
```

Common IaC technologies include:

* Terraform
* AWS CloudFormation
* Google Cloud infrastructure tooling

### Benefits of IaC

* Reproducibility
* Version control
* Automation
* Consistency
* Easier review
* Easier recovery

---

## 5.5 CI/CD and Cloud

Cloud platforms integrate naturally with CI/CD pipelines.

A simplified DevOps workflow is:

```text
Developer
    |
    v
Git Repository
    |
    v
CI Pipeline
    |
    +--> Tests
    |
    +--> Security Checks
    |
    +--> Build
    |
    v
Container Image / Artifact
    |
    v
Cloud Deployment
    |
    v
Application
    |
    v
Monitoring
```

This demonstrates how source control, automation, containerization, cloud infrastructure, and monitoring work together as part of a DevOps lifecycle.

---

# 6. AWS vs GCP Comparison

| Area                 | AWS                              | GCP              |
| -------------------- | -------------------------------- | ---------------- |
| Virtual Machines     | EC2                              | Compute Engine   |
| Object Storage       | S3                               | Cloud Storage    |
| Relational Database  | RDS                              | Cloud SQL        |
| Virtual Network      | VPC                              | VPC              |
| Identity & Access    | IAM                              | Cloud IAM        |
| Serverless Functions | Lambda                           | Cloud Functions  |
| Managed Containers   | ECS / other services             | Cloud Run        |
| Kubernetes           | EKS                              | GKE              |
| Monitoring           | CloudWatch                       | Cloud Monitoring |
| CLI                  | AWS CLI                          | gcloud CLI       |
| Data Analytics       | Amazon Redshift / other services | BigQuery         |

These are conceptual mappings rather than exact one-to-one equivalents. Each platform has different architectures, features, pricing models, and service integrations.

---

# 7. AWS and GCP from a DevOps Perspective

From a DevOps perspective, both AWS and GCP provide infrastructure and managed services required to build, deploy, operate, and monitor applications.

A typical cloud-based DevOps lifecycle is:

```text
Plan
  |
  v
Code
  |
  v
Build
  |
  v
Test
  |
  v
Security
  |
  v
Containerize
  |
  v
Deploy to Cloud
  |
  v
Monitor
  |
  v
Improve
```

For a containerized application, a typical workflow could be:

1. Store the application code in Git.
2. Run automated tests through CI.
3. Build a Docker image.
4. Store the image in a container registry.
5. Deploy the workload to a cloud compute or container platform.
6. Monitor the application after deployment.

This connects cloud infrastructure with the DevOps practices of automation, version control, testing, deployment, and observability.

---

# 8. Key Learnings

Through this task, I learned that AWS and GCP provide similar fundamental cloud capabilities, although their service names, implementations, and available features differ.

The main concepts I understood are:

* Cloud computing provides on-demand infrastructure and managed services.
* EC2 and Compute Engine provide virtual machines.
* S3 and Cloud Storage provide object storage.
* RDS and Cloud SQL provide managed relational databases.
* VPC provides cloud networking capabilities.
* IAM is critical for identity and access control.
* ECS/EKS and GKE support containerized workloads.
* Lambda and Cloud Run provide different serverless or managed execution models.
* CloudWatch and Cloud Monitoring provide observability.
* Infrastructure as Code enables repeatable and automated infrastructure management.
* CI/CD can be integrated with cloud infrastructure for automated application delivery.
* Security and access control should follow least-privilege principles.
* High availability and scalability can be designed using multiple instances and infrastructure locations.

Most importantly, I understood that cloud computing and DevOps complement each other. Cloud platforms provide infrastructure and managed services, while DevOps practices provide automation, testing, deployment, monitoring, and continuous improvement around those resources.

---

# 9. Conclusion

AWS and GCP are comprehensive cloud platforms capable of supporting modern application and DevOps workloads.

Although their service names and implementation details differ, many fundamental concepts are similar:

```text
Compute
Storage
Networking
Database
Identity
Security
Containers
Automation
Monitoring
```

This exploration helped me understand how cloud services fit together to form application architectures and how DevOps engineers use cloud platforms to automate and operate application infrastructure.

It also helped connect my previous learning around Linux, Docker, CI/CD, and DevOps with cloud infrastructure and deployment.

---

# 10. References

* [AWS Documentation](https://docs.aws.amazon.com/)
* [AWS Overview](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html)
* [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-iam-features.html)
* [Google Cloud Documentation](https://cloud.google.com/docs)
* [Google Cloud Products](https://cloud.google.com/products)
* [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
* [Google Cloud IAM Documentation](https://cloud.google.com/iam/docs)
* [Google Cloud Storage Documentation](https://cloud.google.com/storage/docs)
* [Google Cloud SQL Documentation](https://cloud.google.com/sql/docs)
