# Task 6: AWS & GCP Cloud Platforms

---

## 1. Introduction

Cloud computing has become an important part of modern software development and DevOps. Cloud platforms provide computing resources such as virtual machines, storage, networking, databases, security, monitoring and other services over the internet.

For this task, I explored two major cloud platforms:

* Amazon Web Services (AWS)
* Google Cloud Platform (GCP)

I studied their major services, their purpose, and how these services can be used in DevOps environments. I also compared similar services provided by AWS and GCP.

---

# 2. What is Cloud Computing?

Cloud computing is the delivery of computing resources over the internet.

Instead of purchasing and maintaining physical servers, organizations can use cloud providers to access resources when required.

Common cloud resources include:

* Virtual machines
* Storage
* Databases
* Networking
* Security
* Load balancing
* Monitoring
* Containers
* Kubernetes
* Serverless computing

### Benefits of Cloud Computing

1. **Scalability** – Resources can be increased or decreased according to requirements.
2. **Flexibility** – Resources can be created and configured quickly.
3. **Cost Efficiency** – Organizations can pay for the resources they use.
4. **High Availability** – Cloud providers offer infrastructure across multiple regions and availability zones.
5. **Security** – Cloud platforms provide identity, access control and security services.
6. **Global Infrastructure** – Applications can be deployed closer to users around the world.
7. **Automation** – Cloud resources can be managed using APIs, CLI tools and Infrastructure as Code.

---

# 3. Amazon Web Services (AWS)

## 3.1 What is AWS?

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon.

AWS provides a large collection of cloud services for computing, storage, databases, networking, security, monitoring, containers and DevOps.

AWS allows organizations to build, deploy and manage applications without maintaining their own physical data centers.

---

# 4. Important AWS Services

## 4.1 Amazon EC2

**EC2 (Elastic Compute Cloud)** provides virtual servers in the AWS cloud.

### Purpose

EC2 is used to run applications, websites, APIs and other workloads.

### DevOps Use

A DevOps engineer can create EC2 instances, install required software, configure servers and deploy applications.

### Example

An organization can launch an EC2 instance, install Nginx and use it to host a web application.

---

## 4.2 Amazon S3

**S3 (Simple Storage Service)** is an object storage service.

### Purpose

It is used to store files and objects such as:

* Images
* Videos
* Documents
* Backups
* Application files
* Logs

### DevOps Use

S3 can be used for backups, storing build artifacts and static website files.

---

## 4.3 Amazon VPC

**VPC (Virtual Private Cloud)** provides a logically isolated network in AWS.

### Important VPC Components

* VPC
* Subnets
* Route Tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Network ACLs

### DevOps Use

VPC is used to create secure networking infrastructure for applications and servers.

---

## 4.4 IAM

**IAM (Identity and Access Management)** is used to control access to AWS resources.

IAM includes:

* Users
* Groups
* Roles
* Policies

### DevOps Use

IAM allows administrators and applications to access only the resources they need.

This supports the **Principle of Least Privilege**.

---

## 4.5 Elastic Load Balancer

Elastic Load Balancing distributes incoming traffic across multiple servers or targets.

### Purpose

It improves:

* Availability
* Scalability
* Reliability

### Example

If an application is running on two EC2 instances, a load balancer can distribute requests between both instances.

---

## 4.6 Auto Scaling

AWS Auto Scaling automatically adjusts the number of resources according to demand.

### Example

If application traffic increases, additional EC2 instances can be launched automatically.

When traffic decreases, unnecessary instances can be removed.

This helps maintain performance while controlling costs.

---

## 4.7 AWS Lambda

AWS Lambda is a serverless compute service.

It allows developers to run code without managing servers.

### Example

A Lambda function can automatically execute when a file is uploaded to an S3 bucket.

---

## 4.8 Amazon RDS

**RDS (Relational Database Service)** is a managed relational database service.

It supports database engines such as:

* MySQL 
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

### Benefit

AWS manages many database administration tasks such as backups, patching and maintenance.

---

## 4.9 Amazon CloudWatch

CloudWatch is an AWS monitoring and observability service.

It can be used for:

* Metrics
* Logs
* Alarms
* Dashboards
* Monitoring AWS resources

### DevOps Use

CloudWatch can help DevOps engineers monitor EC2 instances, applications and infrastructure.

---

# 5. Google Cloud Platform (GCP)

## 5.1 What is GCP?

Google Cloud Platform (GCP), also known as Google Cloud, is Google's cloud computing platform.

GCP provides services for:

* Compute
* Storage
* Networking
* Databases
* Containers
* Kubernetes
* Security
* Monitoring
* DevOps
* Serverless applications

GCP allows organizations to build, deploy and manage applications using Google's global cloud infrastructure.

---

# 6. Important GCP Services

## 6.1 Compute Engine

**Compute Engine** is GCP's virtual machine service.

It allows users to create and manage virtual machines running on Google's infrastructure.

### Purpose

Compute Engine can be used to run:

* Web servers
* Applications
* APIs
* Development environments
* Backend services

### DevOps Use

DevOps engineers can create VMs, configure operating systems, install applications and deploy workloads.

### AWS Equivalent

**Compute Engine → Amazon EC2**

---

## 6.2 Cloud Storage

**Cloud Storage** is GCP's object storage service.

It is used to store objects such as:

* Images
* Videos
* Documents
* Backups
* Application files
* Logs

### DevOps Use

Cloud Storage can be used for backups, static files and storing application artifacts.

### AWS Equivalent

**Cloud Storage → Amazon S3**

---

## 6.3 Google Cloud VPC

**VPC (Virtual Private Cloud)** provides networking capabilities for GCP resources.

It allows organizations to create and manage networks for their applications.

Important concepts include:

* VPC networks
* Subnets
* Routes
* Firewall rules
* VPN
* Network connectivity

### DevOps Use

VPC is used to create secure and controlled networking environments.

### AWS Equivalent

**GCP VPC → AWS VPC**

---

## 6.4 Cloud IAM

**Cloud IAM (Identity and Access Management)** controls who can access GCP resources and what actions they can perform.

IAM can be used to manage:

* Users
* Groups
* Service accounts
* Roles
* Permissions

### DevOps Use

IAM helps implement secure access and the principle of least privilege.

### AWS Equivalent

**Cloud IAM → AWS IAM**

---

## 6.5 Google Kubernetes Engine (GKE)

**GKE (Google Kubernetes Engine)** is Google's managed Kubernetes service.

Kubernetes is used to deploy, manage and scale containerized applications.

### DevOps Use

GKE can be used for:

* Container orchestration
* Application deployment
* Scaling
* Service management
* Rolling updates

### AWS Equivalent

**GKE → Amazon EKS**

---

## 6.6 Cloud Run

**Cloud Run** is a fully managed platform for running containerized applications.

It allows developers to deploy containers without managing the underlying servers.

### DevOps Use

Cloud Run is useful for deploying:

* APIs
* Web applications
* Microservices
* Containerized applications

### Example

A Dockerized application can be deployed to Cloud Run and made available through a URL.

---

## 6.7 Cloud Functions

**Cloud Functions** is a serverless compute service that allows code to run in response to events.

### Example

A function can be triggered when:

* A file is uploaded
* An HTTP request is received
* A cloud event occurs

### AWS Equivalent

**Cloud Functions → AWS Lambda**

---

## 6.8 Cloud SQL

**Cloud SQL** is a managed relational database service.

It supports popular database engines such as:

* MySQL
* PostgreSQL
* SQL Server

### Benefits

Cloud SQL provides managed database capabilities such as backups, maintenance and high availability options.

### AWS Equivalent

**Cloud SQL → Amazon RDS**

---

## 6.9 Cloud Load Balancing

Cloud Load Balancing distributes incoming traffic across application resources.

### Purpose

It helps improve:

* Availability
* Scalability
* Performance
* Reliability

### DevOps Use

Load balancing can distribute user requests across multiple application instances or services.

### AWS Equivalent

**Cloud Load Balancing → Elastic Load Balancing**

---

## 6.10 Cloud Monitoring

Cloud Monitoring helps monitor applications and infrastructure running on Google Cloud.

It provides information such as:

* Metrics
* Dashboards
* Alerts
* Resource health

### DevOps Use

DevOps engineers can use Cloud Monitoring to identify performance problems and monitor infrastructure.

### AWS Equivalent

**Cloud Monitoring → Amazon CloudWatch**

---

## 6.11 Cloud Logging

Cloud Logging is used to collect, store, search and analyze logs.

Logs can help engineers troubleshoot application and infrastructure problems.

### DevOps Use

For example, if an application returns errors, logs can help identify what went wrong.

### AWS Equivalent

**Cloud Logging → CloudWatch Logs**

---

## 6.12 Cloud Build

**Cloud Build** is a service used to build and automate software delivery workflows.

It can be used to:

* Build applications
* Run tests
* Create container images
* Automate build processes

### DevOps Use

Cloud Build can be integrated into CI/CD workflows.

### AWS Equivalent

**Cloud Build → AWS CodeBuild**

---

## 6.13 Artifact Registry

**Artifact Registry** is used to store and manage software artifacts.

It can store:

* Docker/OCI container images
* Packages
* Build artifacts

### DevOps Use

A CI/CD pipeline can build a Docker image and push it to Artifact Registry before deploying it.

### AWS Equivalent

**Artifact Registry → Amazon ECR**

---

# 7. AWS vs GCP

AWS and GCP are both major cloud platforms.

They provide similar categories of services, but their service names, interfaces and implementations can be different.

| Category            | AWS                    | GCP                  |
| ------------------- | ---------------------- | -------------------- |
| Virtual Machines    | EC2                    | Compute Engine       |
| Object Storage      | S3                     | Cloud Storage        |
| Networking          | VPC                    | VPC                  |
| Kubernetes          | EKS                    | GKE                  |
| Serverless          | Lambda                 | Cloud Functions      |
| Container Platform  | ECS/EKS                | GKE/Cloud Run        |
| Relational Database | RDS                    | Cloud SQL            |
| Identity & Access   | IAM                    | Cloud IAM            |
| Load Balancing      | Elastic Load Balancing | Cloud Load Balancing |
| Monitoring          | CloudWatch             | Cloud Monitoring     |
| Logging             | CloudWatch Logs        | Cloud Logging        |
| Build/CI            | CodeBuild              | Cloud Build          |
| Container Registry  | ECR                    | Artifact Registry    |

---

# 8. AWS and GCP Service Mapping

The following mapping helped me understand that many cloud services solve similar problems.

### Compute

AWS EC2 is similar to GCP Compute Engine.

Both provide virtual machines that can be used to run applications.

### Storage

AWS S3 is similar to GCP Cloud Storage.

Both are object storage services.

### Kubernetes

AWS EKS is similar to GCP GKE.

Both provide managed Kubernetes services.

### Serverless

AWS Lambda is similar to GCP Cloud Functions.

Both allow code to run without managing traditional servers.

### Database

AWS RDS is similar to GCP Cloud SQL.

Both provide managed relational database services.

### Monitoring

AWS CloudWatch is similar to GCP Cloud Monitoring.

Both provide monitoring and observability capabilities.

### Logging

AWS CloudWatch Logs is similar to GCP Cloud Logging.

Both are used to collect and analyze logs.

---

# 9. DevOps Use Cases of AWS and GCP

Cloud platforms are very important for DevOps because they provide infrastructure and services that can be integrated with CI/CD pipelines.

A typical DevOps workflow can look like:

```text
Developer
    |
    v
GitHub
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
Cloud Infrastructure
    |
    v
Application
    |
    v
Monitoring & Logging
```

## AWS Example

A DevOps workflow can use:

```text
GitHub
   |
   v
CI/CD
   |
   v
Docker
   |
   v
Amazon ECR
   |
   v
EC2 / ECS / EKS
   |
   v
Elastic Load Balancer
   |
   v
CloudWatch
```

## GCP Example

A DevOps workflow can use:

```text
GitHub
   |
   v
Cloud Build
   |
   v
Docker
   |
   v
Artifact Registry
   |
   v
GKE / Cloud Run
   |
   v
Cloud Load Balancing
   |
   v
Cloud Monitoring + Cloud Logging
```

---

# 10. Importance of IAM in DevOps

Security is an important part of cloud and DevOps.

Both AWS and GCP provide Identity and Access Management systems.

The main principle I learned is:

**Principle of Least Privilege**

This means a user, service or application should receive only the permissions required to perform its task.

For example, if an application only needs to read files from object storage, it should not receive full administrative permissions.

This reduces the risk of accidental or unauthorized changes.

---

# 11. Monitoring and Logging

Monitoring and logging are important for maintaining applications.

### Monitoring

Monitoring helps answer questions such as:

* Is the server running?
* Is CPU usage high?
* Is memory usage increasing?
* Is the application responding?
* Are there performance problems?

### Logging

Logs provide detailed information about application and system activity.

They can help identify:

* Errors
* Failed requests
* Application problems
* Security issues
* Configuration problems

AWS provides services such as CloudWatch, while GCP provides Cloud Monitoring and Cloud Logging.

---

# 12. Benefits of Using Cloud Platforms for DevOps

Cloud platforms provide several benefits for DevOps teams.

### 1. Automation

Infrastructure and application deployment can be automated.

### 2. Scalability

Resources can be scaled based on application requirements.

### 3. High Availability

Applications can be deployed across multiple locations and resources.

### 4. Infrastructure as Code

Tools such as Terraform can be used to define and manage cloud infrastructure through code.

### 5. CI/CD Integration

Cloud services can be integrated with CI/CD tools and Git repositories.

### 6. Monitoring

Applications and infrastructure can be monitored continuously.

### 7. Containerization

Cloud platforms provide services for running and managing containers and Kubernetes workloads.

---

# 13. My Understanding and Learning

Through this task, I learned that AWS and GCP are major cloud platforms that provide infrastructure and managed services for modern applications.

I already had an understanding of AWS services such as EC2, S3, VPC, IAM, Elastic Load Balancing, Auto Scaling and CloudWatch. While working on this task, I revised these concepts and studied Google Cloud services in more detail.

I learned that GCP provides services similar to AWS. For example, Compute Engine is comparable to EC2, Cloud Storage is comparable to S3, GKE is comparable to EKS, Cloud Functions is comparable to Lambda and Cloud Monitoring is comparable to CloudWatch.

I also learned about GCP services such as Cloud Run, Cloud Build, Artifact Registry, Cloud SQL and Cloud Logging.

The most important thing I understood is that cloud platforms provide the infrastructure required to implement modern DevOps practices such as CI/CD, containerization, Kubernetes, Infrastructure as Code, monitoring and logging.

---

# 14. AWS and GCP in a DevOps Career

Understanding cloud platforms is important for a DevOps Engineer.

DevOps engineers can use cloud services to:

* Deploy applications
* Manage servers
* Create networks
* Configure security
* Manage containers
* Deploy Kubernetes applications
* Build CI/CD pipelines
* Store application artifacts
* Monitor infrastructure
* Analyze logs
* Automate infrastructure using Terraform

Learning both AWS and GCP helps me understand cloud concepts that can be applied across different cloud environments.

---

# 15. Conclusion

AWS and GCP are powerful cloud platforms that provide services for computing, storage, networking, databases, security, containers, serverless applications, monitoring and DevOps.

AWS provides services such as EC2, S3, VPC, IAM, RDS and CloudWatch.

GCP provides services such as Compute Engine, Cloud Storage, VPC, Cloud IAM, GKE, Cloud Run, Cloud SQL, Cloud Monitoring and Cloud Build.

Although the service names and implementations are different, both platforms provide solutions for similar cloud and DevOps requirements.

This task improved my understanding of cloud computing and helped me understand how AWS and GCP services can be used in real-world DevOps environments.

---

#
