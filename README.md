# Task 8 — AWS Observability

## Overview
This task covers an exploration of AWS Observability services, their purpose, and their usage in monitoring, logging, tracing, and auditing cloud infrastructure and applications.

## Contents
- `aws_observability.pdf` — Detailed documentation covering:
  - Introduction to Observability and its importance in modern cloud architectures
  - Top 10 AWS Observability services explained (CloudWatch, CloudTrail, X-Ray, CloudWatch Logs, CloudWatch Alarms, CloudWatch Dashboards, Amazon Managed Prometheus, Amazon Managed Grafana, AWS Health Dashboard, OpenSearch Service)
  - A summary table mapping AWS services to the three pillars of observability (Metrics, Logs, Traces)
- Loom video walkthrough explaining the concepts covered in the documentation (linked in the PR)

## What Was Learned
- The three pillars of observability — metrics, logs, and traces — and how AWS services map to each
- How CloudWatch serves as the central hub for monitoring, alarming, and dashboards across AWS resources
- How AWS X-Ray enables distributed tracing across microservices and serverless applications
- How CloudTrail supports auditing and governance by tracking API activity
- How managed open-source-compatible tools (Amazon Managed Prometheus & Grafana) extend observability for containerized/Kubernetes workloads

## How to Review
1. Read `aws_observability.pdf` for the full write-up.
2. Watch the linked Loom video for a verbal walkthrough of the same concepts.

## Branch Info
- Branch: `fiza-task8`
- Base: `main`
