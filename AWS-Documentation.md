# AWS (Amazon Web Services) - What I Learned

**Name:** Vikash Yadav
**Task:** 6 - Cloud Exploration (AWS)
**Date:** 01 September 2026

## Why I started here

AWS is the cloud provider almost everyone mentions first when they talk about "the cloud," so I figured it made sense to start exploring here before moving to GCP. I spent time going through the AWS console, reading through the docs for the core services, and trying to connect what I was reading to things I've already worked on in this internship (like the Docker setup in Task 5 and the CI pipeline in Task 4).

AWS is built around **Regions** (like `us-east-1`, `ap-south-1`) and **Availability Zones** inside each region (basically separate data centers so that if one goes down, your app doesn't). That was the first thing that clicked for me - almost every AWS service asks you which region you want to use, and that's because AWS is essentially a huge collection of independent data center clusters that you get to pick from.

## Services I looked into

### EC2 (Elastic Compute Cloud)
This is just a virtual machine in the cloud. You pick an instance type (how much CPU/RAM you want), an OS image (Amazon Linux, Ubuntu, etc.), and AWS gives you a machine you can SSH into. It's the most "raw" compute option - you're responsible for installing everything yourself, patching it, keeping it running.

*Example I thought through:* if I wanted to run `devops-crm-project` on a single EC2 instance the "old school" way, I'd basically SSH in, install Docker, and run `docker compose up` the same way I did locally in Task 5. It made me realize EC2 is really just "a computer, except AWS owns the hardware."

### Lambda
Serverless functions - you upload code, and AWS runs it only when triggered (an API call, a file upload to S3, a schedule, etc.). You don't manage a server at all, and you only pay for the time your code actually runs.

*Example:* a Lambda function that runs every night at 2 AM and backs up a database, or one that resizes an image the moment it's uploaded to S3. This is the opposite of EC2 - no server to babysit, but less control.

### ECS and EKS
Both are ways to run containers at scale instead of on a single EC2 box:
- **ECS** is AWS's own container orchestrator - simpler to set up, but it's AWS-only.
- **EKS** is managed Kubernetes - more powerful and portable (since Kubernetes is an open standard), but has a steeper learning curve.

This is the part that felt most relevant to what I've been doing - since I already containerized the CRM project with Docker in Task 5, ECS/EKS is basically "what comes next" if this app needed to actually scale up in production.

### S3 (Simple Storage Service)
Object storage - you create a "bucket" and store files in it (images, backups, logs, static website files, whatever). It's not a filesystem you attach to a VM, it's more like an infinitely scalable folder you access over HTTP.

*Example:* storing the `.env` backup files or build artifacts from the CI pipeline I built in Task 4, instead of leaving them sitting on a runner.

### RDS and DynamoDB
- **RDS** is a managed relational database (Postgres, MySQL, etc.) - AWS handles backups, patching, and failover for you.
- **DynamoDB** is a managed NoSQL database, good for simple key-value lookups at very high scale.

Since `devops-crm-project` uses Postgres, RDS is the obvious AWS option if this app ever moved off a self-hosted Docker Postgres container into managed cloud infra.

### VPC (Virtual Private Cloud)
This is the networking layer - it lets you create your own private network inside AWS, decide which parts are public (reachable from the internet) and which are private (like a database that should never be exposed directly). This connected a lot for me back to the Docker networking I set up in Task 5 - same idea of isolating things, just at cloud scale instead of container scale.

### IAM (Identity and Access Management)
Controls who (or what) can do what. Every user, every service, every automated process needs an IAM role or policy attached to it before it's allowed to touch anything. Almost every "AWS isn't working" problem I read about while researching this turned out to be an IAM permissions issue, not an actual bug.

### CloudWatch
Monitoring and logging - metrics, dashboards, alarms (like "alert me if CPU > 80% for 5 minutes"). This is the AWS equivalent of the kind of logging/monitoring you'd want to bolt onto any deployed app to actually know if it's healthy.

### CodePipeline / CodeBuild
AWS's own CI/CD tools - similar in spirit to the GitHub Actions workflow I built in Task 4, except native to AWS and able to trigger AWS deployments directly.

## What I learned overall

1. **AWS's biggest strength (and its biggest challenge for a beginner) is how much choice it gives you.** There's rarely one "right" way to do something - you can run a container on EC2, ECS, EKS, or Lambda, and each has real tradeoffs.
2. **IAM is the thing to actually get right first.** Almost nothing works if the permissions aren't set up properly, and it's very easy to either lock yourself out or accidentally leave something too open.
3. **A lot of AWS maps directly onto things I already did in this internship.** EC2 ~ the VM I'd have Docker running on. S3 ~ a place to store build artifacts. VPC ~ the same isolation concept as Docker networking, just bigger. CodePipeline ~ the same job as my GitHub Actions CI.
4. **Regions/AZs matter for reliability, not just "where is my data."** I hadn't thought about the "what if one data center goes down" angle before this.
5. Honestly, the console can be overwhelming at first - there are so many services listed on the left sidebar. Focusing on the 6-7 services above (compute, storage, database, networking, IAM, monitoring, CI/CD) was enough to get a real mental model of how it fits together.

## One thing I'd still want to try hands-on

Actually deploying the containerized `devops-crm-project` from Task 5 onto ECS using the AWS free tier, just to see the real workflow end-to-end instead of only reading about it.