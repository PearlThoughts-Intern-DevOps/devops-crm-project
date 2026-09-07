# Task 10 — AWS Observability with CloudWatch (Twenty CRM)

This repository/folder contains the documentation and supporting evidence for **Task 10: AWS Observability with CloudWatch**, built on top of the Twenty CRM deployment from `devops-crm-project` (branch `fiza`).

## What this covers

- Launching and configuring an EC2 instance (t3.small, 20 GiB)
- Deploying Twenty CRM on that instance via Docker (port 2020)
- Exploring default EC2 metrics in CloudWatch
- Installing and configuring the CloudWatch Agent for CPU, memory, and disk metrics
- Creating CloudWatch Alarms (CPU, Disk, Memory) with SNS email notifications
- Building a CloudWatch Dashboard
- Load-testing the instance and validating the full monitoring/alerting pipeline
- Documenting issues faced and how each was resolved

## Project structure

```
.
├── README.md               # this file
├── EC2_OBSERVABILITY.pdf    # full write-up: setup, config, testing, screenshots, issues, conclusions
└── Screenshots/             # supporting screenshots referenced in EC2_OBSERVABILITY.pdf
```

## Where to start reading

Open **`EC2_OBSERVABILITY.pdf`** — it's the complete, step-by-step record of everything done for this task: EC2 launch, IAM role setup, Twenty CRM deployment, CloudWatch Agent installation/config, alarm and dashboard setup, the load test, and a table of every issue hit along with its fix.

## Status

Instance was terminated after all steps in this task were completed and verified. See the "Cleanup" section of `EC2_OBSERVABILITY.pdf` for details.
