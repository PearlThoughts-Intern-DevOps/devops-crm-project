# GCP (Google Cloud Platform) - What I Learned

**Name:** Vikash Yadav
**Task:** 6 - Cloud Exploration (GCP)
**Date:** 01 September 2026

## First impressions

After going through AWS, GCP felt noticeably less overwhelming - not because it does less, but because it seems to push you toward fewer, more opinionated choices instead of giving you 5 different ways to do the same thing. GCP uses the same **Region/Zone** structure as AWS (region = geographic area, zone = a specific data center inside it), so that part transferred straight over from what I'd already learned.

A big thing that stood out immediately: Google basically invented Kubernetes internally (it grew out of their own "Borg" system) and open-sourced it, so GCP's container/Kubernetes tooling feels like the most "native" and polished version of that experience out of any provider.

## Services I looked into

### Compute Engine
This is GCP's version of EC2 - a virtual machine you configure and manage. Same idea: pick a machine type (CPU/RAM), pick an OS image, and you get a server. One thing I noticed is GCP's per-second billing and "sustained use discounts" (you get a discount automatically the longer a VM runs in a month, no need to buy a reserved instance upfront like AWS).

*Example:* running the exact same `docker compose up` setup from Task 5 on a Compute Engine VM instead of an AWS EC2 instance - functionally almost identical, just a different provider's VM under the hood.

### Cloud Functions
GCP's serverless functions, same concept as AWS Lambda - you write a function, it runs only when triggered, you don't manage any server.

*Example:* a Cloud Function that triggers whenever a new file lands in a Cloud Storage bucket and processes it automatically (e.g. resizing an uploaded image, or validating a CSV file).

### GKE (Google Kubernetes Engine)
This is the one that impressed me the most. GKE is a fully managed Kubernetes service - Google handles the "control plane" (the brains of the cluster) for you, and it's widely considered the smoothest managed Kubernetes experience compared to AWS's EKS or Azure's AKS. Since Kubernetes itself is open-source and portable, learning it on GKE means the knowledge would transfer to any other Kubernetes environment too.

*Example:* if `devops-crm-project` needed to scale to handle way more traffic, a real production setup would probably run it as a set of pods on GKE, with Kubernetes automatically restarting containers that crash and scaling up replicas when load increases - something that would be a real pain to do manually with plain Docker.

### Cloud Run
This one is kind of the "best of both worlds" between Compute Engine and Cloud Functions - you give it a container (like a Docker image), and it runs it, scales it up and down automatically (even down to zero when there's no traffic), and you don't manage any servers or clusters at all.

*Example:* I could actually see myself using this for the CRM project - take the Docker image built in Task 5, push it to Cloud Run, and it would just run without needing a whole Kubernetes cluster for something this size.

### Cloud Storage
GCP's version of S3 - object storage for files, backups, static assets, arranged into "buckets," same basic model as AWS.

### Cloud SQL and Firestore
- **Cloud SQL** is a managed relational database (Postgres/MySQL), the GCP equivalent of RDS.
- **Firestore** is a managed NoSQL document database, good for flexible, fast-changing data structures (more document-style than DynamoDB's key-value style).

Since `devops-crm-project` runs on Postgres, Cloud SQL is the direct equivalent I'd reach for here.

### VPC
GCP's VPC is actually **global by default** - one VPC can span multiple regions, whereas in AWS a VPC is tied to a single region. This was one of the clearer differences I noticed between the two platforms - GCP's networking model felt simpler to reason about because I didn't have to think about connecting VPCs across regions.

### Cloud IAM
Same core idea as AWS IAM - who/what is allowed to do what, tied to roles and permissions. I noticed GCP's permission model felt a little more straightforward to read, but the underlying concept (principle of least privilege - only give the minimum access needed) is identical to AWS.

### Cloud Monitoring and Cloud Logging
GCP's version of CloudWatch (this used to be called "Stackdriver" before Google renamed it). Same purpose - metrics, dashboards, logs, alerts for whatever you've got running.

### Cloud Build
GCP's native CI/CD tool, playing the same role as AWS CodePipeline or the GitHub Actions setup from Task 4 - builds, tests, and deploys code automatically when triggered.

## What I learned overall

1. **GCP's services map almost 1:1 onto AWS's** - once I understood AWS, learning GCP was much faster because it was mostly "same concept, different name" (EC2 -> Compute Engine, S3 -> Cloud Storage, RDS -> Cloud SQL, IAM -> IAM, CloudWatch -> Cloud Monitoring).
2. **GKE and Cloud Run stood out as GCP's real strengths.** If I had to actually deploy a containerized app quickly without thinking too hard about infrastructure, Cloud Run looks like the easiest path of anything I looked at across both clouds.
3. **GCP's global VPC is a genuinely simpler mental model** than AWS's per-region VPC - one less thing to worry about when networking things together.
4. **Fewer options isn't a bad thing for a beginner.** AWS gives more flexibility, but GCP's smaller, more curated service list made it easier to build a mental map of "what do I actually need" without getting lost in options I'd probably never use anyway.
5. Between the two, if I were picking a cloud purely to deploy a containerized project like the one from Task 5, GCP (specifically Cloud Run) felt like the fastest path from "I have a Docker image" to "it's running in the cloud."

## One thing I'd still want to try hands-on

Actually pushing the Docker image from Task 5 to Cloud Run using GCP's free trial credit, to compare how that workflow feels against doing the same thing on AWS ECS.