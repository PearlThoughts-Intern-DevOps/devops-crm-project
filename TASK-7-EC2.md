\# Task 7 - AWS EC2 Deployment of Twenty CRM



\## 1. Objective



The objective of this task was to launch and configure an AWS EC2 instance, connect to the instance, install Docker and Docker Compose, and deploy Twenty CRM using Docker Compose.



\## 2. AWS EC2 Configuration



| Configuration | Value |

|---|---|

| Cloud Provider | AWS |

| Region | US East (N. Virginia) - us-east-1 |

| Operating System | Amazon Linux 2023 |

| AMI ID | ami-081b0a6eac00b4f53 |

| Instance Type | t2.small |

| vCPU | 1 |

| Memory | 2 GiB |

| Root Storage | 8 GiB gp3 |

| Monitoring | Disabled |

| CPU Credit Mode | Standard |

| Public IPv4 | Enabled |

| Instance State | Running during deployment |



\### Security Group



The security group was configured with:



\- SSH (TCP 22) - My IP

\- Custom TCP (TCP 3000) - Anywhere IPv4 (0.0.0.0/0)



Port 3000 was required so that Twenty CRM could be accessed from a web browser.



\## 3. EC2 Launch



The EC2 instance was launched using Amazon Linux 2023 with the required AMI.



The initially requested t3.small instance could not be launched because of the AWS account vCPU quota. The account had insufficient available vCPU capacity for the instance bucket.



After reviewing the allowed instance types, t2.small was selected because it was an approved instance type and provides 2 GiB of memory, which satisfies Twenty CRM's minimum memory requirement.



The T-series CPU credit mode was verified as:



\*\*Standard\*\*



Unlimited mode was not used.



\## 4. Connecting to EC2



The EC2 instance was accessed through an SSH client using the EC2 key pair.



The successful connection displayed an Amazon Linux shell similar to:



```text

\[ec2-user@ip-172-31-41-25 \~]$

