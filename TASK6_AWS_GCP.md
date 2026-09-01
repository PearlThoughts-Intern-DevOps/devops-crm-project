# Task 6: AWS & GCP – Cloud Platforms and Services

## 1. Introduction

Cloud computing is the delivery of computing resources such as servers, storage, databases, networking, and monitoring over the internet. Instead of maintaining physical infrastructure, organizations can use cloud providers to provision resources on demand.

Two of the major cloud platforms are **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**.

Both platforms provide a wide range of services that help organizations build, deploy, scale, monitor, and secure applications.

---

## 2. Amazon Web Services (AWS)

### What is AWS?

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon. It provides infrastructure and managed services that can be used to build and operate applications without maintaining physical servers.

AWS follows a pay-as-you-go model for many of its services, allowing organizations to provision resources according to their requirements.

### Important AWS Services

#### 2.1 Amazon EC2

**EC2 (Elastic Compute Cloud)** provides virtual servers in the cloud.

It can be used to:

* Host web applications
* Run backend services
* Deploy APIs
* Run Docker containers
* Configure servers according to application requirements

For example, a DevOps team can deploy an application on an EC2 instance and manage its environment remotely.

---

#### 2.2 Amazon S3

**S3 (Simple Storage Service)** is an object storage service.

It can be used to store:

* Images
* Videos
* Documents
* Application backups
* Logs
* Static website files

S3 stores data inside containers called **buckets**.

One important characteristic of S3 is that storage is separated from compute, which makes it useful for applications that need scalable object storage.

---

#### 2.3 Amazon RDS

**RDS (Relational Database Service)** is a managed database service.

It supports relational database engines such as:

* PostgreSQL
* MySQL
* MariaDB
* Oracle
* SQL Server

RDS handles many administrative tasks such as backups, patching, and database infrastructure management.

This allows developers and DevOps teams to focus more on the application rather than manually managing database servers.

---

#### 2.4 Amazon VPC

**VPC (Virtual Private Cloud)** allows users to create an isolated virtual network in AWS.

Important networking components include:

* Subnets
* Route tables
* Internet gateways
* Security groups
* Network access control lists

VPC is important for controlling how cloud resources communicate with each other and with the internet.

---

#### 2.5 AWS IAM

**IAM (Identity and Access Management)** is used to control access to AWS resources.

IAM can manage:

* Users
* Groups
* Roles
* Policies
* Permissions

A key security principle is **least privilege**, where a user or application receives only the permissions required to perform its job.

---

#### 2.6 Amazon CloudWatch

**CloudWatch** is AWS's monitoring and observability service.

It can be used to monitor:

* Metrics
* Logs
* Application performance
* Resource utilization
* Alarms

For example, CloudWatch can help a DevOps engineer monitor CPU utilization of an EC2 instance and create an alarm when usage becomes too high.

---

## 3. Google Cloud Platform (GCP)

### What is GCP?

Google Cloud Platform (GCP) is Google's cloud computing platform. It provides infrastructure, storage, databases, networking, security, analytics, AI/ML, and monitoring services.

GCP allows organizations to deploy applications and infrastructure using Google's global cloud infrastructure.

### Important GCP Services

#### 3.1 Compute Engine

**Compute Engine** provides virtual machines running on Google Cloud.

It can be used to:

* Host applications
* Run backend services
* Deploy APIs
* Run development environments
* Host Docker-based workloads

It is conceptually similar to AWS EC2.

---

#### 3.2 Cloud Storage

**Cloud Storage** is GCP's object storage service.

It can be used to store:

* Files
* Images
* Videos
* Backups
* Application data
* Static content

Data is organized using storage buckets.

Cloud Storage is comparable to Amazon S3.

---

#### 3.3 Cloud SQL

**Cloud SQL** is a managed relational database service provided by Google Cloud.

It supports database systems such as:

* MySQL
* PostgreSQL
* SQL Server

Cloud SQL handles many infrastructure and database administration tasks, reducing the amount of manual server management required.

---

#### 3.4 Google Cloud VPC

**VPC (Virtual Private Cloud)** provides networking functionality for Google Cloud resources.

It allows organizations to control:

* IP addresses
* Subnets
* Routes
* Firewall rules
* Network connectivity

VPC helps create secure and controlled communication between cloud resources.

---

#### 3.5 Google Cloud IAM

**Cloud IAM (Identity and Access Management)** controls who can access Google Cloud resources and what actions they are allowed to perform.

Permissions can be assigned using roles.

The basic security concept is similar to AWS IAM: users and workloads should receive only the permissions they need.

---

#### 3.6 Cloud Monitoring

**Cloud Monitoring** provides monitoring and observability capabilities for Google Cloud resources and applications.

It can be used to monitor:

* Performance
* Metrics
* Resource utilization
* Application health
* Alerts

It is comparable to AWS CloudWatch.

---

## 4. AWS and GCP Service Comparison

| Category            | AWS        | GCP                         |
| ------------------- | ---------- | --------------------------- |
| Virtual Machines    | EC2        | Compute Engine              |
| Object Storage      | S3         | Cloud Storage               |
| Relational Database | RDS        | Cloud SQL                   |
| Networking          | VPC        | VPC                         |
| Identity & Access   | IAM        | Cloud IAM                   |
| Monitoring          | CloudWatch | Cloud Monitoring            |
| Containers          | ECS / EKS  | GKE                         |
| Serverless          | Lambda     | Cloud Run / Cloud Functions |

Although the names and implementations are different, both platforms provide similar fundamental cloud capabilities.

---

## 5. AWS vs GCP

### AWS

AWS has a very large service ecosystem and provides services for almost every area of cloud computing.

Some important strengths include:

* Large number of available services
* Mature cloud ecosystem
* Extensive infrastructure
* Strong enterprise adoption
* Wide range of DevOps and infrastructure services

### GCP

GCP is Google's cloud platform and has strong capabilities in areas such as:

* Data analytics
* Artificial intelligence and machine learning
* Kubernetes and containers
* Global networking
* Cloud-native application development

### Key Difference

AWS generally has a broader and more mature service ecosystem, while GCP has strong integration with Google's technologies, data services, AI/ML capabilities, and Kubernetes ecosystem.

The appropriate platform depends on the organization's technical requirements, existing infrastructure, pricing considerations, and preferred technologies.

---

## 6. Cloud Computing Concepts Learned

### 6.1 Compute

Compute services provide processing power for applications.

Examples:

* AWS EC2
* GCP Compute Engine

Instead of purchasing physical servers, organizations can provision virtual machines when required.

### 6.2 Storage

Cloud storage allows applications to store files and objects without maintaining physical storage infrastructure.

Examples:

* AWS S3
* GCP Cloud Storage

### 6.3 Managed Databases

Managed database services reduce the operational effort required to maintain databases.

Examples:

* AWS RDS
* GCP Cloud SQL

### 6.4 Networking

Cloud networking provides connectivity and isolation between resources.

VPCs allow organizations to design private networks and control traffic between resources.

### 6.5 Identity and Access Management

IAM is important for cloud security.

Instead of giving every user complete access, permissions should be assigned according to their responsibilities.

### 6.6 Monitoring

Monitoring services provide visibility into application and infrastructure health.

They help DevOps teams identify:

* Performance problems
* Resource utilization
* Errors
* Availability issues
* Operational problems

---

## 7. Role of Cloud in DevOps

Cloud platforms are closely connected with DevOps because they provide infrastructure that can be provisioned and managed programmatically.

A typical DevOps workflow can look like:

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
Build & Test
    |
    v
Cloud Infrastructure
    |
    +------> Compute
    |
    +------> Database
    |
    +------> Storage
    |
    v
Monitoring & Logging
```

Cloud platforms make it easier to automate deployment, scale applications, monitor infrastructure, and manage environments.

For the DevOps CRM project, cloud infrastructure could be used to host the application, database, supporting services, and monitoring systems.

---

## 8. Key Learnings

Through this task, I learned that cloud platforms provide much more than virtual machines.

The main concepts I understood are:

1. Cloud providers offer compute, storage, databases, networking, security, and monitoring services.
2. AWS and GCP provide similar fundamental capabilities but use different service names and implementations.
3. EC2 and Compute Engine provide cloud-based virtual machines.
4. S3 and Cloud Storage provide scalable object storage.
5. RDS and Cloud SQL provide managed relational databases.
6. VPC is important for designing and securing cloud networks.
7. IAM is essential for controlling access to cloud resources.
8. Monitoring services help DevOps teams observe infrastructure and applications.
9. Cloud platforms support automation and scalable infrastructure.
10. Cloud computing is an important part of modern DevOps practices.

---

## 9. Conclusion

AWS and GCP are powerful cloud platforms that provide the infrastructure and managed services required to build and operate modern applications.

The major areas I explored were compute, storage, databases, networking, IAM, and monitoring.

I also understood how these services can fit into a DevOps workflow and how cloud platforms help organizations reduce infrastructure management effort while improving scalability, automation, and operational visibility.

This task provided me with a foundational understanding of AWS and GCP and their role in modern cloud and DevOps environments.
