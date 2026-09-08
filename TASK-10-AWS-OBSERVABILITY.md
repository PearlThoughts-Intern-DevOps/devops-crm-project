\# Task 10 – AWS Observability with CloudWatch



\*\*Intern:\*\* Varad Ahir  

\*\*Date:\*\* 08-09-2026  

\*\*Region:\*\* us-east-1  

\*\*Instance Type:\*\* t3.small  

\*\*Application:\*\* Twenty CRM



\---



\## 1. Objective



The objective of this task was to deploy Twenty CRM on an AWS EC2 instance and configure AWS CloudWatch monitoring and alerting.



The implementation included:



\- Deploying Twenty CRM on EC2.

\- Verifying the CRM application.

\- Exploring default EC2 CloudWatch metrics.

\- Installing and configuring the CloudWatch Agent.

\- Collecting CPU, memory, and disk metrics.

\- Verifying custom CloudWatch metrics.

\- Creating CPU and memory alarms.

\- Creating a CloudWatch dashboard.

\- Generating activity in Twenty CRM.

\- Verifying monitoring data and alarm states.

\- Documenting troubleshooting and implementation details.

\- Terminating the EC2 instance after completion.



\---



\## 2. AWS EC2 Deployment



An Amazon Linux 2023 EC2 instance was launched in the `us-east-1` region.



\### Instance Configuration



| Configuration | Value |

|---|---|

| Region | us-east-1 |

| Operating System | Amazon Linux 2023 |

| Instance Type | t3.small |

| Storage | 20 GiB |

| Application Port | 3000 |

| SSH Port | 22 |



The EC2 instance passed all three instance status checks.



\---



\## 3. Twenty CRM Deployment



Twenty CRM was deployed using Docker and Docker Compose.



The deployment included the following services:



\- Twenty CRM server

\- Twenty CRM worker

\- PostgreSQL database

\- Redis



The application was exposed on port `3000`.



\### Verification



The application health endpoint was tested successfully:



```bash

curl -I http://127.0.0.1:3000/healthz

