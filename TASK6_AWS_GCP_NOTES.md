# Task 6: AWS & GCP — What I Learned

## 1. Overview of Cloud Computing, and its importance

Cloud platforms let you provision compute, storage, networking, and
managed services on demand instead of buying and racking physical
servers. For a DevOps engineer, this means infrastructure itself becomes
something you can version, automate, and tear down/recreate — the same
mindset as the CI/CD and containerization work from earlier tasks, just
applied to the underlying infrastructure rather than just the
application.

AWS (Amazon Web Services) and GCP (Google Cloud Platform) are two of the
three dominant public cloud providers (the third being Microsoft Azure).
Both offer largely overlapping categories of services — compute, storage,
networking, databases, identity, monitoring — but differ in naming,
default tooling, and areas of particular strength.

## 2. AWS Overview

AWS is the oldest and largest public cloud provider by market share and
service catalog breadth. Core services relevant to a DevOps role:

| Category | Service | What it does |
|---|---|---|
| Compute | **EC2** (Elastic Compute Cloud) | Virtual machines — the core building block for running any workload |
| Compute | **Lambda** | Serverless functions — run code without managing a server, billed per invocation |
| Containers | **ECS** / **EKS** | Container orchestration — ECS is AWS's own scheduler, EKS is managed Kubernetes |
| Storage | **S3** (Simple Storage Service) | Object storage — files, backups, static assets, data lake storage |
| Storage | **EBS** | Block storage volumes attached to EC2 instances (like a virtual hard disk) |
| Database | **RDS** | Managed relational databases (Postgres, MySQL, etc.) |
| Database | **DynamoDB** | Managed NoSQL key-value/document database |
| Networking | **VPC** | Virtual private network — isolated network environment for your resources |
| Networking | **Route 53** | DNS service |
| Networking | **CloudFront** | CDN for caching content close to users globally |
| Identity | **IAM** | Identity and Access Management — controls who/what can do what, on which resources |
| Monitoring | **CloudWatch** | Metrics, logs, and alarms across AWS services |
| Infrastructure as Code | **CloudFormation** | AWS's native IaC tool for declaring infrastructure as YAML/JSON templates |
| CI/CD | **CodePipeline / CodeBuild** | AWS's own CI/CD tooling (an alternative to GitHub Actions, which we've used throughout this internship) |

## 3. GCP Overview

GCP is built on the same infrastructure Google uses internally, and
tends to lead in areas like Kubernetes (Google created Kubernetes) and
data analytics.

| Category | Service | What it does |
|---|---|---|
| Compute | **Compute Engine** | Virtual machines, GCP's equivalent of EC2 |
| Compute | **Cloud Functions** | Serverless functions, equivalent of Lambda |
| Containers | **GKE** (Google Kubernetes Engine) | Managed Kubernetes — widely considered the most mature managed Kubernetes offering, since Google originated Kubernetes |
| Storage | **Cloud Storage** | Object storage, equivalent of S3 |
| Storage | **Persistent Disk** | Block storage for VMs, equivalent of EBS |
| Database | **Cloud SQL** | Managed relational databases, equivalent of RDS |
| Database | **Firestore** | Managed NoSQL document database |
| Database | **BigQuery** | Serverless data warehouse for large-scale analytics — a genuine GCP strength with no direct 1:1 AWS equivalent at the same simplicity |
| Networking | **VPC** | Same concept as AWS, though GCP's VPC is global by default (a notable design difference — AWS VPCs are region-scoped) |
| Networking | **Cloud DNS** | DNS service, equivalent of Route 53 |
| Networking | **Cloud CDN** | CDN, equivalent of CloudFront |
| Identity | **IAM** | Same concept as AWS, controls access to resources |
| Monitoring | **Cloud Monitoring / Cloud Logging** | Equivalent of CloudWatch |
| Infrastructure as Code | **Deployment Manager** (largely superseded by Terraform in practice) | GCP's native IaC option |
| CI/CD | **Cloud Build** | GCP's own CI/CD tooling |

## 4. Key differences worth knowing

- **VPC scope**: AWS VPCs are regional; GCP VPCs are global by default,
  meaning subnets in different regions can belong to the same VPC
  without extra peering.
- **Kubernetes maturity**: GKE is generally regarded as the most
  polished managed Kubernetes offering, unsurprising given Google
  originated Kubernetes internally (as Borg) before open-sourcing it.
- **Market share and ecosystem**: AWS has the largest service catalog
  and the most enterprise adoption/third-party tooling support; GCP's
  catalog is narrower but deeply integrated with data/analytics (BigQuery)
  and machine learning tooling (Vertex AI).
- **IAM philosophy**: both use role-based access control, but AWS IAM
  policies are typically attached to users/roles/resources individually,
  while GCP IAM leans more on a project-hierarchy model (Organization →
  Folder → Project) with roles inherited down that hierarchy.
- **Pricing model**: both are pay-as-you-go with per-second/per-minute
  billing on compute, though exact discount structures (Reserved
  Instances on AWS vs Committed Use Discounts on GCP) differ.

## 5. Hands-on practice

Explored both platforms using the sandboxed practice environments shared
by the team:
- [KodeCloud Playgrounds](https://kodekloud.com/playgrounds) — cloud and
  DevOps playgrounds across AWS, Azure, and GCP without needing a real
  cloud account
- [Killercoda Playgrounds](https://killercoda.com/playgrounds) —
  additional Kubernetes/cloud-native environments (Ubuntu, Kubernetes,
  CKS/CKA/CKAD exam-aligned environments, Theia IDE)

*(Fill in specifics here on what you actually tried in these
playgrounds — e.g., launched an EC2 instance and connected via SSH,
created an S3 bucket and uploaded a file, explored a GCP Compute Engine
VM, tried a Kubernetes playground, etc. This section should reflect your
own hands-on exploration, not just reading about the services.)*

## 6. What I learned

- Cloud platforms formalize the same principles from earlier tasks
  (Docker, CI/CD) at the infrastructure layer — everything is API-driven
  and can be automated/versioned rather than manually clicked together.
- AWS and GCP overlap heavily in service *categories* but differ in
  naming, defaults (like VPC scope), and areas of particular depth
  (GCP's data/Kubernetes strength vs AWS's breadth and ecosystem size).
- IAM is a first-class concern on both platforms, not an afterthought —
  understanding least-privilege access control is as important as
  knowing the compute/storage services themselves.
- This maps directly onto real DevOps work: choosing a cloud provider
  affects which managed services, IaC tools, and CI/CD integrations make
  sense for a given project.