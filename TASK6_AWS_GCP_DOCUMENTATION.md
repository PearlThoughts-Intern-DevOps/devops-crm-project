TASK6_AWS_GCP_DOCUMENTATION.md
# Task 6 — Exploring AWS & GCP

---

# 1. Introduction

For this task, I explored both **AWS and GCP** and learned about their basic cloud services.

I focused on:

* Compute
* Storage
* Database
* Networking
* Security
* Containers
* Serverless
* CI/CD
* Monitoring

AWS and GCP are cloud platforms. They provide resources and services that we can use to build, deploy, and manage applications.

---

# 2. What is Cloud Computing?

Cloud computing means using servers, storage, databases, and other resources through the internet.

Instead of buying physical servers, we can use resources from cloud providers.

For example:

```text
User
  ↓
Internet
  ↓
Cloud Provider
  ↓
Application
  ↓
Database
```

Some popular cloud providers are:

* AWS
* GCP
* Microsoft Azure

### Benefits of Cloud Computing

* No need to buy physical servers.
* Easy to increase or decrease resources.
* Pay for the resources we use.
* Applications can be deployed faster.
* Easy to create backup and storage.
* Better availability and scalability.

---

# 3. AWS — Amazon Web Services

AWS stands for **Amazon Web Services**.

AWS is a cloud platform provided by Amazon. It provides many services for running applications and managing infrastructure.

Important AWS services include:

* EC2
* S3
* VPC
* IAM
* RDS
* Lambda
* ECS
* EKS
* CloudWatch
* Route 53
* Elastic Load Balancing
* Auto Scaling
* CodeBuild
* CodePipeline

---

## 4. AWS EC2 — Compute

**EC2** stands for **Elastic Compute Cloud**.

EC2 provides virtual servers in AWS.

We can use EC2 to:

* Run applications
* Host websites
* Run backend servers
* Install Docker
* Run other software

Example:

```text
AWS
 ↓
EC2
 ↓
Operating System
 ↓
Application
```

EC2 is similar to having our own server, but the server is provided by AWS.

---

# 5. AWS S3 — Storage

**S3** stands for **Simple Storage Service**.

S3 is used to store files and objects.

We can store:

* Images
* Videos
* Documents
* Backups
* Logs
* Application files

Example:

```text
Application
     ↓
    S3
     ↓
Files / Images / Backups
```

S3 is mainly used when we need scalable object storage.

---

# 6. AWS VPC — Networking

**VPC** stands for **Virtual Private Cloud**.

VPC is used to create a private network in AWS.

Inside a VPC, we can have:

* Subnets
* Route tables
* Internet Gateway
* NAT Gateway
* Security Groups

Example:

```text
AWS VPC
   |
   ├── Public Subnet
   |
   └── Private Subnet
```

VPC helps us control how our AWS resources communicate with each other and with the internet.

---

# 7. AWS IAM — Security

**IAM** stands for **Identity and Access Management**.

IAM controls who can access AWS resources.

IAM includes:

* Users
* Groups
* Roles
* Policies
* Permissions

For example, we can give a user permission to access S3 but not EC2.

An important security concept is **least privilege**.

Least privilege means giving only the permissions that are actually needed.

---

# 8. AWS RDS — Database

**RDS** stands for **Relational Database Service**.

RDS provides managed databases.

It supports databases such as:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

AWS manages many database tasks for us, such as backups and maintenance.

RDS is useful because we don't need to manually manage the database server.

---

# 9. AWS Lambda — Serverless

AWS Lambda is a **serverless computing service**.

We can run code without managing a server ourselves.

For example:

```text
User Request
     ↓
AWS Lambda
     ↓
Code Runs
     ↓
Response
```

Lambda is useful for:

* APIs
* Automation
* Event-based applications
* Small functions

---

# 10. AWS ECS — Containers

**ECS** stands for **Elastic Container Service**.

ECS is used to run Docker containers on AWS.

For example:

```text
Docker Image
     ↓
AWS ECS
     ↓
Container
     ↓
Application
```

ECS is useful when we want to run containerized applications.

---

# 11. AWS EKS — Kubernetes

**EKS** stands for **Elastic Kubernetes Service**.

EKS is AWS's managed Kubernetes service.

Kubernetes helps us:

* Run containers
* Manage containers
* Scale applications
* Deploy applications
* Manage application workloads

EKS is useful for applications that need Kubernetes.

---

# 12. AWS CloudWatch — Monitoring

CloudWatch is used to monitor AWS resources and applications.

It provides:

* Metrics
* Logs
* Dashboards
* Alarms

For example, we can monitor:

* CPU usage
* Memory-related application metrics
* Server activity
* Application logs

Monitoring helps us find problems in applications and infrastructure.

---

# 13. AWS Route 53 — DNS

Route 53 is an AWS DNS service.

DNS converts a domain name into an IP address.

For example:

```text
www.example.com
       ↓
    Route 53
       ↓
   IP Address
```

Route 53 can be used to connect domain names with applications.

---

# 14. AWS Load Balancer

AWS Elastic Load Balancing distributes incoming traffic across multiple servers or application targets.

Example:

```text
             User
               ↓
        Load Balancer
          ↓       ↓
        EC2      EC2
          ↓       ↓
       Application
```

This helps applications handle more traffic and improves availability.

---

# 15. AWS Auto Scaling

Auto Scaling can automatically increase or decrease resources based on application demand.

For example:

```text
Low Traffic
   ↓
2 Servers

High Traffic
   ↓
5 Servers
```

This helps applications handle changing traffic.

---

# 16. AWS CI/CD Services

AWS provides services that can be used for CI/CD.

### CodeBuild

CodeBuild can build and test application code.

### CodePipeline

CodePipeline can automate different stages of a software delivery process.

Example:

```text
GitHub
   ↓
Build
   ↓
Test
   ↓
Deploy
```

---

# 17. GCP — Google Cloud Platform

GCP stands for **Google Cloud Platform**.

It is Google's cloud platform.

GCP provides services for:

* Compute
* Storage
* Databases
* Networking
* Security
* Containers
* Serverless
* CI/CD
* Monitoring
* Data analytics

Important GCP services include:

* Compute Engine
* Cloud Storage
* VPC
* Cloud IAM
* Cloud SQL
* GKE
* Cloud Run
* Cloud Functions
* Cloud Monitoring
* Cloud Build

---

# 18. GCP Compute Engine — Compute

Compute Engine provides virtual machines in Google Cloud.

It is similar to AWS EC2.

We can use it to:

* Run applications
* Host websites
* Run backend services
* Install required software

Example:

```text
GCP
 ↓
Compute Engine
 ↓
Virtual Machine
 ↓
Application
```

---

# 19. GCP Cloud Storage — Storage

Cloud Storage is used to store files and objects.

We can store:

* Images
* Videos
* Documents
* Backups
* Logs
* Application files

It is similar to AWS S3.

```text
Application
     ↓
Cloud Storage
     ↓
Files / Backups
```

---

# 20. GCP VPC — Networking

GCP VPC provides networking for cloud resources.

It allows different cloud resources to communicate with each other.

Example:

```text
GCP VPC
   |
   ├── Application
   |
   └── Database
```

VPC helps us design and control the network.

---

# 21. GCP Cloud IAM — Security

Cloud IAM is used to manage access to Google Cloud resources.

It controls:

* Users
* Roles
* Permissions
* Service accounts

For example, we can give a user permission to access Cloud Storage without giving access to other resources.

---

# 22. GCP Cloud SQL — Database

Cloud SQL is a managed relational database service.

It supports:

* MySQL
* PostgreSQL
* SQL Server

Cloud SQL is similar to AWS RDS.

Google manages many database administration tasks for us.

---

# 23. GCP GKE — Kubernetes

**GKE** stands for **Google Kubernetes Engine**.

GKE is Google's managed Kubernetes service.

It is used to:

* Run containers
* Deploy applications
* Manage Kubernetes workloads
* Scale applications

It is similar to AWS EKS.

---

# 24. GCP Cloud Run — Serverless Containers

Cloud Run is used to run containerized applications.

We can deploy a Docker container to Cloud Run.

Example:

```text
Docker Image
     ↓
Cloud Run
     ↓
Application
```

Cloud Run manages the infrastructure for us.

It is useful when we want to run containers without managing servers directly.

---

# 25. GCP Cloud Functions — Serverless

Cloud Functions allows us to run code without managing servers.

It can run code when an event happens.

For example:

```text
Event
  ↓
Cloud Function
  ↓
Code Runs
```

It is similar to AWS Lambda.

---

# 26. GCP Cloud Monitoring

Cloud Monitoring is used to monitor applications and cloud resources.

It provides:

* Metrics
* Dashboards
* Alerts
* Monitoring information

It helps us understand application and infrastructure performance.

It is similar to AWS CloudWatch.

---

# 27. GCP Cloud Build — CI/CD

Cloud Build is used to build and test applications.

It can also be used as part of a CI/CD pipeline.

Example:

```text
Code
 ↓
Cloud Build
 ↓
Build
 ↓
Test
 ↓
Deploy
```

---

# 28. AWS vs GCP

| Purpose               | AWS                      | GCP              |
| --------------------- | ------------------------ | ---------------- |
| Virtual Machine       | EC2                      | Compute Engine   |
| Storage               | S3                       | Cloud Storage    |
| Database              | RDS                      | Cloud SQL        |
| Networking            | VPC                      | VPC              |
| Security              | IAM                      | Cloud IAM        |
| Kubernetes            | EKS                      | GKE              |
| Serverless            | Lambda                   | Cloud Functions  |
| Serverless Containers | ECS/Fargate              | Cloud Run        |
| Monitoring            | CloudWatch               | Cloud Monitoring |
| CI/CD                 | CodeBuild / CodePipeline | Cloud Build      |
| DNS                   | Route 53                 | Cloud DNS        |

---

# 29. Difference Between AWS and GCP

AWS and GCP provide many similar cloud services.

### AWS

AWS has a very large number of services and is widely used by many companies.

It provides many options for:

* Compute
* Storage
* Networking
* Containers
* Databases
* Security
* DevOps

### GCP

GCP also provides many cloud services.

It is well known for:

* Kubernetes
* Containers
* Data analytics
* Machine learning
* Cloud-native applications

The best cloud platform depends on the project requirements, cost, services needed, and team knowledge.

---

# 30. AWS and GCP for DevOps

Cloud platforms are very useful for DevOps.

A DevOps engineer can use cloud services to:

* Deploy applications
* Run Docker containers
* Manage Kubernetes
* Create CI/CD pipelines
* Store files
* Manage databases
* Configure networks
* Monitor applications
* Manage security
* Automate infrastructure

For example:

```text
Developer
    ↓
GitHub
    ↓
CI/CD Pipeline
    ↓
Docker Build
    ↓
Cloud
    ↓
Application
```

---

# 31. Possible AWS Architecture

A simple application can be deployed like this:

```text
             User
               ↓
          Route 53
               ↓
       Load Balancer
               ↓
          ECS / EC2
               ↓
             RDS

               +
               
              S3
               ↓
        Files / Backups

              +

             VPC
               ↓
          Networking

              +

             IAM
               ↓
         Access Control

              +

         CloudWatch
               ↓
          Monitoring
```

---

# 32. Possible GCP Architecture

A simple application can be deployed like this:

```text
             User
               ↓
          Cloud DNS
               ↓
        Cloud Run / GKE
               ↓
           Cloud SQL

               +

        Cloud Storage
               ↓
        Files / Backups

               +

             VPC
               ↓
          Networking

              +

          Cloud IAM
               ↓
         Access Control

              +

      Cloud Monitoring
               ↓
          Monitoring
```

These are example architectures. The actual architecture depends on the application requirements.

---

# 33. Security in Cloud

Security is very important in both AWS and GCP.

Some basic security practices are:

* Use IAM to control access.
* Give only required permissions.
* Use strong passwords.
* Enable MFA.
* Do not share access keys.
* Do not put passwords or secrets in GitHub.
* Keep databases private when possible.
* Use firewall and security rules.
* Monitor logs and activities.
* Keep software updated.

---

# 34. What I Learned

From this task, I learned the basic concepts of AWS and GCP.

I learned that both cloud platforms provide services for:

* Compute
* Storage
* Database
* Networking
* Security
* Containers
* Serverless
* CI/CD
* Monitoring

I also learned that many AWS and GCP services have similar purposes.

For example:

```text
AWS EC2       → GCP Compute Engine
AWS S3        → GCP Cloud Storage
AWS RDS       → GCP Cloud SQL
AWS IAM       → GCP Cloud IAM
AWS EKS       → GCP GKE
AWS Lambda    → GCP Cloud Functions
AWS CloudWatch → GCP Cloud Monitoring
```

I also understood that cloud services can reduce the need to manage physical servers.

---

# 35. Conclusion

AWS and GCP are important cloud platforms used in modern IT and DevOps.

AWS provides services such as EC2, S3, VPC, IAM, RDS, Lambda, ECS, EKS, and CloudWatch.

GCP provides services such as Compute Engine, Cloud Storage, VPC, Cloud IAM, Cloud SQL, GKE, Cloud Run, and Cloud Monitoring.

By exploring both platforms, I understood the basic cloud services and how they can be used for application deployment, networking, security, containers, CI/CD, and monitoring.

This task helped me improve my understanding of cloud computing and how AWS and GCP can be used in DevOps.
