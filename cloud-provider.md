## On-Premise

On-premise computing means hosting and managing servers, applications, databases, and data within an organization's own physical location. The organization is responsible for purchasing hardware, installing software, security, maintenance, backups, and upgrades. It provides greater control over infrastructure but generally requires higher initial costs, maintenance efforts, and technical expertise.

## Cloud Computing
Cloud computing is the delivery of computing services such as storage, servers, databases, networking, and software over the Internet. Instead of storing data or running applications only on a personal computer, users can access these resources from cloud providers whenever needed.

####Major Advantages of Cloud Computing Over On-Premise Systems

**Cloud computing provides several major advantages over traditional on-premise infrastructure**:

1. Lower Cost: Reduces upfront investment in servers, hardware, and maintenance.
2. Scalability: Resources can be quickly increased or decreased based on demand.
3. Accessibility: Applications and data can be accessed from anywhere through the Internet.
4. Faster Deployment: Cloud services can be set up and deployed much faster than physical infrastructure.
5. Maintenance: The cloud provider manages hardware, updates, and much of the infrastructure maintenance.
6. Reliability: Provides backup, redundancy, and disaster-recovery capabilities.
7. Flexibility: Organizations can easily adapt resources to changing business requirements.

Overall, cloud computing offers greater cost efficiency, flexibility, scalability, and operational convenience compared with on-premise systems.

## Cloud Providers

Cloud providers are companies that offer computing resources and services over the Internet. They provide services such as **virtual machines, storage, databases, networking, security, and software** without requiring users to maintain physical infrastructure.

#### Major Cloud Providers

1. **Amazon Web Services (AWS):** Offers a wide range of cloud services and is widely used by businesses and developers.
2. **Microsoft Azure:** Provides cloud computing, databases, AI, analytics, and enterprise solutions.
3. **Google Cloud Platform (GCP):** Known for data analytics, artificial intelligence, machine learning, and scalable infrastructure.
4. **Other Providers:** IBM Cloud, Oracle Cloud, Alibaba Cloud, and DigitalOcean also provide various cloud services.

Cloud providers help organizations reduce costs, improve scalability, and deploy applications efficiently.


## AWS(Amazon Web Services)

Amazon Web Services (AWS) is a leading cloud computing platform developed by Amazon. It was launched in 2006 and provides cloud infrastructure that organizations can use instead of maintaining their own physical data centers. AWS operates through a large global infrastructure of data centers and regions, allowing businesses to deploy applications and store data across different geographical locations.

AWS supports organizations of different sizes, from startups to large enterprises and government organizations. It follows a pay-as-you-go pricing model, which helps users avoid large upfront investments in hardware.

### Major AWS Services

####1. Amazon EC2(Elatic Cloud Computing):
Amazon Web Services EC2 (Elastic Compute Cloud) is a cloud computing service that provides virtual
servers called instances. Instead of purchasing physical computers, users can rent computing
resources from AWS and launch servers within minutes. These servers can run applications, websites,
databases, APIs, or enterprise software.

**EC2 Instance:**
An EC2 instance is a virtual machine in AWS containing CPU, RAM, storage, operating system, and
networking capabilities. Users choose instance size depending on workload requirements.
Example
A small blog website may use a small instance with low RAM, while a video streaming platform may
require a large instance with high CPU and memory.


**AMI (Amazon Machine Image):**
AMI is a preconfigured template used to create EC2 instances. It contains the operating system,
installed software, libraries, and settings required to launch a server quickly.
Example
If a company needs 20 Ubuntu servers with Java and Docker already installed, they can create one
AMI and launch all servers from it instead of configuring each server manually.

**EBS (Elastic Block Store):**
EBS is persistent storage attached to EC2 instances. It acts like a virtual hard drive where operating
systems, files, and databases are stored.
Example
If an EC2 server is stopped accidentally, data stored in EBS remains safe and available when the
server restarts.

**EC2 Pricing Models**
A. On-Demand Instances
Users pay only for actual usage without long-term commitment.
Example
Best for testing, development, or short-term projects.

B. Reserved Instances
Instances are reserved for 1 or 3 years for lower pricing.
Example
A company running a permanent ERP system can save cost using reserved instances.

C. Spot Instances
Unused AWS resources are provided at very low prices but may stop anytime.
Example
Used for temporary workloads like video rendering or batch processing.

D. Dedicated Hosts
Physical servers are dedicated to one customer only.
Example
Banks or government organizations may use dedicated hosts for compliance requirements

### 2. IAM (Identity and Access Management)
Amazon Web Services IAM (Identity and Access Management) is an AWS security service used to
control who can access AWS resources and what actions they can perform. It helps organizations
manage authentication and authorization securely without sharing root account credentials. Using
IAM, administrators can create users, groups, roles, and policies with specific permissions.

#### Components of IAM

**IAM Users**
IAM users represent individual people or applications that need access to AWS services. Each user
can have a username, password, and access keys.
Example
A developer working on EC2 servers may get permission only to start or stop EC2 instances, but not
delete databases

**IAM Groups**
Groups are collections of IAM users having similar permissions. Instead of assigning permissions
individually, permissions are attached to groups.
Example
A company may create a “Developers” group with EC2 access and a “Finance” group with billing
access.

**IAM Roles**
IAM roles provide temporary permissions to AWS services or applications without storing credentials
permanently.
Example
An EC2 instance accessing files from an S3 bucket can use an IAM role instead of storing AWS secret
keys inside the application code.

**IAM Policies**
Policies are JSON-based permission documents that define what actions are allowed or denied on
AWS resources.
Example
A policy may allow reading files from an S3 bucket but deny deleting them

### 3. Amazon VPC

Amazon Virtual Private Cloud (Amazon VPC) is a logically isolated virtual network within AWS where you can launch and manage AWS resources. It allows you to control IP addresses, subnets, routing, and network security.
A VPC is similar to having your own private network in a traditional data center, but it is created and managed through AWS.

Main Components
1. VPC
The overall virtual network containing your AWS resources.
2. Subnet
A smaller IP range inside a VPC. Subnets can be public or private depending on their routing configuration.
3. Internet Gateway (IGW)
Connects a VPC to the Internet. A public subnet generally has a route through the Internet Gateway.
4. Route Table
Contains rules that determine where network traffic is sent. For example:
0.0.0.0/0 → Internet Gateway
0.0.0.0/0 → NAT Gateway
5. NAT Gateway
Allows resources in a private subnet to initiate outbound Internet connections without allowing unsolicited inbound Internet connections to those resources.
6. Security Group
Acts as a stateful virtual firewall for resources such as EC2 instances. It controls inbound and outbound traffic using rules based on protocols, ports, and IP addresses or other security groups.
7. Network ACL (NACL)
Acts as a stateless firewall at the subnet level. It controls inbound and outbound traffic using allow and deny rules.
8. VPC Endpoint
Allows resources in a VPC to access supported AWS services without requiring traffic to travel through the public Internet.
9. API Gateway
Amazon API Gateway is a managed service for creating and exposing APIs. It can serve as the public entry point for applications and integrate with backend resources.
10. Elastic IP
A static public IPv4 address that can be associated with certain AWS resources, such as a NAT Gateway.

**Example: User Requests an Order**
Suppose a user opens an e-commerce application and requests their order details.

                                                        User
                                                        ↓
                                                        API Gateway
                                                        ↓
                                                        Application Load Balancer
                                                        ↓
                                                        EC2 (Private Subnet)
                                                        ↓
                                                        Database (Private Subnet)

Step-by-step workflow:

- User sends request
- The user requests GET /orders/123 from the application.
- API Gateway receives it
- API Gateway acts as the public entry point and forwards the request to the backend.
- Load Balancer routes the request
- The Application Load Balancer distributes the request to a healthy EC2 instance in a private subnet.
- Security Group checks traffic
- The EC2 Security Group allows traffic from the Load Balancer but blocks unauthorized connections.
- EC2 accesses the database
- The application running on EC2 requests order information from the database in another private subnet. The database's Security Group allows traffic only from the application's Security Group.
- Response returns
- The database sends the data → EC2 → Load Balancer → API Gateway → User.

If EC2 needs an external API, its route table sends the outbound request to the NAT Gateway, which provides Internet access without exposing the EC2 instance directly to the Internet.

### 4. Amazon CloudWatch:
Amazon Web Services CloudWatch is AWS’s monitoring and observability service used to track
performance, resource utilization, logs, and application health. It collects metrics from AWS
resources and helps administrators monitor systems in real time.

#### Features of CloudWatch

**A. Metrics Monitoring**
CloudWatch monitors CPU usage, memory, disk activity, and network traffic.
Example
An administrator can track whether EC2 CPU usage exceeds safe limits.

**B. Alarms**
CloudWatch alarms trigger notifications or automated actions when thresholds are crossed.
Example
If CPU usage reaches 80%, CloudWatch can trigger Auto Scaling to launch more EC2 instances.

**C. Log Monitoring**
Applications and servers can send logs to CloudWatch for centralized analysis.
Example
Developers can analyze application errors without manually checking each server.

**D. Dashboards**
CloudWatch dashboards visually display system health and performance metrics.
Example
A DevOps team can monitor all production servers from one dashboard.

#### Advantages of CloudWatch
CloudWatch improves system reliability, simplifies monitoring, enables proactive issue detection, and
automates operational responses. It also integrates with services like Lambda, EC2, and SNS.


### 5. Amazon S3 (Simple Storage Service)
Amazon Web Services Amazon S3 (Simple Storage Service) is a highly scalable object storage service
provided by AWS for storing and retrieving data from the cloud. It is designed to store files such as
images, videos, documents, backups, logs, and application data securely from anywhere through the
internet. Data in S3 is stored inside containers called buckets, and each stored file is called an object.

#### Features of S3

**A. Object Storage** 
S3 stores data as objects instead of traditional file systems or blocks. Each object contains the file,
metadata, and a unique identifier.
Example
A company can store customer-uploaded images or videos in an S3 bucket.

**B. High Durability and Availability**
S3 automatically replicates data across multiple AWS facilities to prevent data loss.
Example
Even if one AWS data center fails, stored files remain accessible from another location.

**C. Scalability**
S3 can store unlimited amounts of data and automatically scales according to storage requirements.
Example
A video streaming platform can store millions of videos without managing storage hardware.

**D. Storage Classes**
S3 provides different storage classes like Standard, Intelligent-Tiering, Glacier, and Glacier Deep
Archive for different cost and access needs.
Example
Frequently accessed website images use S3 Standard, while old backups use Glacier for low-cost
archival storage.

**E. Security**
S3 supports encryption, bucket policies, IAM permissions, and access control lists (ACLs).
Example
A company can restrict access so only authorized employees can download confidential documents.


## Amazon S3 Storage Classes

| Storage Class                     | Best For                                   | Access Pattern | Retrieval        | Cost                             |
| --------------------------------- | ------------------------------------------ | -------------- | ---------------- | -------------------------------- |
| **S3 Standard**                   | Frequently accessed data                   | Frequent       | Immediate        | Higher storage cost              |
| **S3 Intelligent-Tiering**        | Data with changing/unknown access patterns | Changing       | Immediate        | Automatically optimizes cost     |
| **S3 Standard-IA**                | Infrequently accessed data                 | Infrequent     | Immediate        | Lower storage, retrieval charges |
| **S3 One Zone-IA**                | Infrequently accessed, reproducible data   | Infrequent     | Immediate        | Lower cost, single AZ            |
| **S3 Glacier Instant Retrieval**  | Archive data accessed occasionally         | Rare           | Milliseconds     | Low storage cost                 |
| **S3 Glacier Flexible Retrieval** | Long-term archives                         | Rare           | Minutes to hours | Very low storage cost            |
| **S3 Glacier Deep Archive**       | Long-term archival                         | Very rare      | Hours            | Lowest storage cost              |
| **S3 Express One Zone**           | High-performance workloads                 | Frequent       | Milliseconds     | Optimized for low latency        |

> 
#### Other AWS Services includes Lambda, RDS, DynamoDB, CloudFront, BeanStalk, Redshift, Cloudtrail + nearly 200 other services.


## Google Cloud Platform (GCP)

**Google Cloud Platform (GCP)** is a cloud computing platform provided by **Google**. It offers infrastructure, platforms, databases, storage, networking, security, data analytics, and AI/ML capabilities through the Internet.

GCP allows organizations to build, deploy, and scale applications without managing physical infrastructure. It uses Google's global infrastructure and follows a **pay-as-you-go** pricing model for most services.

---

## GCP Names Compared with AWS

| AWS             | GCP                                  |
| --------------- | ------------------------------------ |
| **EC2**         | **Compute Engine**                   |
| **S3**          | **Cloud Storage**                    |
| **VPC**         | **Virtual Private Cloud (VPC)**      |
| **Lambda**      | **Cloud Functions**                  |
| **ECS / EKS**   | **Google Kubernetes Engine (GKE)**   |
| **RDS**         | **Cloud SQL**                        |
| **DynamoDB**    | **Firestore**                        |
| **API Gateway** | **API Gateway**                      |
| **CloudFront**  | **Cloud CDN**                        |
| **Route 53**    | **Cloud DNS**                        |
| **CloudWatch**  | **Cloud Monitoring + Cloud Logging** |
| **IAM**         | **Cloud IAM**                        |
| **SQS**         | **Cloud Tasks**                      |
| **SNS**         | **Pub/Sub**                          |
| **Redshift**    | **BigQuery**                         |
| **EBS**         | **Persistent Disk**                  |

> **Note:** These are commonly used comparisons based on similar purposes. They are not always exact one-to-one equivalents.

---

### 5 Major GCP Services

##### 1. Compute Engine

**Compute Engine** is GCP's virtual machine service and is commonly compared with AWS EC2. It allows users to create and run virtual machines with configurable CPU, memory, storage, and operating systems.

It is useful when an application requires control over the underlying virtual machine and operating environment.

##### 2. Cloud Storage

**Cloud Storage** is GCP's object storage service, similar to Amazon S3. It is used to store files, images, videos, backups, logs, and other unstructured data.

Data is organized into **buckets** and can be accessed through APIs or other GCP services.

##### 3. Google Kubernetes Engine (GKE)

**GKE** is GCP's managed Kubernetes service. It allows organizations to deploy, manage, and scale containerized applications using Kubernetes.

Google manages much of the underlying Kubernetes infrastructure, reducing the operational effort required to run container workloads.

##### 4. BigQuery

**BigQuery** is a fully managed, serverless **data warehouse and analytics platform**. It is designed for analyzing very large datasets using SQL.

It is commonly used for business intelligence, reporting, data analytics, and processing large-scale datasets.

##### 5. Cloud SQL

**Cloud SQL** is a fully managed relational database service. It supports database engines such as **MySQL, PostgreSQL, and SQL Server**.

It handles many administrative tasks such as backups, updates, maintenance, and high availability, allowing developers to focus more on their applications.

---

## Other Important GCP Services

GCP also provides many other services, including:

* **Cloud Run** — Serverless container platform
* **Cloud Functions** — Serverless function execution
* **Cloud Pub/Sub** — Messaging and event streaming
* **Cloud IAM** — Identity and access management
* **Cloud Load Balancing** — Distributes traffic across resources
* **Cloud CDN** — Content delivery network
* **Cloud DNS** — Managed DNS service
* **Firestore** — NoSQL document database
* **Cloud Monitoring** — Infrastructure and application monitoring
* **Cloud Logging** — Log management and analysis
* **Vertex AI** — AI and machine learning platform
* **Artifact Registry** — Stores container images and software packages



