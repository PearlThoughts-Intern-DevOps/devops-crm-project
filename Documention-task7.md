# Task 7: EC2 Deployment of Twenty CRM — Documentation

## Overview

This task involved launching an AWS EC2 instance, connecting to it, and deploying
the Twenty CRM application on it using the `devops-crm-project` repo (a Twenty App
extension built on `twenty-sdk`). The SDK's `docker:start` command pulls and runs a
pre-built Docker image (`twentycrm/twenty-app-dev`) containing the full Twenty CRM
stack (PostgreSQL, Redis, server, worker, frontend) so the app can be developed and
synced against a live Twenty instance.

## 1. AWS Console Access

- Logged into the AWS Console using the credentials provided via email.
- Confirmed access to the EC2 dashboard before proceeding.

## 2. EC2 Instance Configuration

| Setting | Value |
|---|---|
| AMI | Ubuntu 22.04/24.04 LTS *(fill in exact AMI name/ID used)* |
| Instance type | *(fill in — e.g. t2.micro / t3.micro, ~1–2GB RAM)* |
| Key pair | *(fill in key pair name, .pem)* |
| Security group | Inbound: SSH (22) from my IP; *(add any other ports opened, e.g. custom TCP for tunnels)* |
| Storage | Initially default (~7–8GB gp2/gp3), later resized to 25GB (see Issues below) |

## 3. Connecting to the Instance

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<ec2-public-ip>
```

## 4. Base Setup on the Instance

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl git

# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Clone the project repo
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project

# Install Node version pinned in .nvmrc, and Yarn 4 via Corepack
nvm install
nvm use
corepack enable
corepack prepare yarn@4 --activate
yarn --version
```

## 5. Installing Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

## 6. Installing Project Dependencies and Running the App

```bash
yarn install
yarn twenty docker:start     # pulls/starts the Twenty CRM Docker image
yarn twenty docker:status    # check health/status
yarn twenty dev              # start dev server and sync the app
```

Once healthy, the app is reachable at `http://localhost:2020` on the instance,
with default login `tim@apple.dev` / `tim@apple.dev`.

## 7. Accessing the App Remotely

Since the app binds to `localhost` on the EC2 instance, the app (and the SDK's
OAuth callback listener used by `yarn twenty dev`) were accessed via an SSH
tunnel rather than opening ports publicly:

```bash
ssh -i your-key.pem -L 2020:localhost:2020 -L <callback-port>:localhost:<callback-port> ubuntu@<ec2-public-ip>
```

The callback port is shown in the `redirectUrl` query parameter of the
`/authorize` link printed by `yarn twenty dev` and can change between runs.

## 8. Issues Faced and Solutions

### Issue 1: `yarn install` killed (Out of Memory)
- **Symptom**: `Killed` during the Fetch/Link step of `yarn install`.
- **Cause**: Instance had ~1.9GB RAM and 0 swap; installing/building packages
  like `esbuild` and `monaco-editor`-adjacent dependencies exceeded available memory.
- **Solution**: Added 2GB of swap space.
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```
- Cleaned up the partial install before retrying:
```bash
yarn cache clean
rm -rf node_modules .yarn/install-state.gz
yarn install
```

### Issue 2: `no space left on device` while pulling the Docker image
- **Symptom**: `docker: failed to extract layer ... no space left on device`
  during `yarn twenty docker:start`.
- **Cause**: Default root EBS volume was only ~6.7–8GB, which filled up
  between the swapfile, apt packages, node_modules, and the large Twenty
  Docker image.
- **Solution**: Resized the EBS volume from the AWS Console (EC2 > Instances >
  Storage tab to find the attached Volume ID > EC2 > Volumes > Modify Volume
  to 25GB), then grew the partition and filesystem on the instance:
```bash
lsblk                              # confirm partition names
sudo growpart /dev/nvme0n1 1       # or /dev/xvda depending on instance type
sudo resize2fs /dev/nvme0n1p1
df -h                               # confirm new space is available
```

### Issue 3: Twenty container reporting "unhealthy" during startup
- **Symptom**: `yarn twenty docker:start` reported "Twenty server did not
  become healthy in time" right after "Flushing cache."
- **Cause**: The instance was still under memory pressure (near its RAM+swap
  limit) while Postgres, Redis, and the Twenty server/worker all started
  inside the container concurrently, so the health check timed out before
  startup fully finished.
- **Solution**: Waited briefly and re-ran `yarn twenty docker:status` — the
  container finished starting and reported `running (healthy)` shortly after.
  No config change was needed, just more time on a resource-constrained box.

### Issue 4: OAuth callback "refused to connect" during `yarn twenty dev`
- **Symptom**: Browsing the printed `/authorize` link showed the frontend
  page fine, but after authorizing, the browser tried to reach
  `127.0.0.1:<port>/callback` and failed to connect.
- **Cause**: The `twenty-sdk` CLI starts a temporary local callback listener
  on the EC2 instance on a random port. Since the browser used was on a local
  machine (not the EC2 instance), `127.0.0.1:<port>` resolved to the local
  machine, which had nothing listening there.
- **Solution**: Added a second SSH tunnel forwarding that specific callback
  port from the EC2 instance to the local machine, alongside the port 2020
  tunnel, then reloaded the authorize link.

## 9. EC2 Concepts Used

- **AMI (Amazon Machine Image)**: base OS image used to launch the instance.
- **Instance type**: determines vCPU/RAM available; directly caused the OOM
  issues above on a small (~1–2GB RAM) instance.
- **Key pair**: used for SSH authentication instead of passwords.
- **Security group**: acts as a virtual firewall; only SSH was opened
  inbound, and app access was done via SSH tunneling instead of opening
  additional ports.
- **EBS (Elastic Block Store) volume**: the instance's root disk; needed to
  be resized when the default size proved too small for Docker images and
  dependencies.
- **Elastic/public IP**: used to SSH into and tunnel to the instance.

## 10. Cleanup

- Stopped/terminated the EC2 instance after verifying the deployment to avoid
  ongoing AWS charges.
*(fill in: confirm stop vs terminate, and date/time performed)*
