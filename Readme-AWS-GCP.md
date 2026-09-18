# AWS and GCP Service Comparison

## Objective

The purpose of this task is to explore **Amazon Web Services (AWS)** and
**Google Cloud Platform (GCP)**, understand their commonly used cloud
services, and compare how both platforms provide compute, storage,
networking, security, monitoring, load balancing, and database services.

---

## AWS and GCP Service Mapping

| Requirement | AWS service | Similar GCP service |
| --- | --- | --- |
| Virtual machine / compute | Amazon EC2 | Compute Engine |
| Identity and access | AWS IAM | Cloud IAM |
| Object storage | Amazon S3 | Cloud Storage |
| DNS | Amazon Route 53 | Cloud DNS |
| Monitoring and logging | Amazon CloudWatch | Cloud Monitoring + Cloud Logging |
| Virtual networking | Amazon VPC | Virtual Private Cloud (VPC) |
| Block storage | Amazon EBS | Persistent Disk / Hyperdisk |
| Load balancing | Elastic Load Balancing | Cloud Load Balancing |
| Managed relational database | Amazon RDS | Cloud SQL |

---

## 1. Compute: Amazon EC2 vs GCP Compute Engine

### Amazon EC2

**EC2 (Elastic Compute Cloud)** is AWS's virtual machine service. It
allows users to create virtual servers called **instances** without
purchasing physical hardware.

With EC2, we can choose:

-   Operating system such as Linux or Windows
-   CPU and memory through an instance type
-   Storage
-   VPC and subnet
-   Security Groups
-   Public or private IP addresses
-   IAM roles

Common EC2 instance categories include:

-   **General Purpose** -- balanced compute and memory.
-   **Compute Optimized** -- suitable for CPU-intensive applications.
-   **Memory Optimized** -- suitable for memory-intensive workloads.
-   **Storage Optimized** -- designed for workloads requiring high
    local-storage performance.
-   **Accelerated Computing** -- uses hardware accelerators such as
    GPUs.

Example:

``` text
Internet
   |
Load Balancer
   |
EC2 Instance
   |
Application
```

### GCP Compute Engine

**Compute Engine** is the comparable GCP service. It provides
configurable Linux and Windows virtual machines.

Both EC2 and Compute Engine allow users to select machine resources,
disks, networking, operating systems, and security configuration.

---

## 2. Identity: AWS IAM vs GCP Cloud IAM

### AWS IAM

**IAM (Identity and Access Management)** controls authentication and
authorization in AWS.

Important concepts:

-   **Users** -- identities for people or applications.
-   **Groups** -- collections of IAM users.
-   **Roles** -- identities with permissions that can be assumed
    temporarily by users, applications, or AWS services.
-   **Policies** -- JSON documents defining allowed or denied actions.

Example:

``` text
EC2 Instance
     |
  IAM Role
     |
     v
 S3 Bucket
```

An EC2 instance can use an IAM role to access S3 without storing
long-term access keys inside the application.

A key security practice is the **principle of least privilege**: grant
only the permissions required to perform a task.

### GCP Cloud IAM

GCP IAM also controls access to cloud resources.

Its main concepts include:

-   Principals
-   Roles
-   Permissions
-   Resources
-   Service accounts

GCP commonly uses **service accounts** to provide identities to
applications and workloads.

---

## 3. Object Storage: Amazon S3 vs GCP Cloud Storage

### Amazon S3

**S3 (Simple Storage Service)** is AWS object storage. Files are stored
as **objects** inside **buckets**.

Example:

``` text
S3 Bucket
├── application-backup.zip
├── build-artifact.tar.gz
├── image.png
└── logs/
```

Common DevOps uses include:

-   Application backups
-   CI/CD build artifacts
-   Static files
-   Log archives
-   Terraform state
-   Long-term data archives

#### Major S3 Storage Classes

-   **S3 Standard** -- frequently accessed data.
-   **S3 Intelligent-Tiering** -- automatically optimizes storage costs
    as access patterns change.
-   **S3 Standard-IA** -- infrequently accessed data requiring rapid
    access when needed.
-   **S3 One Zone-IA** -- infrequently accessed data stored in one
    Availability Zone.
-   **S3 Glacier Instant Retrieval** -- archive data requiring fast
    retrieval.
-   **S3 Glacier Flexible Retrieval** -- low-cost archive storage with
    slower retrieval options.
-   **S3 Glacier Deep Archive** -- very low-cost long-term archival
    storage.

### GCP Cloud Storage

**Cloud Storage** is GCP's object storage service and also organizes
objects inside buckets.

Main storage classes include:

-   **Standard** -- frequently accessed data.
-   **Nearline** -- data generally accessed less than once a month.
-   **Coldline** -- infrequently accessed data.
-   **Archive** -- long-term archival data.

S3 and Cloud Storage solve similar object-storage requirements, although
their pricing rules and storage-class details are not identical.

---

## 4. DNS: Amazon Route 53 vs GCP Cloud DNS

### Amazon Route 53

**Route 53** is AWS's managed Domain Name System (DNS) service. DNS
translates human-readable domain names into information used to route
requests to applications.

Example:

``` text
www.example.com
       |
    Route 53
       |
Load Balancer
       |
Application
```

Route 53 supports common DNS records such as:

-   A
-   AAAA
-   CNAME
-   MX
-   TXT

It also provides routing policies including simple, weighted,
latency-based, failover, geolocation, and multivalue routing.

### GCP Cloud DNS

**Cloud DNS** is Google's managed DNS service. It hosts DNS zones and
records and can be used to direct domains toward GCP resources.

---

## 5. Monitoring: Amazon CloudWatch vs GCP Cloud Monitoring

### Amazon CloudWatch

**Amazon CloudWatch** provides monitoring and observability for AWS
resources and applications.

It can work with:

-   Metrics
-   Logs
-   Alarms
-   Dashboards
-   Events and automated actions

Example:

``` text
EC2
 |
CloudWatch Metrics / Logs
 |
CloudWatch Alarm
 |
Notification or Automated Action
```

For example, a CloudWatch alarm can react when CPU utilization crosses a
configured threshold.

### GCP Cloud Monitoring and Cloud Logging

GCP provides:

-   **Cloud Monitoring** for metrics, dashboards, uptime monitoring, and
    alerting.
-   **Cloud Logging** for collecting, storing, searching, and analyzing
    logs.

Therefore:

``` text
AWS CloudWatch Metrics  ≈ GCP Cloud Monitoring
AWS CloudWatch Logs     ≈ GCP Cloud Logging
AWS CloudWatch Alarms   ≈ GCP Alerting
```

---

## 6. Networking: AWS VPC and Subnets vs GCP VPC

### AWS VPC

**VPC (Virtual Private Cloud)** is an isolated virtual network in AWS.

A VPC has an IP address range and can be divided into smaller networks
called **subnets**.

``` text
AWS VPC
|
├── Public Subnet
|      └── Internet-facing Load Balancer
|
└── Private Subnet
       ├── EC2 Application Server
       └── Database
```

#### Public Subnet

A public subnet has a route to an **Internet Gateway**. Resources can be
internet-facing when they also have the required public addressing and
security configuration.

Typical resources:

-   Internet-facing load balancers
-   Public web servers
-   Bastion hosts

#### Private Subnet

A private subnet does not have a direct route to an Internet Gateway.

Typical resources:

-   Application servers
-   Databases
-   Internal services

Private resources can use a **NAT Gateway** for outbound internet
connectivity while remaining inaccessible through unsolicited inbound
connections via that NAT.

### GCP VPC

GCP also provides **Virtual Private Cloud (VPC)** networking.

An important difference is:

-   **AWS VPCs are regional.**
-   **GCP VPC networks are global resources, while GCP subnets are
    regional.**

Example:

``` text
Global GCP VPC
|
├── Region A
|   └── Subnet A
|
└── Region B
    └── Subnet B
```

GCP provides **Cloud NAT** for controlled outbound connectivity from
workloads without external IP addresses.

---

## 7. Block Storage: Amazon EBS vs GCP Persistent Disk / Hyperdisk

### Amazon EBS

**EBS (Elastic Block Store)** provides persistent block storage for EC2
workloads.

It behaves similarly to a virtual disk attached to a server.

``` text
EC2 Instance
     |
 EBS Volume
     |
Application Data
```

Major EBS volume types include:

-   **gp3 / gp2** -- General Purpose SSD.
-   **io2** -- Provisioned IOPS SSD for demanding workloads.
-   **st1** -- Throughput Optimized HDD.
-   **sc1** -- Cold HDD.

EBS also supports **snapshots**, which are commonly used for backup and
recovery.

### GCP Persistent Disk and Hyperdisk

GCP provides block-storage products such as **Persistent Disk** and
**Hyperdisk** for Compute Engine workloads.

Conceptually:

``` text
AWS: EC2 + EBS
GCP: Compute Engine + Persistent Disk / Hyperdisk
```

Disk prices depend on the disk type, capacity, region, performance
settings, and other usage. A single fixed price should therefore not be
treated as universal.

---

## 8. Load Balancing: AWS ELB vs GCP Cloud Load Balancing

A load balancer distributes incoming requests among multiple backend
servers.

``` text
                 ┌── Server 1
Users ──> LB ────┤
                 └── Server 2
```

This improves application availability and scalability.

### AWS Elastic Load Balancing

#### Application Load Balancer (ALB)

-   Operates at Layer 7.
-   Designed for HTTP and HTTPS applications.
-   Supports host-based and path-based routing.

Example:

``` text
/api/*    -> API Servers
/images/* -> Image Servers
```

#### Network Load Balancer (NLB)

-   Operates primarily at Layer 4.
-   Designed for high-performance TCP, UDP, and TLS workloads.

#### Gateway Load Balancer (GWLB)

-   Designed for deploying and scaling virtual network appliances such
    as firewalls and traffic-inspection systems.

### GCP Cloud Load Balancing

GCP provides **Cloud Load Balancing** with different products for
application and network traffic.

High-level comparison:

``` text
AWS Application Load Balancer ≈ GCP Application Load Balancer
AWS Network Load Balancer     ≈ GCP Network Load Balancer
```

---

## 9. Database: Amazon RDS vs GCP Cloud SQL

### Amazon RDS

**RDS (Relational Database Service)** is AWS's managed relational
database service.

Supported database engines include:

-   MySQL
-   PostgreSQL
-   MariaDB
-   Oracle Database
-   Microsoft SQL Server
-   Amazon Aurora

AWS manages much of the underlying database administration, including
infrastructure provisioning and features for backups, patching,
monitoring, recovery, and high availability.

Example:

``` text
Internet
   |
Load Balancer
   |
EC2 Application
   |
RDS Database
```

### GCP Cloud SQL

**Cloud SQL** is GCP's managed relational database service.

It supports:

-   MySQL
-   PostgreSQL
-   SQL Server

Cloud SQL and RDS serve similar managed relational database use cases,
although their supported engines and platform-specific capabilities
differ.

---

## AWS vs GCP Cost and Platform Differences

The following points were also studied as part of the AWS/GCP
comparison.

### Free Programs

#### AWS

AWS's current Free Tier program for new customers provides **\$100 in
credits at sign-up, with the ability to earn up to another \$100**, and
its Free account plan can be used for **up to six months or until
credits are exhausted**, whichever occurs first. AWS also provides
monthly free usage for selected services.

#### GCP

Google Cloud currently provides new customers with a **\$300 Welcome
credit for 90 days**. GCP also has a Free Tier containing selected
products with monthly usage limits.

> Note: Free programs and pricing change over time, so official pricing
> pages should be checked before making a cost decision.

### Storage Pricing Observation

During the comparison, EBS and GCP disk pricing were reviewed. Both
platforms charge according to factors such as disk type, provisioned
capacity, region, and performance. For example, AWS's official EBS
pricing documentation gives a gp3 example using a region price of
**\$0.08 per GB-month**. Google Cloud's official disk pricing gives a US
example where a **200 GB Standard Persistent Disk costs \$8/month**,
equivalent to \$0.04 per GB-month in that example.

These examples should **not** be interpreted as proof that one provider
is always cheaper. The final cost depends on the exact region, disk
type, IOPS/throughput, network traffic, discounts, and workload.

### VPC Difference

One of the clearest networking differences is:

``` text
AWS VPC -> Regional
GCP VPC -> Global, with regional subnets
```

### Which Platform Is More Widely Used?

AWS has historically held a larger share of the cloud infrastructure
market than Google Cloud. This makes AWS especially common across a wide
variety of organizations and cloud/DevOps environments. GCP is also a
major cloud provider and is particularly strong in areas such as data
analytics, Kubernetes, and Google's global network.

The correct provider should be selected based on workload requirements,
team skills, required services, architecture, region availability, and
total cost rather than market share alone.

---

## Example AWS Architecture

``` text
Users
  |
Route 53
  |
---------------- AWS VPC ----------------
  |
Public subnets in at least two Availability Zones
  |
Internet-facing Application Load Balancer
  |
Private application subnets
  ├── EC2 Instance 1 ── EBS
  └── EC2 Instance 2 ── EBS
              |
Private database subnets
              |
          RDS database

IAM        -> Access control
S3         -> Objects, backups and artifacts
CloudWatch -> Metrics, logs and alarms
```

## Similar GCP Architecture

``` text
Users
  |
Cloud DNS
  |
Cloud Load Balancing
  |
---------------- GCP VPC ----------------
  |
Regional subnets
  |
  ├── Compute Engine VM ── Persistent Disk
  └── Compute Engine VM ── Persistent Disk
              |
           Cloud SQL

Cloud IAM                  -> Access control
Cloud Storage              -> Objects, backups and artifacts
Cloud Monitoring + Logging -> Metrics, logs and alerts
```

GCP subnets are not inherently public or private. External IP addresses,
routes, firewall rules, and Cloud NAT determine how workloads communicate
with the internet.

---

## Key Learning

After exploring AWS and GCP, I learned that both platforms solve similar
cloud infrastructure problems but use different service names and
architectures in some areas.

The most important mappings I learned are:

``` text
EC2             <-> Compute Engine
IAM             <-> Cloud IAM
S3              <-> Cloud Storage
Route 53        <-> Cloud DNS
CloudWatch      <-> Cloud Monitoring / Logging
VPC             <-> VPC
EBS             <-> Persistent Disk / Hyperdisk
AWS ELB         <-> Cloud Load Balancing
RDS             <-> Cloud SQL
```

AWS and GCP both provide scalable, pay-as-you-go infrastructure. AWS has
a very broad service ecosystem and widespread adoption, while GCP
provides strong integration with Google's infrastructure, data, and
cloud-native technologies. Understanding the equivalent services makes
it easier to transfer cloud and DevOps concepts between the two
platforms.
