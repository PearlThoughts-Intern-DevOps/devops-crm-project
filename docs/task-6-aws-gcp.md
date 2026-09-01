# Task 6: AWS & GCP Exploration

## 1. Introduction

Cloud computing has become an important part of modern software development and DevOps. Instead of maintaining physical servers, organizations can use cloud platforms to create servers, store data, manage networks, deploy applications, and monitor infrastructure through the internet.

For this task, I explored two major cloud platforms: Amazon Web Services (AWS) and Google Cloud Platform (GCP). The main goal was to understand what these platforms provide, how their services are used, and how they fit into a DevOps environment.

---

## 2. What I Understood About Cloud Computing

Cloud computing means using computing resources such as servers, storage, databases, networking, and software over the internet instead of owning and maintaining all the physical infrastructure ourselves.

Some important advantages of cloud computing are:

- Resources can be created when they are needed.
- Infrastructure can be scaled according to demand.
- Organizations can avoid purchasing and maintaining physical servers.
- Many services are available on a pay-as-you-use basis.
- Monitoring, security, backups, and other infrastructure tasks can be managed using cloud services.

From a DevOps perspective, cloud computing is useful because infrastructure can be created, configured, deployed, and monitored using automation.

---

# 3. Amazon Web Services (AWS)

AWS is a cloud platform provided by Amazon. It offers a large collection of services for computing, storage, networking, databases, security, monitoring, and application development.

While exploring AWS, I focused on services that are especially relevant to infrastructure and DevOps.

## 3.1 Amazon EC2

Amazon EC2 (Elastic Compute Cloud) provides virtual servers in the cloud.

Instead of purchasing a physical server, we can create an EC2 instance and run applications on it. We can select the operating system, instance size, storage, networking configuration, and other settings.

### Example

A company could use an EC2 instance to host a web application.

```text
User
  |
Internet
  |
AWS
  |
EC2 Instance
  |
Web Application
```

EC2 is useful when we need control over the server environment.

---

## 3.2 Amazon S3

Amazon S3 (Simple Storage Service) is an object storage service.

It can be used to store files such as:

- Images
- Videos
- Documents
- Backups
- Logs
- Application files

S3 stores data inside containers called buckets.

For example, a web application could store uploaded images in an S3 bucket instead of keeping them directly on the application server.

---

## 3.3 Amazon VPC

Amazon VPC (Virtual Private Cloud) is used to create and manage a private network environment inside AWS.

A VPC allows us to configure networking components such as:

- Subnets
- Route tables
- Internet gateways
- Security groups
- Network access control lists

A simple application architecture could contain public and private subnets.

```text
                 Internet
                    |
              Internet Gateway
                    |
                 VPC
              /              Public Subnet    Private Subnet
          |                |
      Web Server        Database
```

Understanding VPC is important because networking is a major part of cloud infrastructure.

---

## 3.4 AWS IAM

IAM stands for Identity and Access Management.

It controls who can access AWS resources and what actions they are allowed to perform.

IAM can be used with:

- Users
- Groups
- Roles
- Policies

For example, a developer might be allowed to view an S3 bucket but not delete it.

The main idea I learned is that cloud resources should follow the principle of least privilege, meaning users and applications should receive only the permissions they actually need.

---

## 3.5 Amazon RDS

Amazon RDS (Relational Database Service) is a managed database service.

It supports relational database engines and handles many administrative tasks such as:

- Database provisioning
- Backups
- Patching
- Monitoring
- Scaling options

This means developers do not always need to manually manage a database server.

---

## 3.6 AWS Lambda

AWS Lambda is a serverless compute service.

With Lambda, code can run in response to events without manually managing a server.

For example:

```text
File uploaded to S3
        |
        v
     Lambda
        |
        v
Process the file
```

Lambda can be useful for event-driven applications and small backend tasks.

---

## 3.7 Amazon CloudWatch

Amazon CloudWatch is used for monitoring AWS resources and applications.

It can collect and provide information such as:

- CPU utilization
- Application logs
- Metrics
- Alarms
- Performance information

CloudWatch is particularly relevant to DevOps because monitoring helps identify performance problems and infrastructure issues.

---

# 4. Google Cloud Platform (GCP)

Google Cloud Platform, commonly called GCP, is Google's cloud computing platform.

Like AWS, GCP provides services for computing, storage, networking, databases, security, monitoring, containers, and application development.

I explored several GCP services that are comparable to services available in AWS.

---

## 4.1 Compute Engine

Google Compute Engine provides virtual machines running on Google's infrastructure.

It is similar to AWS EC2.

We can choose the machine configuration, operating system, storage, and networking settings according to the application's requirements.

### Example

A company could deploy a backend application on a Compute Engine virtual machine.

```text
User
  |
Internet
  |
GCP
  |
Compute Engine
  |
Application
```

---

## 4.2 Cloud Storage

Google Cloud Storage is an object storage service.

It can store files such as:

- Images
- Videos
- Documents
- Backups
- Logs

It is conceptually similar to Amazon S3.

---

## 4.3 Google Cloud VPC

Google Cloud VPC provides networking capabilities for resources running on GCP.

It can be used to manage:

- Networks
- Subnets
- Routes
- Firewall rules
- Network connectivity

This allows applications and services to communicate securely within the cloud environment.

---

## 4.4 Google Cloud IAM

Google Cloud IAM manages permissions and access to GCP resources.

It determines:

- Who can access a resource
- What actions they can perform
- Which resources they can access

Like AWS IAM, access should be carefully controlled using appropriate permissions.

---

## 4.5 Cloud SQL

Cloud SQL is a managed relational database service provided by Google Cloud.

It can be used without manually maintaining the underlying database infrastructure.

It provides features related to database management, backups, maintenance, and scalability.

It is comparable to Amazon RDS.

---

## 4.6 Cloud Functions

Google Cloud Functions is a serverless computing service.

It allows developers to execute code in response to events without managing traditional servers.

For example, a function could be triggered when a file is uploaded or when an application event occurs.

This is similar in concept to AWS Lambda.

---

## 4.7 Google Cloud Monitoring

Google Cloud Monitoring is used to monitor applications and infrastructure running on Google Cloud.

It provides information about:

- Resource performance
- Metrics
- Application health
- Monitoring dashboards
- Alerts

It serves a similar purpose to Amazon CloudWatch.

---

# 5. AWS vs GCP

AWS and GCP provide many similar categories of cloud services, although the names and implementations are different.

| Requirement | AWS | GCP |
|---|---|---|
| Virtual Machines | EC2 | Compute Engine |
| Object Storage | S3 | Cloud Storage |
| Networking | VPC | VPC |
| Identity & Access | IAM | Cloud IAM |
| Managed SQL Database | RDS | Cloud SQL |
| Serverless Functions | Lambda | Cloud Functions |
| Monitoring | CloudWatch | Cloud Monitoring |

The important thing I learned from this comparison is that learning one cloud platform also makes it easier to understand another because the underlying cloud concepts are often similar.

The terminology and implementation can be different, but concepts such as compute, storage, networking, identity, databases, and monitoring exist across both platforms.

---

# 6. Understanding Cloud Architecture

A cloud application usually does not depend on a single service. Multiple services work together.

For example, a simple web application could use:

```text
                    Users
                      |
                   Internet
                      |
                Load Balancer
                  /                        /                     Web Server   Web Server
                 \         /
                  \       /
                 Database
                    |
                 Storage
```

Additional services can provide:

- Authentication and access control
- Monitoring
- Logging
- Backups
- Security
- Automated deployment

This helped me understand that cloud computing is not simply "renting a server." It is an ecosystem of interconnected services used to build and operate applications.

---

# 7. AWS/GCP and DevOps

Cloud platforms are closely connected with DevOps.

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
    v
Application Deployment
    |
    v
Monitoring & Logging
```

AWS and GCP provide services that can support different stages of this workflow.

For example:

- Compute services run applications.
- Storage services store application data and files.
- IAM manages access.
- Networking services connect infrastructure.
- Monitoring services provide operational visibility.
- CI/CD and automation tools can help deploy applications consistently.

This is particularly relevant to my DevOps learning because it shows how Git, automation, containers, cloud infrastructure, and monitoring can work together.

---

# 8. Key Differences I Observed

Although AWS and GCP offer similar services, there are differences in their approach and ecosystems.

### AWS

- Has a very large range of cloud services.
- Has strong adoption across many industries.
- Provides extensive infrastructure and DevOps-related services.
- Uses concepts such as Availability Zones and Regions extensively.

### GCP

- Has strong integration with Google's infrastructure and technologies.
- Provides strong services for data analytics, machine learning, and container-based workloads.
- Uses Google's global infrastructure and networking capabilities.
- Kubernetes is especially important in the Google Cloud ecosystem.

I also learned that choosing a cloud platform is not only about comparing individual services. Factors such as pricing, architecture requirements, existing technologies, team skills, security requirements, and scalability also matter.

---

# 9. What I Learned

After exploring AWS and GCP, I understood several important concepts:

1. Cloud platforms provide much more than virtual machines.
2. Compute, storage, networking, databases, IAM, and monitoring are fundamental cloud components.
3. AWS and GCP have many equivalent services.
4. IAM and security are important when working with cloud infrastructure.
5. Networking concepts such as VPCs and subnets are important for designing cloud applications.
6. Monitoring helps DevOps teams understand the health and performance of infrastructure.
7. Managed services reduce the amount of infrastructure maintenance required.
8. Serverless services allow applications to execute code without managing traditional servers.
9. Cloud services can be combined to build complete application architectures.
10. Understanding cloud fundamentals is important for working in DevOps and cloud engineering.

---

# 10. My Overall Understanding

Before exploring these platforms, I mainly understood cloud computing as running applications on remote servers.

After studying AWS and GCP, my understanding became broader.

I now understand cloud platforms as collections of interconnected infrastructure and managed services. A real application can use compute for processing, storage for files, databases for structured data, networking for communication, IAM for access control, and monitoring for operational visibility.

I also understood why cloud knowledge is important for DevOps. DevOps is not only about Git or CI/CD pipelines. It also involves understanding the infrastructure on which applications are built, deployed, secured, and monitored.

---

# 11. Conclusion

AWS and GCP are two major cloud platforms that provide services for building, deploying, and managing applications.

Although their service names and implementations differ, their core concepts are similar. Both provide solutions for compute, storage, networking, databases, identity management, serverless computing, and monitoring.

This exploration gave me a foundation for understanding cloud infrastructure and how it connects with DevOps practices. Going forward, I can use this foundation to study AWS more deeply and work with services such as EC2, S3, VPC, IAM, CloudWatch, and automation tools.

---

# 12. Loom Video

**Task 6 AWS & GCP Explanation:**

> Watch the Loom video to see my explanation of AWS and GCP.

**Loom Link:** https://www.loom.com/share/3cb4d0d37c6f4fad86758bc681da8e77

The Loom video explains the concepts covered in this document, including AWS, GCP, major services, the AWS vs GCP comparison, and my overall understanding of cloud platforms.

---

## Task Information

**Task:** Task 6 - AWS & GCP  
**Repository:** devops-crm-project  
**Branch:** tushar-task6  
**Student:** Tushar Singh
