# AWS & GCP – Cloud Platforms

## 1. Introduction to Cloud Computing

Cloud computing means using computing resources such as servers, storage, databases, networking and applications over the internet instead of managing everything on our own physical systems.

Some common benefits of cloud computing are:

* **Scalability:** Resources can be increased or decreased according to the requirement.
* **Flexibility:** Services can be accessed from different locations.
* **Cost efficiency:** We can pay for the resources we use instead of maintaining physical infrastructure.
* **Availability:** Cloud providers offer infrastructure designed for high availability.
* **Faster deployment:** Servers and other resources can be created much faster than setting up physical infrastructure.

The three common cloud service models are:

* **IaaS (Infrastructure as a Service):** Provides virtual machines, storage and networking.
* **PaaS (Platform as a Service):** Provides a platform to develop and deploy applications without managing the complete infrastructure.
* **SaaS (Software as a Service):** Provides ready-to-use software through the internet.

---

# 2. Amazon Web Services (AWS)

## What is AWS?

AWS stands for Amazon Web Services. It is a cloud platform provided by Amazon that offers many services for computing, storage, databases, networking, security, monitoring and application deployment.

Instead of maintaining physical servers, an organization can use AWS services according to its requirements.

I explored the main AWS services that are commonly used in application development and DevOps.

## 2.1 EC2 – Elastic Compute Cloud

EC2 provides virtual servers in the AWS cloud.

An EC2 instance can be used to run applications, APIs, websites or other workloads.

Some basic concepts related to EC2 are:

* **Instance:** A virtual server running in AWS.
* **AMI:** A template used to launch an EC2 instance.
* **Instance Type:** Defines the computing resources such as CPU and memory.
* **Security Group:** Acts like a virtual firewall and controls network traffic to the instance.

For example, a Node.js backend application can be deployed on an EC2 instance.

---

## 2.2 S3 – Simple Storage Service

S3 is an object storage service used to store files and other objects.

S3 organizes data using:

* **Bucket:** A container where objects are stored.
* **Object:** The actual file/data stored in the bucket.

S3 can be used for storing images, documents, backups, logs and static website files.

One important advantage of S3 is that it is designed for highly durable storage and can handle large amounts of data.

---

## 2.3 RDS – Relational Database Service

RDS is a managed relational database service.

It supports databases such as:

* PostgreSQL
* MySQL
* MariaDB
* Oracle
* SQL Server

With RDS, AWS manages many database infrastructure tasks, so developers do not have to manually manage the underlying server for every database operation.

For example, an application using PostgreSQL can use Amazon RDS as its managed database.

---

## 2.4 VPC – Virtual Private Cloud

VPC allows us to create a logically isolated network in AWS.

Some important VPC concepts are:

* **Subnet:** A smaller network section inside a VPC.
* **Route Table:** Controls where network traffic should go.
* **Internet Gateway:** Allows communication between a VPC and the internet when properly configured.
* **Security Group:** Controls traffic to resources such as EC2 instances.

VPC is important because applications and resources can be organized and protected inside a controlled network environment.

---

## 2.5 IAM – Identity and Access Management

IAM is used to manage access to AWS resources.

IAM mainly deals with:

* Users
* Groups
* Roles
* Policies
* Permissions

For example, instead of giving every user full access to AWS, we can give users only the permissions they need.

This follows the principle of giving users the minimum required access.

---

## 2.6 Lambda

AWS Lambda is a serverless compute service.

With Lambda, code can run without directly managing a server.

A Lambda function can be triggered by different events, such as an API request or an event from another AWS service.

It is useful for small backend operations, automation and event-driven applications.

---

## 2.7 CloudWatch

Amazon CloudWatch is used for monitoring AWS resources and applications.

It can provide:

* Metrics
* Logs
* Monitoring dashboards
* Alarms

For example, CloudWatch can be used to monitor an EC2 instance and check application or system-related metrics.

---

# 3. Google Cloud Platform (GCP)

## What is GCP?

GCP stands for Google Cloud Platform. It is Google's cloud computing platform.

GCP provides services for compute, storage, databases, networking, security, containers, monitoring and application deployment.

Like AWS, GCP allows organizations to use cloud resources without maintaining all the physical infrastructure themselves.

I explored the main GCP services that are comparable to commonly used AWS services.

---

## 3.1 Compute Engine

Google Compute Engine provides virtual machines that can be used to run applications and workloads.

It is conceptually similar to AWS EC2.

A Compute Engine VM can be used to host a backend application, web server or other software.

The resources of a VM can be selected according to the workload requirements.

---

## 3.2 Cloud Storage

Google Cloud Storage is an object storage service.

It stores data using buckets and objects.

It can be used to store:

* Images
* Documents
* Backups
* Application files
* Other large amounts of data

Cloud Storage is similar in concept to Amazon S3.

---

## 3.3 Cloud SQL

Cloud SQL is a managed relational database service provided by Google Cloud.

It supports database systems such as:

* MySQL
* PostgreSQL
* SQL Server

Cloud SQL reduces the need to manually manage database infrastructure.

For example, a web application can use PostgreSQL through Cloud SQL instead of maintaining a database server manually.

---

## 3.4 VPC

Google Cloud VPC provides networking for resources running on Google Cloud.

It helps in creating and managing network connectivity between cloud resources.

Important concepts include:

* VPC networks
* Subnets
* Routes
* Firewall rules
* IP addresses

VPC is important for controlling how different cloud resources communicate with each other.

---

## 3.5 IAM

Google Cloud IAM is used to control access to Google Cloud resources.

It manages who can access a resource and what actions they are allowed to perform.

IAM uses roles and permissions to provide controlled access.

For example, a developer may receive permission to work with a particular service without receiving complete access to the entire cloud project.

---

## 3.6 Cloud Functions

Cloud Functions is a serverless compute option in Google Cloud.

It allows developers to run code in response to events without directly managing servers.

It can be useful for event-driven backend operations and automation.

The basic idea is similar to AWS Lambda.

---

## 3.7 Google Kubernetes Engine (GKE)

GKE is Google's managed Kubernetes service.

Kubernetes is used for managing and orchestrating containers.

GKE helps deploy and manage containerized applications using Kubernetes.

It is useful when applications are built using containers and require features such as scaling and container management.

---

## 3.8 Cloud Monitoring

Google Cloud Monitoring is used to monitor applications and infrastructure running on Google Cloud.

It provides information such as:

* Metrics
* Performance information
* Dashboards
* Alerts

It helps in identifying issues and understanding the health of cloud resources.

---

# 4. AWS vs GCP

Both AWS and GCP provide similar categories of cloud services, although the service names and implementations are different.

| Requirement                 | AWS        | GCP              |
| --------------------------- | ---------- | ---------------- |
| Virtual Machines            | EC2        | Compute Engine   |
| Object Storage              | S3         | Cloud Storage    |
| Managed Relational Database | RDS        | Cloud SQL        |
| Virtual Network             | VPC        | VPC              |
| Identity & Access           | IAM        | IAM              |
| Serverless Functions        | Lambda     | Cloud Functions  |
| Kubernetes                  | EKS        | GKE              |
| Monitoring                  | CloudWatch | Cloud Monitoring |

The main thing I understood from the comparison is that both platforms provide similar building blocks, but their service names, interfaces and specific features can be different.

---

# 5. Practical Exploration

I used the provided cloud learning/playground resources to explore the cloud environment and understand how the services are organized.

I focused mainly on understanding the purpose of services such as EC2, S3, IAM and networking concepts in AWS, and their corresponding services in GCP.

The playground environment was useful for getting familiar with the cloud console and understanding where different services are available.

My focus during this task was on understanding the purpose and basic working of the services rather than going deeply into advanced cloud architecture.

---

# 6. What I Learned

During this task, I learned that cloud platforms provide different services that can be combined to build and deploy applications.

For example, a basic application can use:

* A compute service to run the application.
* Object storage to store files.
* A managed database for application data.
* Networking services to control communication.
* IAM to manage access and permissions.
* Monitoring services to observe the application and infrastructure.

I also understood that AWS and GCP have many equivalent services. Learning one cloud platform makes it easier to understand the concepts of another cloud platform because the underlying cloud concepts are similar.

From a DevOps perspective, understanding compute, storage, networking, IAM and monitoring is important because these services are commonly involved when deploying and maintaining applications.

---

# 7. Conclusion

AWS and GCP are both major cloud platforms that provide a wide range of services for developing, deploying and managing applications.

Through this task, I gained a basic understanding of the core services of both platforms and their use cases. I also learned how services such as compute, storage, databases, networking, IAM and monitoring work together.

This exploration gave me a foundation for learning more advanced topics such as cloud deployment, containers, Kubernetes, CI/CD and infrastructure automation in the future.
