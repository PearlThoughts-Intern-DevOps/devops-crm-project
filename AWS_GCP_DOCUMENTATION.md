Task 6 — AWS \& GCP Cloud Platforms

1\. Introduction



Cloud computing provides on-demand access to computing resources such as servers, storage, databases, networking, analytics, and application services over the internet.



Instead of purchasing and maintaining physical infrastructure, organizations can provision resources from cloud providers according to their requirements. Cloud platforms also provide scalability, high availability, security controls, monitoring, automation, and pay-as-you-use pricing models.



The two major cloud platforms explored in this task are:



Amazon Web Services (AWS)

Google Cloud Platform (GCP)



Both platforms provide similar categories of services, but their service names, architecture, management tools, and specific features differ.



2\. Amazon Web Services (AWS)

2.1 What is AWS?



Amazon Web Services is a cloud platform that provides a large collection of infrastructure and managed services.



AWS provides services for:



Compute

Storage

Databases

Networking

Security

Data engineering

Analytics

Serverless applications

Containers

Machine learning

Monitoring

DevOps and CI/CD



Cloud computing allows resources such as compute, storage, and databases to be provisioned on demand instead of requiring organizations to maintain physical hardware.



3\. Important AWS Services

3.1 Amazon EC2



Amazon Elastic Compute Cloud (EC2) provides scalable virtual servers in AWS.



An EC2 instance is essentially a virtual machine that can be configured with different combinations of:



CPU

Memory

Storage

Networking

Operating system



EC2 is useful when an application requires control over the operating system and server environment.



Example



A company can deploy a web application on an EC2 instance instead of maintaining a physical server.



3.2 Amazon S3



Amazon Simple Storage Service (S3) is AWS object storage.



S3 stores data as:



Bucket

&#x20;  |

&#x20;  ├── Object

&#x20;  ├── Object

&#x20;  └── Object



Common uses include:



Data lakes

Backups

Application files

Logs

Static websites

ETL input/output

Large datasets



S3 stores objects inside buckets and provides configurable access controls such as IAM policies and bucket policies.



My project usage



In my CMS payment-data project, S3 is used as the storage layer:



CMS Dataset

&#x20;    |

&#x20;    v

S3 Raw Zone

&#x20;    |

&#x20;    v

Glue Transformation

&#x20;    |

&#x20;    v

S3 Enriched Zone

4\. AWS IAM



AWS Identity and Access Management (IAM) controls authentication and authorization in AWS.



IAM can manage:



Users

Groups

Roles

Policies

Permissions

Access keys



For example, a user may have permission to upload objects to S3 but not delete an EC2 instance.



AWS recommends controlling access according to the principle of least privilege — users and workloads should receive only the permissions required for their responsibilities.



Example

GitHub Actions

&#x20;     |

&#x20;     v

AWS IAM

&#x20;     |

&#x20;     +---- S3 permissions

&#x20;     |

&#x20;     +---- CloudFormation permissions

&#x20;     |

&#x20;     +---- Glue permissions

5\. Amazon VPC



Amazon Virtual Private Cloud (VPC) provides a logically isolated virtual network in AWS.



A VPC can contain:



Subnets

Route tables

Internet gateways

NAT gateways

Security groups

Network ACLs



Resources such as EC2 instances can be launched inside a VPC.



A simplified architecture is:



AWS Region

&#x20;   |

&#x20;   +---- VPC

&#x20;          |

&#x20;          +---- Public Subnet

&#x20;          |

&#x20;          +---- Private Subnet

&#x20;          |

&#x20;          +---- Route Table

&#x20;          |

&#x20;          +---- Internet Gateway

6\. AWS Lambda



AWS Lambda is a serverless compute service.



Instead of maintaining a server, developers deploy a function and AWS manages the underlying infrastructure.



Lambda is useful for:



Event-driven applications

API backends

Automation

File processing

Scheduled jobs

Lightweight data processing



Lambda automatically scales based on workload and uses a pay-per-use model.



Example

S3 File Upload

&#x20;     |

&#x20;     v

AWS Lambda

&#x20;     |

&#x20;     v

Process File

7\. AWS Glue



AWS Glue is a serverless data integration and ETL service.



It can be used to:



Discover data

Extract data

Transform data

Load data

Build data pipelines

Maintain metadata

Run ETL jobs



AWS Glue includes the Glue Data Catalog, which stores metadata about data sources and tables.



CMS project example



My CMS payment-data pipeline uses the following architecture:



CMS Open Payments Data

&#x20;         |

&#x20;         v

&#x20;  Glue Ingestion Job

&#x20;         |

&#x20;         v

&#x20;   S3 Raw Zone

&#x20;         |

&#x20;         v

&#x20;  Glue Transform Job

&#x20;         |

&#x20;         v

&#x20; S3 Enriched Zone

&#x20;         |

&#x20;         v

&#x20;   Glue Crawler

&#x20;         |

&#x20;         v

&#x20;  Glue Data Catalog



This helped me understand how cloud services can be combined instead of using each service independently.



8\. AWS Step Functions



AWS Step Functions is used to orchestrate workflows between AWS services.



For example, instead of manually executing:



Glue Job 1

&#x20;  ↓

Glue Job 2

&#x20;  ↓

Crawler



Step Functions can automate the sequence:



Step Function

&#x20;     |

&#x20;     v

Ingestion Job

&#x20;     |

&#x20;     v

Transform Job

&#x20;     |

&#x20;     v

Crawler



This makes the pipeline repeatable and easier to monitor.



9\. AWS CloudFormation



AWS CloudFormation is an Infrastructure as Code (IaC) service.



Instead of manually creating resources through the AWS Console, infrastructure can be described in YAML or JSON.



For example:



Resources:

&#x20; MyBucket:

&#x20;   Type: AWS::S3::Bucket



CloudFormation can then create and manage the infrastructure described in the template.



My project



I used CloudFormation to define resources such as:



IAM roles

Glue jobs

Glue database

Glue crawler

Step Functions state machine



This makes infrastructure reproducible and suitable for CI/CD.



10\. AWS CloudWatch



Amazon CloudWatch is used for monitoring AWS resources and applications.



It can provide:



Metrics

Logs

Alarms

Dashboards

Events



For example, CloudWatch can be used to monitor Lambda execution or application logs.



11\. AWS CloudTrail



AWS CloudTrail records API activity in an AWS account.



It can help answer questions such as:



Who performed an action?

What action was performed?

When was it performed?

Which resource was affected?



CloudTrail is useful for auditing and security investigations.



12\. Google Cloud Platform (GCP)

12.1 What is GCP?



Google Cloud Platform is Google's cloud computing platform.



GCP provides services for:



Compute

Storage

Networking

Databases

Data analytics

Containers

Serverless applications

AI/ML

Security

DevOps



Google Cloud organizes resources around concepts such as organizations, folders, projects, and resources.



13\. Important GCP Services

13.1 Compute Engine



Google Compute Engine provides virtual machines and is comparable to Amazon EC2.



It provides self-managed virtual machine instances with configurable compute, memory, networking, operating systems, and storage.



AWS vs GCP

AWS	GCP

EC2	Compute Engine

Virtual Machine	Virtual Machine

AMI	Machine Image

Security Group	VPC Firewall Rules

14\. Google Cloud Storage



Cloud Storage is Google's object storage service.



It stores objects inside buckets.



Architecture:



Bucket

&#x20;  |

&#x20;  ├── Object

&#x20;  ├── Object

&#x20;  └── Object



Cloud Storage is commonly used for:



Data lakes

Backups

Archives

Application data

Analytics datasets



Cloud Storage buckets are associated with Google Cloud projects.



AWS vs GCP

AWS	GCP

Amazon S3	Cloud Storage

S3 Bucket	Cloud Storage Bucket

S3 Object	Cloud Storage Object

15\. Google Cloud IAM



Google Cloud IAM controls access to Google Cloud resources.



IAM works using:



Principal

&#x20;   |

&#x20;   v

Role

&#x20;   |

&#x20;   v

Permissions

&#x20;   |

&#x20;   v

Resource



Google Cloud provides:



Basic roles

Predefined roles

Custom roles



Predefined roles provide more granular permissions for specific services.



AWS vs GCP

AWS	GCP

IAM Policy	IAM Role/Permissions

IAM User	Google Identity

IAM Role	Service Account / IAM Role

Managed Policy	Predefined Role

16\. Google Cloud VPC



Google Cloud VPC provides networking for:



Compute Engine

GKE

Serverless workloads

Other Google Cloud services



A major difference is that Google Cloud VPC networks are global resources, while their subnets are regional.



AWS vs GCP

AWS	GCP

VPC	VPC

Subnet	Subnet

Route Table	Routes

Security Group	Firewall Rules

Internet Gateway	Cloud NAT / Internet connectivity mechanisms

17\. Google Kubernetes Engine (GKE)



Google Kubernetes Engine (GKE) is Google's managed Kubernetes service.



It allows organizations to deploy and operate containerized applications using Kubernetes.



GKE supports:



Container orchestration

Scaling

Networking

Workload management

Kubernetes deployments

Automated cluster management



GKE provides managed Kubernetes capabilities and supports both Autopilot and Standard modes.



AWS equivalent

AWS EKS

&#x20;  ≈

GCP GKE

18\. Google Cloud Run



Cloud Run is a fully managed platform for running applications and containers without managing servers or Kubernetes clusters.



It supports:



Web applications

APIs

Background jobs

Event-driven workloads

Containerized applications



Cloud Run can automatically scale container instances based on workload.



AWS equivalent



Cloud Run can be compared conceptually with services such as:



Google Cloud Run

&#x20;      ≈

AWS App Runner / Lambda



The exact capabilities and deployment models are different, so this is a conceptual comparison rather than a one-to-one mapping.



19\. Google BigQuery



BigQuery is Google's fully managed, serverless data warehouse and analytics platform.



It can be used for:



SQL analytics

Large datasets

Data warehousing

Business intelligence

Data engineering

Machine learning workloads



BigQuery separates storage and compute, so users don't have to provision traditional database servers for analytical workloads.



AWS equivalent

Google BigQuery

&#x20;      ≈

Amazon Redshift



Both support analytical data warehousing, although their architecture and pricing models differ.



20\. AWS vs GCP — Service Comparison

Category	AWS	GCP

Cloud platform	AWS	Google Cloud

Virtual machines	EC2	Compute Engine

Object storage	S3	Cloud Storage

Virtual network	VPC	VPC

Serverless compute	Lambda	Cloud Run / Cloud Functions

Kubernetes	EKS	GKE

Data warehouse	Redshift	BigQuery

ETL / data integration	Glue	Dataflow / Dataproc

IAM	AWS IAM	Cloud IAM

Infrastructure as Code	CloudFormation	Cloud Deployment Manager / Terraform

Monitoring	CloudWatch	Cloud Monitoring

Audit logging	CloudTrail	Cloud Audit Logs

Container registry	ECR	Artifact Registry

DNS	Route 53	Cloud DNS

Messaging	SQS / SNS	Pub/Sub

21\. AWS and GCP Networking Comparison



A simplified comparison is:



AWS                              GCP



Region                           Region

&#x20; |                                |

&#x20; VPC                              VPC

&#x20; |                                |

&#x20; +-- Subnet                       +-- Subnet

&#x20; |                                |

&#x20; +-- Route Table                  +-- Routes

&#x20; |

&#x20; +-- Internet Gateway             +-- Cloud NAT / Internet

&#x20; |

&#x20; +-- Security Groups              +-- Firewall Rules



One important difference is that an AWS VPC is associated with a Region, while Google Cloud VPC networks are global and contain regional subnets.



22\. AWS vs GCP IAM



Both platforms use identity-based authorization, but the terminology differs.



AWS

User / Role

&#x20;    |

&#x20;    v

IAM Policy

&#x20;    |

&#x20;    v

Permissions

GCP

Principal

&#x20;    |

&#x20;    v

IAM Role

&#x20;    |

&#x20;    v

Permissions



Google Cloud roles are collections of permissions and can be basic, predefined, or custom.



The common principle is:



Give identities only the permissions required to perform their tasks.



23\. Shared Responsibility Model



Cloud security is not completely handled by the cloud provider.



It follows a shared responsibility model.



AWS



AWS is responsible for the security of the cloud, including underlying infrastructure.



Customers are responsible for security in the cloud, including things such as data, application configuration, IAM permissions, and, depending on the service, operating system and network configuration.



GCP



Google Cloud follows a similar model: Google secures the underlying cloud infrastructure while customers remain responsible for securing their data, applications, configurations, and access.



24\. DevOps and CI/CD



Both AWS and GCP can be integrated with GitHub Actions.



A typical deployment flow is:



Developer

&#x20;   |

&#x20;   v

GitHub

&#x20;   |

&#x20;   v

GitHub Actions

&#x20;   |

&#x20;   +-------------------+

&#x20;   |                   |

&#x20;   v                   v

&#x20;  AWS                 GCP

&#x20;   |                   |

&#x20;   v                   v

CloudFormation       Terraform /

&#x20;   |                Cloud Deploy

&#x20;   |                   |

&#x20;   v                   v

AWS Resources        GCP Resources



For authentication, modern CI/CD systems should preferably use short-lived, federated credentials rather than storing long-lived cloud access keys.



25\. What I Learned from AWS



Through my practical work with AWS, I learned how different cloud services can be combined to build an end-to-end data pipeline.



My CMS payment-data project helped me understand:



S3 can be used as a raw and processed data storage layer.

AWS Glue can perform serverless ETL.

Glue Data Catalog can maintain metadata.

Glue Crawlers can discover schemas from stored data.

Step Functions can orchestrate multiple data-processing steps.

IAM controls access between users, GitHub Actions, and AWS services.

CloudFormation can define infrastructure as code.

GitHub Actions can automate deployment.

Cloud services must be given appropriate permissions through IAM roles.

Troubleshooting cloud deployments requires checking both application configuration and cloud-level permissions.

26\. What I Learned from GCP



While exploring GCP, I understood the equivalent services and concepts:



Compute Engine provides virtual machines.

Cloud Storage provides object storage.

VPC provides cloud networking.

Cloud IAM controls access to resources.

GKE provides managed Kubernetes.

Cloud Run provides serverless container execution.

BigQuery provides serverless analytical data warehousing.

Google Cloud organizes resources using projects and higher-level organization structures.

IAM uses roles containing sets of permissions.

GCP provides services that can be combined to create scalable data and application architectures.

27\. Key Differences I Understood



The two platforms provide many equivalent capabilities, but the terminology and implementation differ.



For example:



AWS                         GCP



EC2                         Compute Engine

S3                          Cloud Storage

EKS                         GKE

Lambda                      Cloud Run / Cloud Functions

Redshift                    BigQuery

IAM                         Cloud IAM

CloudWatch                  Cloud Monitoring

CloudTrail                  Cloud Audit Logs

VPC                         VPC



The services are not always exact one-to-one equivalents, but the comparison helps understand the common cloud architecture concepts.



28\. Why Cloud Platforms Are Important for DevOps



Cloud platforms are important for DevOps because they enable:



Automation



Infrastructure and deployments can be automated using:



GitHub Actions

CloudFormation

Terraform

Cloud Deploy

CLI/API tools

Scalability



Applications can scale according to demand rather than requiring physical hardware upgrades.



Infrastructure as Code



Infrastructure can be version-controlled alongside application code.



Monitoring



Cloud platforms provide centralized logging, metrics, alerts, and auditing.



Security



IAM and other security services allow organizations to control access to resources.



Faster deployment



CI/CD pipelines can automatically build, test, and deploy applications.



29\. My Understanding



The main thing I learned from exploring AWS and GCP is that cloud computing is not only about running servers.



A complete cloud architecture combines several services:



&#x20;                   Cloud Platform

&#x20;                        |

&#x20;      +-----------------+----------------+

&#x20;      |                 |                |

&#x20;   Compute           Storage          Network

&#x20;      |                 |                |

&#x20;      +-----------------+----------------+

&#x20;                        |

&#x20;                   IAM / Security

&#x20;                        |

&#x20;                   Monitoring

&#x20;                        |

&#x20;                   Automation

&#x20;                        |

&#x20;                      CI/CD



The biggest advantage is being able to combine managed services to build scalable systems without having to manage all the underlying physical infrastructure.



30\. Conclusion



AWS and GCP are both comprehensive cloud platforms that provide services for compute, storage, networking, databases, analytics, security, containers, serverless applications, and DevOps.



My practical experience with AWS, especially the CMS payment-data pipeline, helped me understand how cloud services work together in a real data engineering workflow.



The comparison with GCP helped me understand that although service names and implementations differ, the fundamental cloud concepts remain similar:



Compute

Storage

Networking

Identity and access management

Data processing

Monitoring

Automation

Scalability

Security



Learning both platforms provides a broader understanding of cloud architecture and makes it easier to adapt to different cloud environments.

