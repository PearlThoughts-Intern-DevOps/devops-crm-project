# Task 6: AWS & GCP

## 1. Objective

The objective of this task was to explore both AWS and Google Cloud Platform and understand their cloud services and their basic use in Cloud and DevOps.

I explored the basic services in both AWS and GCP through their cloud consoles and learned how these services are used.

The main services I explored were:

### AWS

* EC2
* S3
* IAM
* DynamoDB
* VPC

### Google Cloud Platform

* Compute Engine
* Cloud Storage
* IAM
* Firestore
* VPC Network

---

# 2. AWS Exploration

## 2.1 Amazon EC2

Amazon EC2 stands for Elastic Compute Cloud.

EC2 is used to create and run virtual machines in AWS.

While exploring EC2, I learned that we can select different instance types, operating systems, storage, networking, and other configurations while creating a virtual machine.

EC2 can be used to run applications, websites, servers, and other workloads in the cloud.

**What I learned:**

* EC2 provides virtual machines in AWS.
* We can select the required machine configuration.
* EC2 instances can be used to run applications and services.
* We can connect to an EC2 instance using SSH.

**Screenshot:**
*Add EC2 console screenshot here.*

---

## 2.2 Amazon S3

Amazon S3 stands for Simple Storage Service.

S3 is an object storage service used to store files and other data.

S3 stores data inside buckets. We can use buckets to store files such as images, documents, backups, logs, and application data.

**What I learned:**

* S3 is used for object storage.
* Data is stored inside buckets.
* S3 can be used for backups and application files.
* Access to buckets and objects can be controlled using permissions.

**Screenshot:**
*Add S3 console screenshot here.*

---

## 2.3 AWS IAM

IAM stands for Identity and Access Management.

IAM is used to manage users, roles, permissions, and access to AWS resources.

It helps control which users or services can access AWS resources and what actions they are allowed to perform.

**What I learned:**

* IAM manages access to AWS resources.
* Users can be given specific permissions.
* Roles can be used by AWS services and applications.
* IAM is important for AWS security.

**Screenshot:**
*Add IAM console screenshot here.*

---

## 2.4 Amazon DynamoDB

Amazon DynamoDB is a NoSQL database service provided by AWS.

It is used to store application data in tables and provides fast access to data.

DynamoDB is useful for applications that need scalable and highly available database storage.

**What I learned:**

* DynamoDB is a NoSQL database.
* Data is stored in tables.
* It is designed for fast and scalable applications.
* It can be used without managing traditional database servers.

**Screenshot:**
*Add DynamoDB console screenshot here.*

---

## 2.5 Amazon VPC

VPC stands for Virtual Private Cloud.

VPC is used to create and manage the network environment for AWS resources.

A VPC can contain components such as subnets, route tables, security groups, and internet connectivity.

**What I learned:**

* VPC provides networking for AWS resources.
* Resources can be organized inside subnets.
* Route tables control network traffic.
* Security groups help control network access.

**Screenshot:**
*Add VPC console screenshot here.*

---

# 3. Google Cloud Platform Exploration

## 3.1 Google Compute Engine

Google Compute Engine is the virtual machine service provided by Google Cloud.

It is used to create and run virtual machines on Google Cloud infrastructure.

While exploring Compute Engine, I created a VM instance and connected to it using the Google Cloud Console SSH option.

**What I learned:**

* Compute Engine is used for virtual machines.
* We can select the machine type and operating system.
* We can configure storage and networking for the VM.
* We can connect to the VM using SSH.

**Screenshot:**
*Add Compute Engine VM screenshot here.*

---

## 3.2 Google Cloud Storage

Google Cloud Storage is an object storage service.

It is used to store files and objects in buckets.

During the exploration, I created a Cloud Storage bucket and checked its configuration and access settings.

**What I learned:**

* Cloud Storage uses buckets to store objects.
* It can be used for files, backups, and application data.
* Storage classes can be selected based on requirements.
* Public access can be controlled using bucket settings.

**Screenshot:**
*Add Cloud Storage bucket screenshot here.*

---

## 3.3 Google Cloud IAM

Google Cloud IAM stands for Identity and Access Management.

It is used to control access to Google Cloud resources.

IAM allows us to manage users, roles, and permissions.

**What I learned:**

* IAM controls access to Google Cloud resources.
* Roles provide different levels of permissions.
* Permissions can be assigned to users and service accounts.
* IAM is important for cloud security.

**Screenshot:**
*Add GCP IAM screenshot here.*

---

## 3.4 Google Cloud Firestore

Firestore is a NoSQL document database service provided by Google Cloud.

It is used to store application data in documents and collections.

During the exploration, I created a Firestore database in Native mode with the Mumbai region.

**What I learned:**

* Firestore is a NoSQL document database.
* Data can be stored in collections and documents.
* It is a managed database service.
* It can be used for web and application data.

**Screenshot:**
*Add Firestore screenshot here.*

---

## 3.5 Google Cloud VPC Network

Google Cloud VPC Network is used for networking between Google Cloud resources.

The default VPC network was explored along with its subnets and network configuration.

The VM created in Compute Engine was connected to the default VPC network.

**What I learned:**

* VPC provides networking for Google Cloud resources.
* The default VPC contains subnets for different regions.
* Compute Engine VMs can use a VPC network.
* VPC helps manage communication between cloud resources.

**Screenshot:**
*Add VPC Network screenshot here.*

---

# 4. AWS and GCP Services Comparison

| Purpose             | AWS      | Google Cloud   |
| ------------------- | -------- | -------------- |
| Virtual Machines    | EC2      | Compute Engine |
| Object Storage      | S3       | Cloud Storage  |
| Identity and Access | IAM      | IAM            |
| NoSQL Database      | DynamoDB | Firestore      |
| Networking          | VPC      | VPC Network    |

Both AWS and Google Cloud provide similar types of cloud services, but the service names and some features are different.

---

# 5. Other Services Explored

While exploring the AWS and Google Cloud service menus, I also checked other services available on both platforms.

### AWS

Some of the other services include:

* Lambda
* RDS
* ECS
* EKS
* CloudFormation
* CloudWatch
* CodePipeline
* CodeBuild

### Google Cloud

Some of the other services include:

* Cloud Run
* Google Kubernetes Engine (GKE)
* Cloud Functions
* Cloud SQL
* BigQuery
* Cloud Build
* Artifact Registry
* Cloud Monitoring

I did not create resources for all these services. I explored the service menus and learned their basic purpose.

---

# 6. Cloud and DevOps Understanding

From this task, I understood how cloud platforms provide different services for running applications and managing infrastructure.

Compute services are used to run applications and virtual machines.

Storage services are used to store files and application data.

Database services are used to store structured and unstructured application data.

IAM services are used to manage users, roles, permissions, and security.

Networking services are used to connect and control communication between cloud resources.

These services are also commonly used together in DevOps and CI/CD environments.

For example, a virtual machine can run an application, object storage can store application files or artifacts, IAM can control access, a database can store application data, and VPC can provide the network environment.

---

# 7. Conclusion

Through this task, I explored both AWS and Google Cloud Platform and learned about their basic cloud services.

I explored EC2, S3, IAM, DynamoDB, and VPC in AWS.

I also explored Compute Engine, Cloud Storage, IAM, Firestore, and VPC Network in Google Cloud.

This helped me understand the basic purpose of compute, storage, database, identity, and networking services in cloud platforms and how they can be used in Cloud and DevOps.

