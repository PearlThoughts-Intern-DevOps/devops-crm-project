# Task 6: AWS & GCP – Cloud Platforms & Services

**Name:** Nagendra Madasu
**Task:** Task 6 – AWS & GCP
**Repository:** `devops-crm-project`

---

## 1. Introduction

Cloud computing provides on-demand access to computing resources such as servers, storage, databases, networking, security, and monitoring over the internet.

Two of the most popular cloud platforms are:

* **Amazon Web Services (AWS)**
* **Google Cloud Platform (GCP)**

Both platforms provide similar categories of cloud services, but they differ in their architecture, service names, tools, and strengths.

---

# 2. Amazon Web Services (AWS)

## What is AWS?

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon. It offers a large collection of services for computing, storage, databases, networking, security, monitoring, DevOps, and application development.

AWS follows a pay-as-you-go model, where users generally pay based on the resources they consume.

### Major AWS Service Categories

| Category               | AWS Service    | Purpose                           |
| ---------------------- | -------------- | --------------------------------- |
| Compute                | EC2            | Virtual servers                   |
| Storage                | S3             | Object storage                    |
| Database               | RDS            | Managed relational databases      |
| Networking             | VPC            | Private cloud networking          |
| Serverless             | Lambda         | Run code without managing servers |
| Containers             | ECS / EKS      | Container orchestration           |
| Monitoring             | CloudWatch     | Monitoring and logs               |
| Security               | IAM            | Identity and access management    |
| DNS                    | Route 53       | DNS and domain management         |
| Load Balancing         | ELB            | Distribute traffic                |
| CI/CD                  | CodePipeline   | Continuous delivery               |
| Infrastructure as Code | CloudFormation | Infrastructure automation         |

---

## 3. Important AWS Services

### 3.1 Amazon EC2

**EC2 (Elastic Compute Cloud)** provides virtual servers in the cloud.

An EC2 instance can be used to:

* Host websites
* Run applications
* Deploy APIs
* Run Docker containers
* Configure CI/CD tools
* Host development environments

**Example:**

A company can launch an EC2 instance running Linux and deploy a web application on it.

---

### 3.2 Amazon S3

**S3 (Simple Storage Service)** is an object storage service.

It can store:

* Images
* Videos
* Documents
* Backups
* Application files
* Logs

S3 organizes data using **buckets** and objects.

**Example:**

A website can store uploaded profile pictures in an S3 bucket.

---

### 3.3 Amazon RDS

**RDS (Relational Database Service)** is a managed database service.

It supports databases such as:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

AWS manages many administrative tasks such as backups, patching, and infrastructure provisioning.

---

### 3.4 Amazon VPC

**VPC (Virtual Private Cloud)** allows users to create an isolated network environment in AWS.

Important VPC components include:

* Subnets
* Route tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Network ACLs

**Example architecture:**

Internet → Load Balancer → Application Server → Database

---

### 3.5 AWS IAM

**IAM (Identity and Access Management)** controls who can access AWS resources and what actions they can perform.

Important IAM concepts:

* Users
* Groups
* Roles
* Policies

Following the **principle of least privilege** is important when configuring IAM.

---

### 3.6 AWS Lambda

Lambda is a **serverless compute service**.

Instead of managing servers, developers upload code and AWS runs it when triggered.

Common triggers include:

* API requests
* S3 events
* Scheduled events
* Queue messages

---

### 3.7 Amazon CloudWatch

CloudWatch is used for:

* Metrics
* Logs
* Monitoring
* Alerts
* Application performance

For example, CloudWatch can monitor EC2 CPU utilization and trigger an alarm when CPU usage becomes high.

---

# 4. Google Cloud Platform (GCP)

## What is GCP?

Google Cloud Platform (GCP) is Google's cloud computing platform. It provides services for computing, storage, databases, networking, containers, Kubernetes, analytics, AI/ML, monitoring, and application development.

GCP organizes resources using concepts such as:

**Organization → Folders → Projects → Resources**

---

## 5. Major GCP Service Categories

| Category               | GCP Service                    | Purpose                         |
| ---------------------- | ------------------------------ | ------------------------------- |
| Compute                | Compute Engine                 | Virtual machines                |
| Storage                | Cloud Storage                  | Object storage                  |
| Database               | Cloud SQL                      | Managed relational database     |
| Networking             | VPC                            | Cloud networking                |
| Serverless             | Cloud Functions                | Serverless functions            |
| Containers             | GKE                            | Kubernetes                      |
| Monitoring             | Cloud Monitoring               | Monitoring                      |
| Logging                | Cloud Logging                  | Centralized logging             |
| IAM                    | Cloud IAM                      | Access control                  |
| Load Balancing         | Cloud Load Balancing           | Traffic distribution            |
| CI/CD                  | Cloud Build                    | Build and deployment automation |
| Infrastructure as Code | Deployment Manager / Terraform | Infrastructure automation       |
| Data Analytics         | BigQuery                       | Data warehouse and analytics    |

---

# 6. Important GCP Services

### 6.1 Compute Engine

Compute Engine provides virtual machines running on Google's infrastructure.

It can be used to:

* Host applications
* Run web servers
* Deploy APIs
* Run Docker containers
* Create development environments

**AWS Equivalent:** EC2

---

### 6.2 Cloud Storage

Cloud Storage is GCP's object storage service.

It can store:

* Images
* Videos
* Backups
* Documents
* Logs
* Application data

**AWS Equivalent:** S3

---

### 6.3 Cloud SQL

Cloud SQL is a managed relational database service.

It supports databases such as:

* MySQL
* PostgreSQL
* SQL Server

Google manages infrastructure and several database administration tasks.

**AWS Equivalent:** RDS

---

### 6.4 Google Kubernetes Engine (GKE)

GKE is Google's managed Kubernetes service.

It can be used to deploy and manage containerized applications.

GKE is particularly important for DevOps and container orchestration because it integrates Kubernetes with Google's cloud infrastructure.

**AWS Equivalent:** EKS

---

### 6.5 Cloud IAM

Cloud IAM controls access to GCP resources.

It determines:

* Who can access resources
* Which resources they can access
* What actions they can perform

**AWS Equivalent:** IAM

---

### 6.6 Cloud Monitoring

Cloud Monitoring helps monitor applications and infrastructure.

It provides:

* Metrics
* Dashboards
* Alerts
* Resource monitoring

**AWS Equivalent:** CloudWatch

---

### 6.7 BigQuery

BigQuery is Google's fully managed, serverless data warehouse.

It is designed for analyzing large amounts of data using SQL.

**Example:**

A company can use BigQuery to analyze millions of customer transactions and generate business reports.

---

# 7. AWS vs GCP

| Feature              | AWS                    | GCP                  |
| -------------------- | ---------------------- | -------------------- |
| Cloud Provider       | Amazon                 | Google               |
| Virtual Machines     | EC2                    | Compute Engine       |
| Object Storage       | S3                     | Cloud Storage        |
| Managed SQL Database | RDS                    | Cloud SQL            |
| Kubernetes           | EKS                    | GKE                  |
| Serverless           | Lambda                 | Cloud Functions      |
| Networking           | VPC                    | VPC                  |
| Identity             | IAM                    | Cloud IAM            |
| Monitoring           | CloudWatch             | Cloud Monitoring     |
| Logging              | CloudWatch Logs        | Cloud Logging        |
| Data Warehouse       | Redshift               | BigQuery             |
| Container Registry   | ECR                    | Artifact Registry    |
| Load Balancing       | Elastic Load Balancing | Cloud Load Balancing |

---

# 8. AWS and GCP for DevOps

Both AWS and GCP provide services that are useful for implementing DevOps practices.

A typical DevOps workflow can look like:

**Developer → GitHub → CI/CD Pipeline → Build → Test → Container → Cloud → Monitoring**

### Example AWS DevOps Workflow

GitHub
↓
Jenkins / GitHub Actions
↓
Build & Test
↓
Docker
↓
Amazon ECR
↓
Amazon ECS / EKS / EC2
↓
CloudWatch

### Example GCP DevOps Workflow

GitHub
↓
Cloud Build / GitHub Actions
↓
Build & Test
↓
Docker
↓
Artifact Registry
↓
GKE / Compute Engine
↓
Cloud Monitoring & Logging

---

# 9. Security

Security is an important part of cloud infrastructure.

Some important practices include:

* Use IAM instead of sharing credentials.
* Follow the principle of least privilege.
* Avoid storing passwords or API keys directly in source code.
* Use security groups and firewall rules.
* Enable logging and monitoring.
* Encrypt sensitive data.
* Regularly review permissions.
* Use secrets-management services for sensitive credentials.

---

# 10. High-Level Architecture

A basic cloud application can be designed as:

```text
                    Internet
                       |
                Load Balancer
                       |
              Application Servers
                       |
                Managed Database
                       |
                Object Storage
                       |
                Monitoring & Logs
```

This architecture can be implemented using equivalent AWS or GCP services.

### AWS Example

```text
Users
  |
  v
Elastic Load Balancer
  |
  v
EC2 / ECS / EKS
  |
  +------> RDS
  |
  +------> S3
  |
  +------> CloudWatch
```

### GCP Example

```text
Users
  |
  v
Cloud Load Balancing
  |
  v
Compute Engine / GKE
  |
  +------> Cloud SQL
  |
  +------> Cloud Storage
  |
  +------> Cloud Monitoring
```

---

# 11. What I Learned

Through this task, I learned the basic concepts and services provided by AWS and GCP.

The major concepts I understood are:

1. Cloud platforms provide infrastructure and services on demand.
2. AWS and GCP provide similar services with different names and implementations.
3. EC2 and Compute Engine provide virtual machines.
4. S3 and Cloud Storage provide object storage.
5. RDS and Cloud SQL provide managed relational databases.
6. EKS and GKE provide managed Kubernetes environments.
7. IAM is important for controlling access to cloud resources.
8. Monitoring and logging are essential for maintaining applications.
9. Cloud services can be integrated into DevOps and CI/CD pipelines.
10. Cloud security and least-privilege access are important when managing infrastructure.

---

# 12. Conclusion

AWS and GCP are powerful cloud platforms that provide services for application development, deployment, networking, storage, databases, security, monitoring, containers, and DevOps.

AWS provides a very broad range of cloud services, while GCP has strong capabilities in areas such as Kubernetes, data analytics, and cloud-native technologies.

Learning both platforms helps a DevOps engineer understand different cloud architectures and choose appropriate services based on project requirements.

---

## 13. Key Takeaway

**AWS and GCP provide the infrastructure and managed services needed to build, deploy, scale, secure, and monitor modern applications in the cloud.**

Understanding the equivalent services between both platforms is especially useful for a DevOps/Cloud Engineer.

