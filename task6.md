# Task 6 — Exploring AWS & GCP

**Branch:** `sakhisurakhya/task-6`

## What I Did

For this task, I explored both AWS and GCP consoles and learned about their core cloud services.

I focused on:

* Compute
* Containers
* Storage
* Databases
* Networking
* Security
* CI/CD
* Monitoring

---

# 1. Basic Idea of Cloud Computing

Cloud computing means using computing resources through the internet instead of purchasing and maintaining physical servers ourselves.

Cloud providers offer services such as:

* Virtual machines
* Containers
* Storage
* Databases
* Networking
* Security
* Monitoring
* Application deployment

Some major cloud providers are:

* AWS — Amazon Web Services
* GCP — Google Cloud Platform
* Microsoft Azure

### Traditional Approach

```text
Physical Server
      ↓
Operating System
      ↓
Application
      ↓
Users
```

### Cloud Approach

```text
Cloud Provider
      ↓
Virtual / Managed Resources
      ↓
Application
      ↓
Users
```

The main advantage is that we don't need to purchase and maintain physical infrastructure ourselves. We can provision the required resources from a cloud provider.

---

# 2. AWS — Amazon Web Services

AWS stands for **Amazon Web Services**.

It is Amazon's cloud computing platform and provides services for:

* Computing
* Containers
* Storage
* Databases
* Networking
* Security
* Monitoring
* CI/CD
* Analytics
* Machine learning

AWS provides different ways to run applications, including virtual machines, containers, and serverless services.

## Important AWS Services I Explored

### EC2 — Compute

* EC2 provides virtual machines in the AWS cloud.
* We can select the required CPU, memory, operating system, and other configurations.
* Applications can then be deployed and run on these virtual machines.
* It is similar to having our own server, but the infrastructure is provided by AWS.

### Lambda — Serverless Compute

* Lambda allows code to run without managing a server ourselves.
* The code is executed when an event or request triggers it.
* AWS manages the underlying infrastructure.
* It is useful for event-driven applications and smaller functions.

### ECS — Containers

* ECS stands for Elastic Container Service.
* It is used to run and manage Docker containers on AWS.
* A Docker image can be deployed as a container through ECS.
* This is relevant to our Docker work because our application was containerized in Task 5.

### EKS — Kubernetes

* EKS stands for Elastic Kubernetes Service.
* It is AWS's managed Kubernetes service.
* It is useful when an application requires Kubernetes for container orchestration.

### S3 — Storage

* S3 stands for Simple Storage Service.
* It is object storage.
* It can be used to store:

  * Files
  * Images
  * Backups
  * Logs
  * Application objects

### EBS — Block Storage

* EBS stands for Elastic Block Store.
* It provides persistent storage for EC2 instances.
* It works like a persistent disk attached to a virtual machine.

### RDS — Database

* RDS stands for Relational Database Service.
* It provides managed relational databases.
* It supports databases such as:

  * PostgreSQL
  * MySQL
  * MariaDB
  * Oracle
  * SQL Server
* AWS manages many database administration tasks for us.

### VPC — Networking

* VPC stands for Virtual Private Cloud.
* It provides an isolated networking environment in AWS.
* It allows us to control how cloud resources communicate with each other.
* It can be used to control networking and security boundaries.

### IAM — Security

* IAM stands for Identity and Access Management.
* It controls who can access AWS resources.
* It manages:

  * Users
  * Roles
  * Policies
  * Permissions
* One important concept I learned is **least privilege**, which means giving only the permissions that are actually required.

### CodeBuild and CodePipeline — CI/CD

* CodeBuild can be used to build and test applications.
* CodePipeline can be used to automate application delivery.
* These services can be used to create CI/CD pipelines.

### CloudWatch — Monitoring

* CloudWatch is used for monitoring AWS resources and applications.
* It provides:

  * Metrics
  * Logs
  * Dashboards
  * Alarms
* It helps identify application or infrastructure problems.

## What I Learned About AWS

* AWS has a very large number of services.
* There can be multiple ways to solve the same problem.
* For example, containers can be run using ECS, EKS, Fargate, or even Docker on EC2.
* This makes AWS powerful but also gives it a learning curve.
* IAM is an important part of AWS because permissions control access to resources.
* Choosing the right AWS service depends on the application requirements, cost, scalability, and operational needs.

---

# 3. GCP — Google Cloud Platform

GCP stands for **Google Cloud Platform**.

It is Google's cloud computing platform and provides services for:

* Computing
* Containers
* Storage
* Databases
* Networking
* Security
* Monitoring
* CI/CD
* Data analytics
* Machine learning

GCP provides different ways to deploy applications, including virtual machines, containers, Kubernetes, and serverless services.

## Important GCP Services I Explored

### Compute Engine — Compute

* Compute Engine provides virtual machines in Google Cloud.
* It is similar to AWS EC2.
* We can select the required machine configuration and operating system.
* Applications can be deployed and run on these virtual machines.

### Cloud Run — Serverless Containers

* Cloud Run is a service for running containerized applications.
* We can deploy a Docker image to Cloud Run.
* Google manages the underlying infrastructure.
* It can automatically scale based on incoming requests.
* It can scale down to zero when there are no requests.
* This makes it an interesting option for applications with intermittent usage.

### GKE — Kubernetes

* GKE stands for Google Kubernetes Engine.
* It is Google's managed Kubernetes service.
* It is used for running and managing Kubernetes workloads.

### Cloud Storage — Storage

* Cloud Storage provides object storage.
* It can be used to store:

  * Files
  * Images
  * Backups
  * Logs
  * Other objects

### Cloud SQL — Database

* Cloud SQL is a managed relational database service.
* It supports databases such as:

  * PostgreSQL
  * MySQL
  * SQL Server
* It is similar to AWS RDS.

### VPC — Networking

* GCP VPC provides networking for cloud resources.
* It allows resources to communicate with each other.
* It can be used to design and control the network environment.

### Cloud IAM — Security

* Cloud IAM manages identities and permissions.
* It controls which users and services can access cloud resources.
* It provides roles and permissions to control access.

### Cloud Build — CI/CD

* Cloud Build is a service for building and deploying applications.
* It can automate build and deployment processes.
* It can be used as part of a CI/CD workflow.

### Cloud Monitoring — Monitoring

* Cloud Monitoring is used to monitor applications and cloud infrastructure.
* It provides:

  * Metrics
  * Dashboards
  * Alerts
  * Monitoring information

## What I Learned About GCP

* GCP provides services similar to AWS for many common cloud requirements.
* Cloud Run stood out to me because it provides a simple way to run containerized applications.
* GCP also has strong capabilities around:

  * Data analytics
  * Machine learning
  * Kubernetes
  * Container-based workloads
* The best service depends on the application requirements and workload.

---

# 4. AWS vs GCP

AWS and GCP provide many similar cloud capabilities, but the service names and approaches can be different.

### Compute

* AWS → EC2
* GCP → Compute Engine

Both provide virtual machines for running applications.

### Object Storage

* AWS → S3
* GCP → Cloud Storage

Both can be used for storing files, images, backups, and other objects.

### Managed Database

* AWS → RDS
* GCP → Cloud SQL

Both provide managed relational databases such as PostgreSQL and MySQL.

### Containers

* AWS → ECS / EKS
* GCP → GKE

Both provide services for running containerized workloads.

### Serverless Containers

* AWS → Fargate with ECS/EKS
* GCP → Cloud Run

Both can be used to run containers without managing traditional servers directly.

### Serverless Functions

* AWS → Lambda
* GCP → Cloud Functions

Both allow code to run without directly managing the underlying server infrastructure.

### Identity and Access

* AWS → IAM
* GCP → Cloud IAM

Both provide identity and permission management.

### CI/CD

* AWS → CodeBuild / CodePipeline
* GCP → Cloud Build

Both provide services that can be used to automate application build and deployment processes.

### Monitoring

* AWS → CloudWatch
* GCP → Cloud Monitoring

Both provide monitoring, metrics, logs, dashboards, and alerts.

## Overall Comparison

* AWS has a very broad service catalog and a mature ecosystem.
* GCP provides strong services for data analytics, AI/ML, Kubernetes, and containers.
* AWS provides many different options for solving infrastructure problems.
* GCP felt relatively straightforward for some container-based use cases.
* The choice between AWS and GCP depends on:

  * Application requirements
  * Cost
  * Scalability
  * Existing infrastructure
  * Team knowledge
  * Required services

---

# 5. Why Cloud Could Be Useful for Our Project

Our application currently runs locally.

If we wanted to make the application available to users over the internet, we would need infrastructure to host:

* Application containers
* Database
* Storage
* Networking
* Security
* Monitoring

Cloud platforms can provide these resources without requiring us to purchase and maintain physical servers.

## Possible AWS Architecture

```text
AWS
 │
 ├── ECS / Fargate
 │       ↓
 │   Application Containers
 │
 ├── RDS
 │       ↓
 │   PostgreSQL Database
 │
 ├── S3
 │       ↓
 │   File/Object Storage
 │
 ├── VPC
 │       ↓
 │   Networking
 │
 └── IAM
         ↓
     Access Control
```

## Possible GCP Architecture

```text
GCP
 │
 ├── Cloud Run
 │       ↓
 │   Application Containers
 │
 ├── Cloud SQL
 │       ↓
 │   PostgreSQL Database
 │
 ├── Cloud Storage
 │       ↓
 │   File/Object Storage
 │
 ├── VPC
 │       ↓
 │   Networking
 │
 └── Cloud IAM
         ↓
     Access Control
```

These are possible architectures for deploying an application to the cloud. The purpose of this task was to understand AWS and GCP services rather than actually deploy the project.

---

# 6. What I Learned

The biggest thing I learned from this task is that cloud platforms provide much more than just virtual servers.

They provide managed services for:

* Computing
* Containers
* Storage
* Databases
* Networking
* Security
* Monitoring
* CI/CD
* Analytics
* Machine learning

I also learned that managed services can reduce the amount of infrastructure that developers and DevOps teams need to maintain themselves.

For example:

* Instead of managing PostgreSQL manually → AWS RDS or GCP Cloud SQL can be used.
* Instead of managing servers for containers → AWS ECS/Fargate or GCP Cloud Run can be used.
* Instead of managing physical storage → AWS S3 or GCP Cloud Storage can be used.
* Instead of manually managing access → AWS IAM or GCP Cloud IAM can be used.
* Instead of manually monitoring infrastructure → CloudWatch or Cloud Monitoring can be used.

---

# 7. Conclusion

Exploring AWS and GCP helped me understand how cloud platforms are used in modern application development and DevOps.

I learned about:

* Compute
* Containers
* Storage
* Databases
* Networking
* IAM
* CI/CD
* Monitoring

AWS and GCP provide similar fundamental cloud capabilities, but they have different services, approaches, and ecosystems.

The main takeaway from this task is that cloud platforms provide the infrastructure and managed services required to deploy, operate, secure, monitor, and scale applications without maintaining physical servers ourselves.
