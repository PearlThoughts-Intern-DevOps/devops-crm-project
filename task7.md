# Task 7 — AWS EC2: Deploying Twenty CRM

**Branch:** `sakhisurakhya/task-7`

## 1. Overview

This task involved launching an AWS EC2 instance, connecting to it via SSH, installing the required tooling, and deploying the Twenty CRM application (the same app worked with in Tasks 3–5) on that instance — accessible from a browser via the instance's public IP.

**Final result:** Twenty CRM successfully running on EC2, accessible at `http://<public-ip>:2020`, with the same seeded workspace data (599 companies, etc.) seen in local testing.

## 2. EC2 Concepts Used

- **EC2 (Elastic Compute Cloud):** AWS's virtual machine service — rents a server with a chosen CPU/RAM/OS configuration, billed by usage.
- **AMI (Amazon Machine Image):** the OS template an instance boots from. Used: **Ubuntu Server (Canonical, 26.04 LTS)** — chosen for consistency with the Ubuntu/WSL2 environment used in Tasks 3–5, and because it uses `apt` (matching all previously-tested setup commands).
- **Instance type:** determines CPU/RAM/network capacity. Started with `t3.micro` (1 vCPU, 1GB RAM) but ultimately used **`t3.small`** (2 vCPU, 2GB RAM) after the smaller type proved insufficient for Twenty CRM's setup process (see Issues below).
- **Key pair:** an SSH public/private key pair used to authenticate into the instance instead of a password. AWS stores the public key; the private key (`.pem` file) is downloaded once and used locally for SSH.
- **Security group:** a virtual firewall attached to the instance. Configured to allow:
  - **SSH (port 22)** — for terminal access to the instance
  - **Custom TCP (port 2020)** — for browser access to the Twenty CRM UI
  - Both rules set to source "Anywhere" (0.0.0.0/0), acceptable for this short-lived task instance
- **Storage (EBS volume):** the instance's disk. Started with the default **8 GiB**, which proved insufficient (see Issues) — ultimately resized to **20 GiB** for the successful deployment.
- **Region:** `us-east-1` (N. Virginia).

## 3. Steps Performed

### 3.1 Launch the EC2 instance
1. EC2 Dashboard → **Launch instance**
2. Name: `devops-crm-task7`
3. AMI: **Ubuntu Server 26.04 LTS**, 64-bit (x86)
4. Instance type: **t3.small**
5. Key pair: created new key pair (RSA, `.pem` format), downloaded and kept locally — per team instruction, SSH was required via the local `.pem` file rather than AWS's browser-based "EC2 Instance Connect"
6. Security group: created new, with inbound rules for SSH (22) and Custom TCP (2020), both from Anywhere
7. Storage: **20 GiB** (gp3) — increased from the 8 GiB default after diagnosing a disk space issue (see Issue 2)
8. Launched the instance and waited for status to become **Running**

### 3.2 Connect to the instance
```bash
chmod 400 sakhisurakhya-task7-key.pem   # (on Linux/macOS; not required on Windows)
ssh -i sakhisurakhya-task7-key.pem ubuntu@<instance-public-ip>
```

### 3.3 Install Docker
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

### 3.4 Install Node.js and the Twenty CLI
```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs
sudo corepack enable
sudo npm install -g twenty-sdk
```

### 3.5 Add swap space (for memory headroom — see Issue 3)
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 3.6 Deploy Twenty CRM
```bash
twenty docker:start
```
This pulls the official `twentycrm/twenty-app-dev` Docker image and starts the Twenty CRM server, running migrations, seeding demo data, and starting the application — the same process used locally in Task 3, now running on EC2.

### 3.7 Verify deployment
```bash
twenty docker:status
```
Output:
```
Status:  running (healthy)
URL:     http://localhost:2020
Version: v2.37.4
Login:   tim@apple.dev / tim@apple.dev
```

Accessed from a browser (from the local machine, not the instance) at:
```
http://<instance-public-ip>:2020
```
Logged in with the default credentials (`tim@apple.dev` / `tim@apple.dev`) and confirmed the full CRM UI loaded correctly, including the seeded workspace data (599 companies).

> **Note on "Not secure" browser warning:** the app is served over plain HTTP (no SSL/TLS certificate), since setting up HTTPS would require a registered domain and certificate — outside this task's scope. This is expected for a short-lived test deployment.

### 3.8 Clean up
```bash
twenty docker:stop
```
The EC2 instance was then **terminated** via the AWS Console (Instances → select instance → Instance state → Terminate) to avoid ongoing AWS charges, per the task's instructions.

## 4. Issues Faced & Solutions

### Issue 1 — Shared AWS account vCPU quota limit
**Problem:** The team's shared AWS account had a vCPU quota limit that blocked EC2 launches for multiple interns simultaneously, including this one.
**Solution:** Used KodeCloud's temporary AWS sandbox playground as a workaround to continue hands-on practice while the team's quota increase was pending. The team's account quota was later increased, and final deployment work was completed on the original shared account.

### Issue 2 — `docker:start` killed during database migrations (disk space)
**Problem:** On the first successful instance launch (8 GiB default storage, `t3.micro`), `twenty docker:start` failed partway through with:
```
==>  Running initial database setup and migrations... Killed
```
**Diagnosis:** Checked disk usage (`df -h`) and found the root filesystem was **100% full** (only ~104MB free on a 6.7GB usable disk) — the base OS, Docker, Node.js, and the ~1.8GB Twenty Docker image together left no working room for PostgreSQL to write logs and temp files during migration. Safe cleanup steps (`apt clean`, journal log cleanup) were attempted first but only freed a negligible amount, confirming the disk was fundamentally undersized for this workload rather than cluttered with removable files.
**Solution:** Terminated the instance and relaunched with **20 GiB** storage instead of the 8 GiB default. This resolved the migration failure — `Running initial database setup and migrations... Done` completed successfully on the next attempt.

### Issue 3 — `docker:start` reported "Seeding workspace data... Failed" (memory)
**Problem:** After fixing the disk issue, a subsequent `twenty docker:start` run progressed further (migrations completed) but reported:
```
==>  Seeding workspace data... Failed
Twenty server did not become healthy in time.
```
**Diagnosis:** Checked memory (`free -h`) and found the instance (`t3.small`, 2GB RAM) was nearly fully utilized (only ~89MB available, 0 swap configured) at the time of failure. Checking `docker ps -a` showed the container was still running despite the CLI reporting "Failed" — the CLI's readiness check had simply timed out waiting for the memory-intensive seeding step to finish, rather than the container actually crashing.
**Solution:** Added a 2GB swap file to give the instance more effective memory headroom. Rechecked shortly after with `twenty docker:status`, which confirmed the container had finished seeding on its own in the background and was now `running (healthy)` — the extra swap gave the still-running process enough room to complete rather than being killed.

### Issue 4 — AMI selection mismatch (Amazon Linux vs. Ubuntu)
**Problem:** On one launch attempt, the AMI defaulted to **Amazon Linux** rather than Ubuntu.
**Diagnosis:** All setup commands used throughout this task (and Tasks 3/5) are Ubuntu/Debian-specific (`apt`, NodeSource's `.deb`-based install script, `ubuntu` as the default SSH user). Amazon Linux uses a different package manager (`yum`/`dnf`) and default SSH user (`ec2-user`), which would have required a different, untested command set.
**Solution:** Explicitly selected the **Ubuntu** Quick Start AMI tile before launching, ensuring consistency with all previously validated commands.



## 5. Summary of Root Cause

The two most significant technical issues (migrations killed, seeding failed) both traced back to the same underlying theme: **the default EC2 instance sizing (`t3.micro`, 8GB disk) was insufficient for Twenty CRM's full setup process** (Docker image + Postgres + migrations + demo data seeding + a large NestJS application boot). Methodically checking `df -h` and `free -h` at each failure point — rather than guessing — correctly identified disk space and memory as the actual constraints, leading directly to the fix: **`t3.small` (2GB RAM) + 20GB storage + 2GB swap**, which together provided enough headroom for a fully successful deployment.


