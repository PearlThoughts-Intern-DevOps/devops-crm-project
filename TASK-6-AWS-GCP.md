# Task 6 – Exploring AWS and GCP

---

## 1. Introduction

Cloud computing means using computing resources over the internet instead of managing physical servers and infrastructure ourselves.

Cloud platforms provide services for running applications, storing data, managing databases, networking, security, and monitoring.

For this task, I explored the basic concepts and services provided by **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**.

Both platforms provide similar types of cloud services, but their service names, interfaces, and implementations are different.

---

# 2. AWS – Amazon Web Services

## What is AWS?

AWS is a cloud platform provided by Amazon. It provides many services that can be used to build, deploy, and manage applications.

I understood AWS as a collection of cloud services that allows developers and DevOps engineers to use infrastructure without having to maintain physical servers.

Some important AWS services I explored are:

* EC2
* S3
* IAM
* VPC
* RDS
* CloudWatch

---

## 2.1 EC2 – Compute

**Amazon EC2 (Elastic Compute Cloud)** provides virtual machines in AWS.

I understood EC2 as a cloud-based server where we can run applications, APIs, websites, and other workloads.

In DevOps, EC2 can be used to host applications and services.

**Example:**

An organization can create an EC2 instance and deploy its backend application on that server.

---

## 2.2 S3 – Storage

**Amazon S3 (Simple Storage Service)** is used for storing files and objects.

It can be used to store:

* Images
* Videos
* Documents
* Backups
* Logs
* Application files

S3 stores data inside **buckets**.

I understood S3 as cloud storage where application-related files can be stored without managing a physical storage server.

---

## 2.3 IAM – Identity and Access Management

**AWS IAM** is used to control access to AWS resources.

IAM allows us to manage:

* Users
* Roles
* Policies
* Permissions

For example, a developer may need access to an S3 bucket but should not have permission to modify other AWS resources.

I learned that IAM is important for security because users and applications should only receive the permissions they actually need.

---

## 2.4 VPC – Virtual Private Cloud

**Amazon VPC** is used to create and manage a private network inside AWS.

It allows us to configure networking components such as:

* Subnets
* Route tables
* Internet gateways
* Security groups
* Network ACLs

I understood VPC as the networking environment in which AWS resources can communicate securely.

---

## 2.5 RDS – Relational Database Service

**Amazon RDS** is a managed relational database service.

Instead of manually setting up and maintaining a database server, RDS handles many database administration tasks.

It can be used when an application requires a relational database.

I understood RDS as a managed database service that reduces the amount of infrastructure management required from the developer or DevOps team.

---

## 2.6 CloudWatch – Monitoring

**Amazon CloudWatch** is used to monitor AWS resources and applications.

It provides information such as:

* Metrics
* Logs
* Alarms
* Dashboards

For DevOps, monitoring is important because it helps identify application failures, resource usage, and performance issues.

---

# 3. GCP – Google Cloud Platform

## What is GCP?

Google Cloud Platform, commonly called **Google Cloud**, is Google's cloud computing platform.

Like AWS, it provides services for computing, storage, databases, networking, security, monitoring, containers, and application deployment.

I explored the main GCP services and understood how they compare with similar AWS services.

Important GCP services include:

* Compute Engine
* Cloud Storage
* Cloud IAM
* VPC
* Cloud SQL
* Cloud Monitoring

---

## 3.1 Compute Engine – Compute

**Google Compute Engine** provides virtual machines in Google Cloud.

I understood Compute Engine as a cloud-based virtual server where applications and services can be deployed.

It is similar to **AWS EC2**.

**Example:**

A backend application can be deployed on a Compute Engine virtual machine.

---

## 3.2 Cloud Storage – Storage

**Google Cloud Storage** is used to store files and objects.

It can be used for:

* Images
* Videos
* Documents
* Backups
* Application files

Cloud Storage uses **buckets** to organize stored objects.

It is similar to **Amazon S3**.

---

## 3.3 Cloud IAM – Access Management

**Google Cloud IAM** is used to control access to Google Cloud resources.

It manages identities, roles, and permissions.

I understood that IAM helps organizations control who can access specific cloud resources and what actions they are allowed to perform.

It is similar to **AWS IAM**.

---

## 3.4 VPC Network – Networking

Google Cloud provides **VPC networking** for connecting and controlling cloud resources.

It provides networking features such as:

* Networks
* Subnets
* Routes
* Firewall rules

I understood that VPC provides the networking layer required for applications and cloud resources to communicate securely.

It is similar to AWS VPC.

---

## 3.5 Cloud SQL – Database

**Cloud SQL** is a managed relational database service provided by Google Cloud.

It reduces the need to manually manage the underlying database infrastructure.

Cloud SQL is similar to **Amazon RDS**.

---

## 3.6 Cloud Monitoring – Monitoring

**Cloud Monitoring** is used to monitor applications and infrastructure running on Google Cloud.

It provides information such as:

* Metrics
* Dashboards
* Alerts
* Performance information

It is similar to **AWS CloudWatch**.

---

# 4. AWS and GCP Comparison

Although AWS and GCP are different cloud platforms, many of their services solve similar problems.

| Purpose                     | AWS        | GCP              |
| --------------------------- | ---------- | ---------------- |
| Virtual machines            | EC2        | Compute Engine   |
| Object storage              | S3         | Cloud Storage    |
| Identity & permissions      | IAM        | Cloud IAM        |
| Networking                  | VPC        | VPC              |
| Managed relational database | RDS        | Cloud SQL        |
| Monitoring                  | CloudWatch | Cloud Monitoring |
| Kubernetes                  | EKS        | GKE              |

The main difference I noticed is that the platforms use different service names and provide different implementations and management interfaces.

The basic cloud concepts are similar, so learning one platform can make it easier to understand another cloud platform.

---

# 5. AWS and GCP in DevOps

Cloud platforms are very useful in DevOps because they provide infrastructure that can be integrated with development and deployment pipelines.

A typical DevOps workflow can look like:

```text
Developer
    ↓
Git Repository
    ↓
CI/CD Pipeline
    ↓
Build & Test
    ↓
Container Image
    ↓
Cloud Infrastructure
    ↓
Application Deployment
    ↓
Monitoring
```

For example, a DevOps team can:

1. Store source code in Git.
2. Use a CI/CD pipeline to build and test the application.
3. Create a container image.
4. Store the image in a container registry.
5. Deploy the application to cloud infrastructure.
6. Monitor the application using cloud monitoring services.
7. Use alerts and logs to identify problems.

AWS and GCP both provide services that can support this workflow.

---

# 6. Security and Access Management

Security is an important part of cloud computing.

Both AWS and GCP provide IAM systems to control access to cloud resources.

Some important security practices I learned are:

* Use strong authentication.
* Enable multi-factor authentication where possible.
* Follow the principle of least privilege.
* Do not share access credentials.
* Use roles and service accounts where appropriate.
* Protect application secrets and credentials.
* Monitor access and resource activity.
* Configure network security controls properly.

For DevOps, secure access is especially important because CI/CD pipelines may need permission to deploy applications and access cloud resources.

---

# 7. My Understanding

From this task, I understood that AWS and GCP are two different cloud platforms that provide many similar categories of services.

I learned that cloud computing allows organizations to use computing infrastructure without having to purchase and maintain physical servers.

The main services I learned can be summarized as:

* **EC2 / Compute Engine** → Virtual machines
* **S3 / Cloud Storage** → Object storage
* **IAM / Cloud IAM** → Access and permissions
* **VPC / VPC** → Networking
* **RDS / Cloud SQL** → Managed relational databases
* **CloudWatch / Cloud Monitoring** → Monitoring

I also understood how cloud platforms can be used together with DevOps practices such as CI/CD, application deployment, infrastructure management, monitoring, and security.

---

# 8. Key Takeaways

The main things I learned from this task are:

1. Cloud computing provides infrastructure and services over the internet.
2. AWS and GCP are different cloud platforms.
3. Both platforms provide similar categories of services.
4. EC2 and Compute Engine provide virtual machines.
5. S3 and Cloud Storage provide object storage.
6. IAM is important for controlling access to resources.
7. VPC provides cloud networking.
8. RDS and Cloud SQL provide managed relational databases.
9. Monitoring services help track application and infrastructure health.
10. Cloud platforms are an important part of modern DevOps workflows.

---

# 9. Conclusion

Exploring AWS and GCP helped me understand the basic concepts of cloud computing and how cloud services are used in DevOps.

Although AWS and GCP have different service names and interfaces, their core concepts are similar.

Understanding services related to computing, storage, networking, databases, IAM, and monitoring gives a strong foundation for working with cloud infrastructure and DevOps.

This task helped me connect the cloud concepts I learned with practical DevOps activities such as application deployment, CI/CD, security, and monitoring.
