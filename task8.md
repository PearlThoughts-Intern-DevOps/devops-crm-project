# Task 8 — Exploring AWS Observability

**Branch:** `sakhisurakhya/task-8`

## What I did

For this task, I explored AWS's observability services — the tools used to monitor, log, and trace what's actually happening inside cloud infrastructure and applications. This connected directly to real problems I hit in Task 7: when my EC2 instance's `twenty docker:start` failed, I had to manually SSH in and run `free -h` / `df -h` to figure out what went wrong. Observability tools are essentially what let you see that same kind of information (and much more) without having to manually dig through a terminal every time.

## 1. What is Observability (Quick Context)

Observability is the ability to understand what's happening inside a system from the outside, based on the data it produces — logs, metrics, and traces. In Task 7, I was doing a very manual, small-scale version of this myself (checking `free -h`, `df -h`, `docker logs`) to diagnose why the app wasn't starting. AWS's observability services do this at a much larger scale, automatically, and let you go back in time to see what happened, set up alerts, and visualize trends — instead of only being able to check the current moment like I was doing manually.

## 2. AWS Observability Services Explored

| Service | What it does | How it connects to what I did in Task 7 |
|---|---|---|
| **CloudWatch** | The core AWS monitoring service — collects metrics (CPU, memory, disk, network) and logs from AWS resources, lets you build dashboards, and set alarms. | If I'd had CloudWatch set up, I could have seen my EC2 instance's memory and disk usage as a graph over time, instead of manually SSHing in and running `free -h`/`df -h` after something already failed. |
| **CloudWatch Logs** | Centralized log storage — applications and services can stream their logs here instead of only living on the local disk. | Right now, `twenty docker:logs` only shows logs on the instance itself, and they'd be lost the moment I terminate it. CloudWatch Logs would keep them centrally, even after the instance is gone. |
| **CloudWatch Alarms** | Lets you set thresholds (e.g., "alert me if disk usage goes above 90%") and get notified automatically. | This would have caught my Task 7 disk-space issue *before* it caused a crash, instead of me discovering it only after `docker:start` failed. |
| **CloudTrail** | Logs every API call/action made in the AWS account — who did what, when (e.g., who launched an instance, who changed a security group). | Useful for a shared team account like the one used in this internship — could help track down things like the security group naming collision I hit, or who has which IAM permissions. |
| **X-Ray** | Distributed tracing — tracks a single request as it moves through multiple services, showing where time is spent and where failures happen. | More relevant for complex multi-service apps (e.g., if Twenty CRM's backend called out to several other microservices) rather than a single EC2 instance, but useful to know about for larger deployments. |
| **AWS Config** | Tracks configuration changes to AWS resources over time and can check them against compliance rules. | Could have flagged that my EC2 instance's security group allowed SSH from "Anywhere" (0.0.0.0/0), which is a common but flagged security practice. |
| **Systems Manager (SSM) / CloudWatch Agent** | An agent installed on an EC2 instance that pushes detailed OS-level metrics (memory, disk, custom app metrics) into CloudWatch — since CloudWatch alone only sees basic hypervisor-level metrics by default, not what's happening inside the OS. | This is the missing piece from Task 7 — by default, CloudWatch doesn't automatically know an instance's real memory/disk usage from inside the OS; you need this agent running for that. |

## 3. Key Things I Learned

**CloudWatch doesn't see everything by default.** This surprised me — I assumed AWS would automatically show memory and disk usage for an EC2 instance, but by default, CloudWatch only tracks basic metrics like CPU utilization and network traffic at the hypervisor level. To get real memory/disk usage (exactly the numbers I was checking manually via `free -h`/`df -h` in Task 7), you need to install the **CloudWatch Agent** on the instance itself, which then pushes that OS-level data into CloudWatch.

**Logs and metrics are different tools for different questions.** Metrics (CloudWatch) answer "how much" or "how many" over time — good for trends and thresholds. Logs (CloudWatch Logs) answer "what exactly happened" — good for detailed debugging, similar to what I was doing manually with `docker logs` and `twenty docker:logs` in Task 7.

**CloudTrail is about *actions on AWS*, not application behavior.** It was a bit confusing at first, but CloudTrail isn't about what my app is doing — it's about what people/systems are doing *to AWS itself* (launching instances, changing permissions, etc.). This is more of an audit trail than an app-monitoring tool.

**Observability would have saved real time in Task 7.** Both of my EC2 deployment failures (disk space, then memory) were things I only discovered *after* they caused a crash, by manually connecting and running diagnostic commands. With CloudWatch Alarms set up in advance (e.g., "alert if disk usage > 85%" or "alert if available memory < 200MB"), I could have caught both issues proactively, before `twenty docker:start` ever failed.

## 4. How I'd Apply This Going Forward

If I were setting up the Task 7 EC2 deployment "properly" for a real environment (not just a one-off task), I'd:
1. Install the **CloudWatch Agent** on the instance to get real memory/disk metrics
2. Set **CloudWatch Alarms** for disk usage and available memory, so I'd get notified before hitting the same crashes I hit manually
3. Send the Twenty CRM container logs to **CloudWatch Logs**, so they'd persist even after the instance is terminated (right now, once I terminate the instance, all those logs are gone forever)
4. Use **CloudTrail** to keep an audit history on the shared team AWS account, which would help explain things like unexpected security group changes or who launched what



