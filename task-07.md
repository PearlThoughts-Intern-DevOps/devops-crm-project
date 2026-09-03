# Task 7: AWS EC2 — Deploy Twenty CRM

**Author:** Shubham Singh
**Branch:** `shubham-7`
**Date:** September 2, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [EC2 Concepts Used](#ec2-concepts-used)
3. [Step 1: Launch EC2 Instance](#step-1-launch-ec2-instance)
4. [Step 2: Configure Security Group](#step-2-configure-security-group)
5. [Step 3: Connect to EC2 Instance](#step-3-connect-to-ec2-instance)
6. [Step 4: Install Docker on EC2](#step-4-install-docker-on-ec2)
7. [Step 5: Deploy Twenty CRM](#step-5-deploy-twenty-crm)
8. [Step 6: Access and Verify the Application](#step-6-access-and-verify-the-application)
9. [Step 7: Verify Data in Database](#step-7-verify-data-in-database)
10. [Issues Faced & Solutions](#issues-faced--solutions)
11. [Cleanup](#cleanup)
12. [Summary](#summary)

---

## Overview

This document covers the end-to-end process of deploying **Twenty CRM** on an AWS EC2 instance using Docker Compose, verifying the application works correctly through the UI, and confirming that data is persisted in the PostgreSQL database.

**Instance Details:**

| Parameter     | Value                     |
|---------------|---------------------------|
| Instance Type | t3.small                  |
| AMI           | Ubuntu Server 24.04 LTS   |
| Region        | us-east-1                 |
| Key Pair      | shubhamsingh-task07.pem   |
| Public IP     | 18.207.122.57             |
| App URL       | http://18.207.122.57:3000 |

---

## EC2 Concepts Used

- **AMI (Amazon Machine Image):** A pre-configured OS template used to launch the instance. Ubuntu 24.04 LTS was used here.
- **Instance Type:** Defines the vCPU and RAM allocated. `t3.small` gives 2 vCPUs and 2 GB RAM, which is better suited for running multiple Docker containers simultaneously.
- **Key Pair:** An SSH key pair used to connect securely. The `.pem` file is downloaded once at instance creation — losing it means losing SSH access.
- **Security Group:** Works like a firewall, controlling what traffic can reach the instance and on which ports.
- **Public IP:** The externally reachable IP assigned to the instance. This changes if the instance is stopped and started unless an Elastic IP is attached.
- **User Data:** Optional scripts that can run automatically when an instance first boots up.

---

## Step 1: Launch EC2 Instance

1. Log in to the **AWS Console** → Go to **EC2** → Click **Launch Instance**.

2. Fill in the configuration:
   - **Name:** `twenty-crm-server`
   - **AMI:** Ubuntu Server 24.04 LTS (64-bit x86)
   - **Instance Type:** `t3.small`
   - **Key Pair:** Created a new key pair named `shubhamsingh-task07` and downloaded the `.pem` file
   - **Storage:** 20 GB gp2

3. Click **Launch Instance** and wait for the status to show **running**.

---

## Step 2: Configure Security Group

The following **Inbound Rules** were added to allow the necessary traffic:

| Rule       | Protocol | Port | Source    |
|------------|----------|------|-----------|
| SSH        | TCP      | 22   | 0.0.0.0/0 |
| HTTP       | TCP      | 80   | 0.0.0.0/0 |
| HTTPS      | TCP      | 443  | 0.0.0.0/0 |
| Custom TCP | TCP      | 3000 | 0.0.0.0/0 |

> Port 3000 is where Twenty CRM listens, so it must be open for the app to be reachable from the browser.

---

## Step 3: Connect to EC2 Instance

Fix the key file permissions first, then SSH in:

```bash
chmod 400 shubhamsingh-task07.pem
ssh -i "shubhamsingh-task07.pem" ubuntu@18.207.122.57
```

Once inside, update the system:

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

After the reboot, SSH back in.

---

## Step 4: Install Docker on EC2

```bash
# Install Docker
sudo apt install -y docker.io

# Start Docker and make it start on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group so sudo isn't needed every time
sudo usermod -aG docker ubuntu
newgrp docker

# Confirm Docker is working
docker --version

# Install Docker Compose plugin
sudo apt install -y docker-compose-plugin
docker compose version
```

---

## Step 5: Deploy Twenty CRM

### 5.1 Create a Working Directory

```bash
mkdir ~/twenty-deploy && cd ~/twenty-deploy
```

### 5.2 Download the Official Docker Compose File

The Twenty repo is a large monorepo — there's no `docker-compose.yml` at the root. The deployment file lives inside the `packages/twenty-docker/` subfolder, so pull just that file directly:

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/docker-compose.yml
```

This uses pre-built images from Docker Hub (`twentycrm/twenty:latest`) — no need to build from source.

### 5.3 Generate Secret Keys

```bash
NEW_KEY=$(openssl rand -hex 32)
APP_SECRET=$(openssl rand -hex 32)

echo "ENCRYPTION_KEY: $NEW_KEY"
echo "APP_SECRET: $APP_SECRET"
```

Using `hex` instead of `base64` avoids characters like `/`, `+`, and `=` that can cause issues when parsed from a `.env` file.

### 5.4 Get the Instance's Public IP

```bash
curl ifconfig.me
# 18.207.122.57
```

### 5.5 Create the `.env` File

Opened a new `.env` file in vi and filled in the values:

```bash
vi .env
```

Added the following variables (using the keys generated in 5.3 and the IP from 5.4):

```
PG_DATABASE_PASSWORD=<strong-password>
ENCRYPTION_KEY=<generated-hex-key>
APP_SECRET=<generated-hex-key>
SERVER_URL=http://18.207.122.57:3000
STORAGE_TYPE=local
```

Save and exit vi with `:wq`.

### 5.6 Adjust the Healthcheck Timing

The default healthcheck in the compose file gives up too early — the server needs 2–3 minutes to finish DB migrations and come up. Open the file with vi and update the healthcheck values under the `server` service:

```bash
vi docker-compose.yml
```

Change:
```yaml
retries: 20
interval: 5s
timeout: 5s
```

To:
```yaml
retries: 40
interval: 10s
timeout: 10s
```

Save and exit with `:wq`.

### 5.7 Start the Application

```bash
docker compose up -d
```

### 5.8 Check Container Status

```bash
docker compose ps
```

Expected output once everything is healthy:

```
NAME              IMAGE                     COMMAND                  SERVICE   CREATED          STATUS
twenty-db-1       postgres:16               "docker-entrypoint.s…"   db        13 minutes ago   Up 13 minutes (healthy)
twenty-redis-1    redis                     "docker-entrypoint.s…"   redis     13 minutes ago   Up 13 minutes (healthy)
twenty-server-1   twentycrm/twenty:latest   "/app/entrypoint.sh …"   server    13 minutes ago   Up 12 minutes (healthy)
```

### 5.9 Tail the Server Logs

```bash
docker compose logs -f server
```

A successful start looks like:

```
[Nest] 1  - LOG [NestApplication] Nest application successfully started
```

### 5.10 Quick Local Health Check

```bash
curl http://localhost:3000/healthz
```

Expected response:

```json
{"status":"ok","info":{},"error":{},"details":{}}
```

---

## Step 6: Access and Verify the Application

Open a browser and go to:

```
http://18.207.122.57:3000
```

### 6.1 Create a Workspace and Admin Account

On first load, Twenty CRM shows a setup screen. Filled in the details:

- **Email:** shubhamsingh74888@gmail.com
- **First Name:** Shubham
- **Last Name:** Singh
- **Workspace Name:** shubham singh

Clicked **Create Account** and was redirected to the Twenty CRM dashboard.

### 6.2 Add Test Companies

To have real data to verify in the database:

1. In the left sidebar, clicked **Companies**.
2. Used **+ New Company** to add a company named `Untitled` with domain set to the instance IP.

Twenty CRM also seeds a few default companies on workspace creation — Airbnb, Anthropic, Stripe, Figma, and Notion were already present.

The Companies view showing all 6 entries confirms the app is working correctly:

![Twenty CRM Companies View](screenshots/twenty-crm-companies.png)

---

## Step 7: Verify Data in Database

The PostgreSQL container runs as `twenty-db-1`. Connected directly with:

```bash
docker exec -it twenty-db-1 psql -U postgres -d default
```

### 7.1 Find the Workspace Schema

Twenty CRM creates a separate schema per workspace. To find it:

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name LIKE 'workspace_%';
```

Output:

```
             schema_name
-------------------------------------
 workspace_4opx724eiivxpdi0typo3eqqy
(1 row)
```

### 7.2 List All Tables in the Workspace Schema

```sql
\dt workspace_4opx724eiivxpdi0typo3eqqy.*
```

Output showed 31 tables including `company`, `person`, `opportunity`, `task`, `note`, `workflowRun`, `workspaceMember`, and others — confirming the schema was fully initialized.

### 7.3 Query the Companies Table

```sql
SET search_path TO workspace_4opx724eiivxpdi0typo3eqqy;

SELECT id, name, "domainName", "createdAt"
FROM company
ORDER BY "createdAt"
LIMIT 10;
```

This returned all 6 companies visible in the UI — the 5 seeded defaults (Airbnb, Anthropic, Stripe, Figma, Notion) plus the one created manually.

### 7.4 Query the Workspace Members Table

```sql
SELECT id, "nameFirstName", "nameLastName", "createdAt"
FROM "workspaceMember"
LIMIT 5;
```

This returned the admin account created during setup — confirming user data is persisted correctly.

### 7.5 Exit psql

```sql
\q
```

---

## Issues Faced & Solutions

### Issue 1: SERVER_URL Had the Wrong Value in .env

**Problem:** After starting the containers, the server kept throwing a validation error — `SERVER_URL must be a URL address`. When I opened the `.env` file to check, the SERVER_URL value wasn't right.

**What was happening:** I had initially written the IP placeholder manually but made a typo in the format. Opened the file again in vi, fixed the SERVER_URL to the correct format (`http://18.207.122.57:3000`), saved, and brought the containers back up.

**Fix:**

```bash
vi .env
# corrected SERVER_URL to: http://18.207.122.57:3000
docker compose down -v
docker compose up -d
```

---

### Issue 2: Server Container Kept Reporting Unhealthy

**Problem:** After running `docker compose up -d`, the server container kept showing as `unhealthy` and dependent containers wouldn't start. But tailing the logs with `docker compose logs -f server` showed the Nest app actually did start successfully — it printed `Nest application successfully started` right before Docker declared it unhealthy.

**What was happening:** Twenty's server takes around 2–3 minutes to run DB migrations and fully initialize. The default healthcheck only gives it about 100 seconds (20 retries × 5s interval) before marking it unhealthy — not enough time.

**Fix:** Opened `docker-compose.yml` with vi and updated the healthcheck block under the `server` service:

```bash
vi docker-compose.yml
```

Changed `retries: 20` to `retries: 40` and both `interval` and `timeout` from `5s` to `10s`. That gives ~6–7 minutes total wait time, which is enough for the server to complete initialization.

```bash
docker compose down -v
docker compose up -d
```

All three containers (db, redis, server) came up healthy after that.

---

### Issue 3: ENCRYPTION_KEY with Special Characters Caused Startup Failure

**Problem:** The first key I generated using `openssl rand -base64 32` had characters like `/`, `+`, and `=`. The app failed to start and the logs showed a key parsing error.

**Fix:** Switched to `openssl rand -hex 32` which only outputs alphanumeric characters — no special characters that could break `.env` parsing.

---

### Issue 4: No docker-compose.yml at Repo Root

**Problem:** I first cloned the full `twentyhq/twenty` GitHub repo expecting to find a `docker-compose.yml` at the root. The repo is a large NX monorepo and there's nothing deployable at the top level — just source code.

**Fix:** Pulled the deployment file directly from its actual path inside the repo instead of cloning everything:

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/docker-compose.yml
```

This grabs just the compose file, which references pre-built Docker Hub images — no local build needed.

---

## Cleanup

Stopped all containers first:

```bash
docker compose down -v
```

Then in the **AWS Console:**
- Went to **EC2 → Instances**
- Selected the instance → **Instance State → Terminate**

---

## Summary

| Step | Action                                                         | Status  |
|------|----------------------------------------------------------------|---------|
| 1    | Launched EC2 instance (Ubuntu 24.04, t3.small)                 | ✅ Done |
| 2    | Configured Security Group (ports 22, 80, 443, 3000)            | ✅ Done |
| 3    | SSH into EC2 using shubhamsingh-task07.pem                     | ✅ Done |
| 4    | Installed Docker and Docker Compose                            | ✅ Done |
| 5    | Downloaded official Twenty CRM docker-compose.yml              | ✅ Done |
| 6    | Created `.env` with correct keys and SERVER_URL                | ✅ Done |
| 7    | Adjusted healthcheck timing in docker-compose.yml              | ✅ Done |
| 8    | Deployed Twenty CRM via `docker compose up -d`                 | ✅ Done |
| 9    | Verified health endpoint returns `{"status":"ok"}`             | ✅ Done |
| 10   | Created workspace and admin account in Twenty CRM              | ✅ Done |
| 11   | Added companies and verified they appear in the UI             | ✅ Done |
| 12   | Connected to PostgreSQL and verified workspace schema + data   | ✅ Done |
| 13   | Cleaned up containers and terminated EC2 instance              | ✅ Done |
