# AWS & GCP Cloud Platforms – Learning Documentation

## 1. Introduction

Cloud computing provides computing resources such as servers, storage, databases, networking, and application services over the internet.

Two major cloud platforms are:

* Amazon Web Services (AWS)
* Google Cloud Platform (GCP)

Both platforms provide services that help organizations build, deploy, manage, and monitor applications without maintaining all physical infrastructure themselves.

---

## 2. Amazon Web Services (AWS)

### What is AWS?

Amazon Web Services (AWS) is a cloud computing platform provided by Amazon. It offers a large collection of services for computing, storage, networking, databases, security, monitoring, and DevOps.

AWS allows organizations to provision resources when required and scale them according to application requirements.

### Important AWS Services

| Service        | Purpose                               |
| -------------- | ------------------------------------- |
| EC2            | Provides virtual servers in the cloud |
| S3             | Stores files and objects              |
| VPC            | Provides isolated cloud networking    |
| IAM            | Manages users, roles, and permissions |
| RDS            | Provides managed relational databases |
| Lambda         | Runs code without managing servers    |
| CloudWatch     | Monitoring, logs, and metrics         |
| EKS            | Managed Kubernetes service            |
| CloudFormation | Infrastructure as Code                |
| CodePipeline   | CI/CD pipeline service                |

### AWS EC2

Amazon EC2 provides virtual machines that can be used to host applications, websites, APIs, and other workloads.

As a DevOps learner, EC2 is useful for understanding:

* Server provisioning
* Linux administration
* Application deployment
* Security groups
* Networking
* Scaling

### AWS S3

Amazon S3 is an object storage service.

It can be used to store:

* Images
* Videos
* Documents
* Backups
* Application files
* Static website files

### AWS VPC

Amazon VPC provides networking for AWS resources.

It allows users to configure:

* Subnets
* Route tables
* Internet gateways
* Security groups
* Network access

### AWS IAM

IAM stands for Identity and Access Management.

It controls who can access AWS resources and what actions they are allowed to perform.

IAM uses:

* Users
* Groups
* Roles
* Policies

### AWS RDS

Amazon RDS is a managed relational database service.

It supports database engines such as:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

AWS manages many database administration tasks such as backups and infrastructure maintenance.

### AWS Lambda

AWS Lambda is a serverless compute service.

It allows developers to run code without managing servers directly.

Lambda can be useful for event-driven applications and automation.

### AWS CloudWatch

CloudWatch is used for monitoring AWS resources and applications.

It provides:

* Metrics
* Logs
* Alarms
* Monitoring dashboards

### AWS EKS

Amazon EKS is a managed Kubernetes service.

It allows organizations to run Kubernetes workloads on AWS without managing the entire Kubernetes control plane themselves.

---

## 3. Google Cloud Platform (GCP)

### What is GCP?

Google Cloud Platform (GCP), commonly called Google Cloud, is Google's cloud computing platform.

It provides services for computing, storage, networking, databases, containers, Kubernetes, analytics, security, and DevOps.

### Important GCP Services

| Service          | Purpose                               |
| ---------------- | ------------------------------------- |
| Compute Engine   | Provides virtual machines             |
| Cloud Storage    | Stores objects and files              |
| VPC              | Provides cloud networking             |
| IAM              | Manages access and permissions        |
| Cloud SQL        | Provides managed relational databases |
| Cloud Run        | Runs containerized applications       |
| GKE              | Managed Kubernetes service            |
| BigQuery         | Data warehouse and analytics          |
| Cloud Monitoring | Monitoring and metrics                |
| Cloud Build      | CI/CD and build automation            |

### GCP Compute Engine

Compute Engine provides virtual machines that can be used to host applications and services.

It is similar to AWS EC2.

It can be used for:

* Web servers
* Application servers
* Linux administration
* Application deployment

### GCP Cloud Storage

Cloud Storage is an object storage service.

It can store:

* Files
* Images
* Videos
* Backups
* Application data

It is conceptually similar to Amazon S3.

### GCP VPC

Google Cloud VPC provides networking for cloud resources.

It supports:

* Networks
* Subnets
* Firewall rules
* Routes
* Network connectivity

### GCP IAM

Google Cloud IAM controls access to cloud resources.

It uses identities, roles, and permissions to determine what users and services can access.

### GCP Cloud SQL

Cloud SQL is a managed relational database service.

It supports databases such as:

* MySQL
* PostgreSQL
* SQL Server

Google Cloud manages many infrastructure and database administration tasks.

### GCP Cloud Run

Cloud Run is a managed platform for running containerized applications.

It is useful for deploying applications without manually managing servers.

### GCP GKE

Google Kubernetes Engine (GKE) is Google's managed Kubernetes service.

It helps organizations deploy and manage containerized applications using Kubernetes.

### GCP BigQuery

BigQuery is a cloud data warehouse and analytics platform.

It can process large datasets and is useful for data analytics and reporting.

### GCP Cloud Monitoring

Cloud Monitoring provides monitoring and observability for applications and infrastructure.

It can provide:

* Metrics
* Dashboards
* Alerts
* Monitoring information

### GCP Cloud Build

Cloud Build is a service used to build and deploy applications.

It can be used as part of CI/CD workflows.

---

## 4. AWS and GCP Comparison

| Area                  | AWS               | GCP              |
| --------------------- | ----------------- | ---------------- |
| Virtual Machines      | EC2               | Compute Engine   |
| Object Storage        | S3                | Cloud Storage    |
| Networking            | VPC               | VPC              |
| Identity & Access     | IAM               | IAM              |
| Managed SQL Database  | RDS               | Cloud SQL        |
| Serverless/Containers | Lambda            | Cloud Run        |
| Kubernetes            | EKS               | GKE              |
| Monitoring            | CloudWatch        | Cloud Monitoring |
| Data Analytics        | Redshift / Athena | BigQuery         |
| CI/CD                 | CodePipeline      | Cloud Build      |

Both platforms provide similar categories of cloud services, although their service names, features, pricing models, and implementation details can differ.

---

## 5. AWS and GCP for DevOps

Cloud platforms are very useful in DevOps because they provide infrastructure and services that can be integrated with automation and CI/CD tools.

A DevOps workflow can include:

1. Developer pushes code to GitHub.
2. CI pipeline builds and tests the application.
3. Docker creates a container image.
4. The image can be stored in a container registry.
5. The application can be deployed to cloud infrastructure.
6. Monitoring tools collect logs and metrics.
7. Alerts can notify the team about problems.

AWS and GCP both support this type of workflow.

---

## 6. Services Relevant to My DevOps Learning

The following services are particularly relevant to my DevOps learning:

### AWS

* EC2 for virtual servers
* S3 for object storage
* VPC for networking
* IAM for access control
* EKS for Kubernetes
* CloudWatch for monitoring
* CloudFormation for Infrastructure as Code

### GCP

* Compute Engine for virtual machines
* Cloud Storage for object storage
* VPC for networking
* IAM for access control
* GKE for Kubernetes
* Cloud Monitoring for monitoring
* Cloud Build for CI/CD

These services connect with DevOps concepts such as Linux administration, networking, containers, Kubernetes, CI/CD, automation, monitoring, and Infrastructure as Code.

---

## 7. Key Learnings

From exploring AWS and GCP, I learned that:

1. Cloud platforms provide infrastructure and services over the internet.
2. Virtual machines can be created without purchasing physical servers.
3. Object storage is useful for files, backups, and application data.
4. IAM is important for controlling access securely.
5. VPC services provide cloud networking.
6. Managed databases reduce infrastructure administration work.
7. Kubernetes services such as EKS and GKE help run containerized workloads.
8. Monitoring services help track application and infrastructure health.
9. Cloud services can be integrated with CI/CD pipelines.
10. AWS and GCP provide similar cloud capabilities but use different service names and implementations.

---

## 8. Conclusion

AWS and GCP are powerful cloud platforms that provide services for computing, storage, networking, databases, security, containers, Kubernetes, monitoring, and DevOps.

As a DevOps learner, understanding these services is important because modern applications are commonly deployed and managed using cloud infrastructure.

The exploration of AWS and GCP helped me understand how cloud services fit into DevOps workflows and how services such as virtual machines, storage, networking, IAM, Kubernetes, monitoring, and CI/CD can be used to build and operate applications.
