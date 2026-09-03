# Task 7 – AWS EC2 Deployment

## Overview

This task deploys the Twenty CRM application on an AWS EC2 instance using Docker and Docker Compose.

The deployment uses the Docker containerization setup completed in Task 5.

## AWS EC2 Configuration

| Configuration | Value |
|---|---|
| Cloud Provider | AWS |
| Region | US East (N. Virginia) – `us-east-1` |
| AMI | Amazon Linux 2023 |
| Instance Type | `t3.small` |
| Storage | 8 GiB |
| Key Pair | `mohsin-task-7-key.pem` |
| Security Group | `mohsin-khaled-task7-sg` |

## Security Group Configuration

The EC2 security group was configured with the following inbound rules:

| Type | Protocol | Port | Source | Purpose |
|---|---|---:|---|---|
| SSH | TCP | 22 | My IP | Secure SSH administration |
| Custom TCP | TCP | 2020 | `0.0.0.0/0` | Twenty CRM web access |

SSH access was restricted to the administrator's current public IP, while port 2020 was opened publicly so that the Twenty CRM web interface could be accessed from a browser.

## Connecting to EC2

The Amazon Linux EC2 instance was accessed using the downloaded PEM key from a local Ubuntu/WSL terminal.

The key permissions were restricted:

```bash
chmod 400 ~/mohsin-task-7-key.pem

