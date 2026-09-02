# Task 7: Deploy Twenty CRM on AWS EC2

## Objective

Launch an AWS EC2 instance, configure it for application deployment, deploy and Twenty CRM on EC2 instance, verify external browser access, document troubleshooting, and clean up the AWS resource. 

## 1. EC2 Instance Setup

- **Cloud Provider:** AWS
- **Region:** `us-east-1` (N. Virginia)
- **AMI:** Ubuntu Server LTS, 64-bit x86
- **Initial Instance Type:** `t3.micro`
- **Final Instance Type:** `t3.small`
- **Root Storage:** Increased from 8 GiB to 20 GiB GP3
- **Public IPv4:** Enabled
- **VPC:** Default VPC

### Security Group

| Type | Port | Source | Purpose |
|---|---:|---|---|
| SSH | 22 | My IP | SSH access |
| Custom TCP | 2020 | My IP | Twenty CRM access |

## 2. SSH Connection

The EC2 key pair was configured locally and used to connect to the Ubuntu instance.

```bash
ssh -i ~/.ssh/purva.pem ubuntu@<EC2-PUBLIC-IP>
```

The private key was kept secure and was not committed to the repository.

## 3. Environment Setup

### Docker

Docker and Docker Compose were installed:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
```

### Node.js and Yarn

The project requires Node.js `24.5.0` and Yarn 4.

```bash
nvm install 24.5.0
nvm use 24.5.0

corepack enable
corepack prepare yarn@4.13.0 --activate
```

## 4. Storage Troubleshooting

The initial root volume was 8 GiB. During dependency installation, disk/resource limitations were encountered.

The EBS root volume was increased to **20 GiB GP3**. The partition and filesystem were then expanded:

```bash
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
```

Storage was verified with:

```bash
lsblk
df -h
```

## 5. Memory Troubleshooting

The initial `t3.micro` instance did not have enough memory for Twenty CRM's initialization and migration process.

A Node.js heap error occurred:

```text
FATAL ERROR: Ineffective mark-compacts near heap limit
Allocation failed - JavaScript heap out of memory
```

A **2 GiB swap** configuration was added, and the EC2 instance was upgraded:

```text
t3.micro → t3.small
```

This provided enough memory for the Twenty CRM initialization to complete.

## 6. Twenty CRM Deployment

The official Twenty Docker image was ultimately used:

```text
twentycrm/twenty-app-dev:latest
```

The container was started with:

```bash
docker run -d   --name twenty-task7   -p 2020:2020   twentycrm/twenty-app-dev:latest
```

The container was verified using:

```bash
docker ps
```

The container exposed:

```text
0.0.0.0:2020->2020/tcp
```

## 7. Application Initialization

Twenty CRM required time to initialize its database, server, worker, and scheduled jobs.

Logs were monitored with:

```bash
docker logs -f twenty-task7
```

Successful startup messages included:

```text
twenty-server successfully started
twenty-worker successfully started
```

Cron registration subsequently completed with:

```text
Cron job registration completed: 27 successful, 0 failed, 2 skipped
```

## 8. Verification

The application was first verified from inside EC2:

```bash
curl -I http://localhost:2020
```

Final response:

```text
HTTP/1.1 200 OK
```

Twenty CRM was then opened externally in a browser using:

```text
http://<EC2-PUBLIC-IP>:2020
```

The application loaded successfully.

This confirmed that:
- The Docker container was running.
- Twenty CRM was responding on port 2020.
- The EC2 security group permitted the required traffic.
- The application was accessible externally.

## 9. Issues Faced and Solutions

### Disk space
**Problem:** The initial 8 GiB root volume was insufficient during setup.

**Solution:** Increased the EBS volume to 20 GiB GP3 and expanded the filesystem.

### Dependency installation/resource pressure
**Problem:** Resource limitations affected dependency installation.

**Solution:** Added 2 GiB swap and increased the instance size.

### Node.js heap out-of-memory
**Problem:** Twenty CRM initialization exceeded the memory available on `t3.micro`.

**Solution:** Upgraded to `t3.small` and used swap.

### Incorrect Twenty CLI command
A custom Dockerfile was initially tested. The command:

```bash
yarn twenty dev
```

was found to be a development synchronization/build command rather than the command that starts the Twenty server.

The official image was therefore used directly:

```text
twentycrm/twenty-app-dev:latest
```

### Slow application startup
The official container initially returned connection reset/empty replies while initialization was still running.

The following commands were used to monitor it:

```bash
docker logs --tail 50 twenty-task7
docker stats --no-stream twenty-task7
```

The logs showed server, worker, database, and cron initialization progressing. After allowing the initialization to complete, the application returned:

```text
HTTP/1.1 200 OK
```

## 10. EC2 Concepts Explored

- **AMI:** Operating system image used to launch the instance.
- **Instance type:** Determines compute and memory capacity.
- **Key pair:** Secure SSH authentication.
- **Security Group:** Controls network traffic.
- **Public IPv4:** Enables external access to exposed services.
- **EBS volume:** Block storage attached to the instance.
- **VPC/Subnet:** Provides the networking environment.
- **Instance lifecycle:** Start, stop, and terminate operations.

## 11. Security Considerations

- SSH port 22 was restricted to My IP.
- Port 2020 was restricted to My IP.
- The private key was not committed to Git.
- No GitHub Personal Access Token (PAT) was configured on EC2.
- No application/source code was pushed from EC2 to the repository.

## 13. Cleanup

After the browser verification and Loom recording were completed, the EC2 instance was **terminated** to avoid unnecessary AWS charges.

## 14. Conclusion

Twenty CRM was successfully deployed on an AWS EC2 Ubuntu instance using Docker.

The task involved practical troubleshooting of storage, memory, Node.js heap usage, and application startup. After increasing storage, adding swap, upgrading the instance type, and using the appropriate official Twenty Docker image, the application became accessible through the EC2 public IP on port 2020.

**Thank you!**
