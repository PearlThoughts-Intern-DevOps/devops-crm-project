# Task 6 — AWS & GCP: What I Learned

**Author:** Saketh
**Branch:** `saketh-task-6`

## 1. Why cloud platforms, in the context of this project

Everything built in Tasks 4–5 (CI pipeline, Docker images) exists to
produce an artifact — a container image — that has to run *somewhere*
reachable on the internet. AWS and GCP are two of the major providers
of that "somewhere": compute, storage, networking, and managed
databases rented by the hour/second instead of bought as hardware.

## 2. AWS (Amazon Web Services) — core services explored

| Category | Service | What it's for |
|---|---|---|
| Compute | **EC2** | Rentable virtual machines; full control over the OS, install anything (e.g. Docker) yourself |
| Compute (containers) | **ECS** / **Fargate** | Runs containers directly — Fargate removes the need to manage the underlying VM at all |
| Compute (containers, K8s) | **EKS** | Managed Kubernetes control plane |
| Storage (objects) | **S3** | Durable object storage — files, backups, static assets, Docker layer caches |
| Storage (block) | **EBS** | Persistent disks attached to EC2 instances |
| Database | **RDS** | Managed Postgres/MySQL/etc. — patching, backups, failover handled for you |
| Networking | **VPC** | Private network you control; subnets, route tables, security groups |
| Identity | **IAM** | Fine-grained permissions — *who/what* can call *which* API |
| CI/CD | **CodePipeline / CodeBuild** | AWS-native alternative to GitHub Actions for build/deploy |
| Container registry | **ECR** | Private Docker image registry, natural pairing with ECS/EKS |

**Typical path for this project on AWS:** push the image built in Task 5
to **ECR** → run it on **ECS Fargate** (no server management) → put
Postgres on **RDS** and Redis on **ElastiCache** instead of containers →
front it with an **Application Load Balancer**.

## 3. GCP (Google Cloud Platform) — core services explored

| Category | Service | What it's for |
|---|---|---|
| Compute | **Compute Engine** | GCP's equivalent of EC2 — VMs |
| Compute (containers) | **Cloud Run** | Fully-managed, serverless container runner — give it an image, it scales to zero and back automatically |
| Compute (containers, K8s) | **GKE** | Managed Kubernetes — arguably the most mature managed K8s offering, since Google created Kubernetes |
| Storage (objects) | **Cloud Storage** | GCP's equivalent of S3 |
| Database | **Cloud SQL** | Managed Postgres/MySQL, GCP's equivalent of RDS |
| Networking | **VPC** | Same concept as AWS's VPC |
| Identity | **IAM** | Same concept, GCP's permission model |
| CI/CD | **Cloud Build** | GCP-native build/deploy pipelines |
| Container registry | **Artifact Registry** | Private image registry, GCP's equivalent of ECR |

**Typical path for this project on GCP:** push the image to **Artifact
Registry** → deploy straight to **Cloud Run** (simplest option for a
single containerized service — no cluster to manage at all) → Postgres
on **Cloud SQL**, Redis via **Memorystore**.

## 4. AWS vs GCP — how I'd compare them for this kind of project

| | AWS | GCP |
|---|---|---|
| Breadth of services | Larger overall catalog, more legacy/niche options | Smaller, more curated catalog |
| Simplest way to run *one* container | ECS Fargate (still some setup: task defs, service, ALB) | Cloud Run (`gcloud run deploy`, essentially one command) |
| Managed Kubernetes | EKS | GKE (generally considered the most polished managed K8s, since Google originated Kubernetes) |
| Pricing model | Pay-per-second for most compute, many pricing dimensions | Similar pay-per-use; Cloud Run specifically bills per-request/scale-to-zero, cheap for spiky/low traffic |
| Market position | Largest market share, most third-party tutorials/tooling | Strong in data/ML and Kubernetes-native workloads |
| Learning curve for a beginner | Steeper — IAM and networking have a lot of surface area | Cloud Run in particular is one of the fastest paths from "Docker image" to "running URL" |

Both platforms map onto the same underlying concepts (VMs, managed
containers, managed Kubernetes, object storage, managed SQL, IAM,
VPC) — the names differ, the shape of the problem doesn't.

## 5. Where this connects back to Tasks 4 & 5

- The **CI workflow** (Task 4) is what would run before any cloud
  deploy — it's the gate that decides whether a build is even eligible
  to be pushed to ECR/Artifact Registry.
- The **Docker image** (Task 5) is exactly the artifact both ECS
  Fargate and Cloud Run expect as input — nothing about the image needs
  to change to move from "runs on my laptop via docker-compose" to
  "runs on a managed container platform." That portability is the whole
  point of containerizing in the first place.

## 6. Steps followed for this task

1. Read AWS's and GCP's own "core concepts" documentation for compute,
   storage, database, and IAM.
2. Mapped each AWS service explored to its closest GCP equivalent (and
   vice versa) to understand where the platforms are conceptually
   identical vs. where they diverge (e.g. Cloud Run has no direct AWS
   1:1 equivalent — Fargate is the closest but requires more setup).
3. Worked through where this specific project's Docker image (Task 5)
   and CI pipeline (Task 4) would fit if deployed to each platform.
4. Wrote this document and recorded the Loom video explaining it.

## 7. Issues faced & solutions

| Issue | Solution |
|---|---|
| AWS's service catalog is large and easy to get lost in as a beginner. | Focused only on the services needed to take *this project's* Docker image to production (compute, registry, managed DB, IAM), rather than trying to learn every service. |
| Mapping AWS ⇄ GCP services 1:1 isn't always exact (e.g. Cloud Run vs. Fargate have different operating models). | Documented the differences explicitly in the comparison table instead of glossing over them. |

## 8. Result

- PR link: `<add PR URL here after opening it>`
- Loom video (face visible throughout): `<add Loom link here>`
