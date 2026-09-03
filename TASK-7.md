# Task 7: AWS EC2 – Twenty CRM Deployment

## 1. Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance and understand the basic concepts of EC2, networking, Security Groups, storage and remote server administration.

The deployment includes:

* AWS EC2 instance configuration
* Amazon Linux 2023
* Security Group configuration
* SSH-based remote access
* Docker installation
* Docker Compose installation
* Docker Buildx compatibility
* Swap memory configuration
* GitHub repository setup
* Twenty CRM deployment
* Docker networking
* Persistent Docker volumes
* Healthcheck configuration
* Application and service verification
* Troubleshooting deployment issues

---

## 2. EC2 Instance Configuration

The Twenty CRM application was deployed on an AWS EC2 instance.

The following configuration was used:

| Configuration    | Value               |
| ---------------- | ------------------- |
| AMI              | Amazon Linux 2023   |
| Instance Type    | t3.small            |
| Architecture     | x86_64              |
| vCPUs            | 2                   |
| Memory           | Approximately 2 GiB |
| Storage          | 20 GiB EBS          |
| Operating System | Amazon Linux 2023   |
| Application Port | 2020                |

The `t3.small` instance was selected as a small and cost-efficient instance suitable for the task environment.

Since Twenty CRM is relatively memory-intensive, additional swap space was configured to improve stability during application startup.

---

## 3. Amazon EC2

Amazon Elastic Compute Cloud (EC2) provides resizable virtual servers in the AWS cloud.

For this task, EC2 was used as the remote server on which the Twenty CRM application and its Docker containers were deployed.

The main EC2 concepts used during this task were:

* AMI
* Instance Type
* EBS Storage
* Public IP
* Security Groups
* SSH access
* Instance lifecycle management

The EC2 instance provided the compute environment required to run the containerized application.

---

## 4. Security Group Configuration

A Security Group was configured to control inbound network access to the EC2 instance.

The main ports used were:

| Port | Protocol | Purpose               |
| ---- | -------- | --------------------- |
| 22   | TCP      | SSH access            |
| 2020 | TCP      | Twenty CRM web access |

Port `22` was required to connect to the EC2 server using SSH.

Port `2020` was exposed so that Twenty CRM could be accessed through the EC2 public IP address.

For a production environment, Security Group rules should be restricted to trusted source IP addresses or controlled through an appropriate load balancer and network architecture.

---

## 5. Connecting to EC2

The EC2 instance was accessed remotely using SSH through MobaXterm.

After connecting successfully, the server environment was verified using:

```bash
whoami
```

The command confirmed the EC2 user:

```text
ec2-user
```

System information was checked using:

```bash
uname -a
```

This provided information about the Amazon Linux kernel and system architecture.

---

## 6. EC2 System Resources

The available memory and storage were checked before deploying the application.

### Check Memory

```bash
free -h
```

The instance provides approximately 2 GiB of RAM.

### Check Disk Space

```bash
df -h
```

The EC2 instance was configured with 20 GiB of EBS storage.

Because Twenty CRM can consume a significant amount of memory during startup, swap space was configured on the instance.

---

## 7. Docker Installation

Docker was installed on the EC2 instance to run the application in containers.

The Docker installation was verified using:

```bash
docker --version
```

The installed Docker environment reported:

```text
Docker Client: 25.0.14
Docker Server: 25.0.16
```

Docker provides the container runtime required for the Twenty CRM deployment.

---

## 8. Docker Compose Installation

Docker Compose was installed to manage the multiple services required by the project.

The installed version was verified using:

```bash
docker-compose version
```

The environment used:

```text
Docker Compose v5.5.0
```

Docker Compose allows the application services, networking, environment variables, volumes and healthchecks to be defined in a single configuration file.

---

## 9. Docker Buildx Compatibility

During the initial deployment, Docker Compose reported a Buildx compatibility error:

```text
compose build requires buildx 0.17.0 or later
```

The initially available Buildx version was older than the required version.

The existing Buildx installation was replaced with a compatible version.

The final Buildx version was verified using:

```bash
docker buildx version
```

The final environment reported:

```text
github.com/docker/buildx v0.17.1
```

After upgrading Buildx, the Docker Compose build completed successfully.

---

## 10. Swap Memory Configuration

Because the `t3.small` instance has approximately 2 GiB of RAM and Twenty CRM requires significant memory during startup, a 2 GiB swap file was configured.

The swap file was created at:

```text
/swapfile
```

The swap configuration included:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

The configuration was also added to `/etc/fstab` so that the swap could persist after reboot.

Swap was verified using:

```bash
swapon --show
```

The resulting configuration showed:

```text
/swapfile    file    2G
```

The memory configuration was verified using:

```bash
free -h
```

The system therefore had approximately 2 GiB physical memory along with 2 GiB swap space.

---

## 11. Project Setup

The project repository is maintained in GitHub.

The standard deployment workflow is to clone the required repository on the EC2 instance and work from the appropriate task branch.

The project directory used for deployment was:

```text
/home/ec2-user/devops-crm-project
```

The Git remote was verified using:

```bash
git remote -v
```

The Task 7 branch was:

```text
abhishek-task-7
```

The active branch was verified using:

```bash
git branch --show-current
```

---

## 12. Environment Configuration

Runtime configuration was handled using environment variables.

The `.env` file was kept outside version control because it contains sensitive configuration such as the Twenty CRM API key.

The application uses:

```text
TWENTY_API_URL=http://twenty:2020
TWENTY_API_KEY=<secret>
```

The secret API key was not hard-coded into the Dockerfile or source code and was not included in the Git repository.

The `.env` file was also protected with appropriate file permissions.

---

## 13. Docker Compose Architecture

Docker Compose was used to run the application and Twenty CRM together.

The deployment contains two primary services:

```text
                 Docker Compose Network
                         |
             +-----------+-----------+
             |                       |
             v                       v
      +-------------+         +---------------+
      |     app     |         |     twenty    |
      |             |         |               |
      | Node/Yarn   | ------> | Twenty CRM    |
      | Application |         | Server        |
      +-------------+         +---------------+
             |                       |
             |                       |
          Port 3000               Port 2020
             |                       |
             v                       v
        EC2 Host                EC2 Host
```

### `twenty` Service

The Twenty CRM service uses:

```text
twentycrm/twenty-app-dev:latest
```

It runs Twenty CRM on port:

```text
2020
```

The service also uses named Docker volumes for persistent application data.

### `app` Service

The application service is built using the project's Dockerfile.

The container listens internally on:

```text
2020
```

and is exposed on the EC2 host through:

```text
3000
```

The application communicates with Twenty using:

```text
http://twenty:2020
```

---

## 14. Docker Networking

Docker Compose automatically creates a project network:

```text
devops-crm-project_default
```

Both services are connected to this network.

The application communicates with Twenty using the Docker Compose service name:

```text
http://twenty:2020
```

Using the service name allows Docker's internal DNS to resolve the Twenty container.

This is preferable to using `localhost` because `localhost` inside a container refers to that same container.

The Docker network was verified using:

```bash
docker network ls
```

and:

```bash
docker network inspect devops-crm-project_default
```

---

## 15. Port Mapping

The deployment uses the following port mappings:

| Service     | Container Port | EC2 Host Port |
| ----------- | -------------: | ------------: |
| Twenty CRM  |           2020 |          2020 |
| Application |           2020 |          3000 |

Therefore, Twenty CRM can be accessed externally through:

```text
http://<EC2-Public-IP>:2020
```

The application service is exposed through:

```text
http://<EC2-Public-IP>:3000
```

---

## 16. Persistent Volumes

The Twenty CRM deployment uses named Docker volumes to persist application data.

The configured volumes are:

```text
twenty-data
twenty-storage
```

They are mounted inside the Twenty container as:

```text
twenty-data
    /data/postgres

twenty-storage
    /app/packages/twenty-server/.local-storage
```

Persistent volumes allow data to remain available when containers are recreated.

The volumes were verified using:

```bash
docker volume ls
```

---

## 17. Healthcheck

A Docker healthcheck was configured for the Twenty CRM service.

The healthcheck verifies whether Twenty CRM is responding on port `2020`.

The configuration uses:

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - wget --no-verbose --tries=1 --spider http://127.0.0.1:2020 || exit 1
  timeout: 10s
  interval: 30s
  retries: 10
  start_period: 10m
```

A longer `start_period` was configured because Twenty CRM performs several initialization operations before becoming ready.

Once initialization was completed, the container reached:

```text
Up (healthy)
```

---

## 18. Service Dependency

The application service depends on the Twenty CRM service.

The Compose configuration uses:

```yaml
depends_on:
  twenty:
    condition: service_healthy
```

This ensures that the application waits for Twenty to pass its healthcheck before starting.

This is more reliable than simply checking whether the Twenty container has started, because a running container does not necessarily mean that the application inside it is ready.

---

## 19. Docker Compose Deployment

Before starting the deployment, the Compose configuration was validated using:

```bash
docker-compose config --quiet
```

The configuration completed successfully without errors.

The services were then started using:

```bash
docker-compose up -d
```

Docker Compose created the required:

* Containers
* Network
* Volumes
* Application image

The final container status was checked using:

```bash
docker-compose ps
```

The resulting state showed:

```text
devops-crm-app    Up
twenty-server     Up (healthy)
```

---

## 20. Deployment Verification

### Check Container Status

```bash
docker-compose ps
```

The Twenty CRM container was running in the healthy state.

### Check Twenty Health Endpoint

```bash
curl -s http://localhost:2020/healthz
```

The endpoint returned:

```json
{"status":"ok","info":{},"error":{},"details":{}}
```

This confirmed that the Twenty CRM server was responding successfully.

### Check Application-to-Twenty Connectivity

Connectivity from the application container was verified using:

```bash
docker exec devops-crm-app sh -c \
'wget -qO- http://twenty:2020/healthz'
```

The request returned the Twenty health response.

Docker DNS resolution was also checked using:

```bash
docker exec devops-crm-app sh -c 'getent hosts twenty'
```

The `twenty` service was successfully resolved to its Docker network IP address.

---

## 21. Browser Verification

Twenty CRM was verified externally using the EC2 public IP and port `2020`.

The application was accessed through:

```text
http://<EC2-Public-IP>:2020
```

The Twenty CRM web interface loaded successfully in the browser.

This verified the complete path:

```text
Internet
    |
    v
EC2 Public IP
    |
    v
Security Group : 2020
    |
    v
Docker Host
    |
    v
Twenty CRM Container : 2020
```

---

## 22. Container Resource Usage

Container resource consumption was checked using:

```bash
docker stats --no-stream
```

The Twenty CRM container consumed a significant portion of the available memory on the `t3.small` instance.

This demonstrated the importance of monitoring resource usage when deploying memory-intensive applications on small EC2 instance types.

The configured swap space helped provide additional virtual memory during periods of high memory usage.

---

## 23. Issues Faced and Solutions

### Issue 1: Docker Buildx Version Compatibility

During the initial Docker Compose deployment, the following error was encountered:

```text
compose build requires buildx 0.17.0 or later
```

#### Cause

The installed Buildx version was older than the version required by the Docker Compose build process.

#### Solution

Buildx was upgraded to version:

```text
v0.17.1
```

The version was verified using:

```bash
docker buildx version
```

After the upgrade, the Docker image build completed successfully.

---

### Issue 2: Limited EC2 Memory

The `t3.small` instance provides approximately 2 GiB of RAM.

Twenty CRM consumed a significant amount of memory during startup.

#### Solution

A 2 GiB swap file was configured on the EC2 instance.

The swap configuration was verified using:

```bash
swapon --show
```

This provided additional virtual memory and improved the stability of the deployment.

---

### Issue 3: Twenty CRM Startup Delay

During initial startup, the Twenty CRM healthcheck temporarily failed because the application was still initializing.

The endpoint initially returned a connection error, but later became available.

#### Cause

Twenty CRM performs application initialization and database-related operations before the HTTP service becomes ready.

#### Solution

A healthcheck with an extended:

```yaml
start_period: 10m
```

was configured.

After the startup process completed, the container reached:

```text
Up (healthy)
```

and the health endpoint returned:

```json
{"status":"ok"}
```

---

### Issue 4: Application Initialization Error

The custom application container reported an initialization error while starting.

The Docker networking configuration was separately verified.

The application container was able to:

* Resolve the `twenty` Docker service
* Connect to `http://twenty:2020`
* Receive a successful Twenty health response

Therefore, basic Docker networking and Twenty server availability were confirmed.

The remaining initialization issue appears to be related to the application's additional initialization or authentication flow rather than basic container-to-container connectivity.

The main Twenty CRM deployment remained healthy and accessible.

---

## 24. Security Considerations

The following security practices were considered during the deployment:

* API keys were kept outside the Git repository.
* Secrets were provided through environment variables.
* The `.env` file was not committed to Git.
* Sensitive API key values were not exposed during the demonstration.
* SSH access should be restricted to trusted IP addresses in a production environment.
* Public application ports should only be opened when required.
* Port `2020` was exposed for temporary task demonstration and should be restricted or removed after the task.
* Production deployments should use HTTPS and appropriate network security controls.

For a production environment, additional AWS services and controls such as IAM roles, private subnets, Application Load Balancer, HTTPS certificates, monitoring and centralized logging could also be considered.

---

## 25. EC2 Concepts Learned

Through this task, the following EC2 concepts were practically explored.

### AMI

An Amazon Machine Image defines the operating system and initial software environment used to launch an EC2 instance.

### Instance Type

The instance type determines the compute resources available to the server, including CPU and memory.

The selected instance type was:

```text
t3.small
```

### EBS

Amazon Elastic Block Store provides persistent block storage for EC2 instances.

The instance was configured with:

```text
20 GiB
```

of storage.

### Security Group

A Security Group acts as a virtual firewall and controls network traffic to and from the EC2 instance.

### Public IP

The EC2 public IP provides a network endpoint through which externally accessible services can be reached.

### SSH

SSH provides secure remote access for administering the Linux server.

### Instance Lifecycle

EC2 instances can be:

```text
Running
   ↓
Stopped
   ↓
Started
```

or permanently:

```text
Terminated
```

Stopping an instance preserves its configuration and attached EBS volumes, while termination permanently removes the instance according to the configured storage behavior.

---

## 26. Cleanup

After completing the demonstration and review requirements, the deployment resources should be cleaned up to avoid unnecessary AWS charges.

Docker Compose services can be stopped using:

```bash
docker-compose down
```

The EC2 instance can then be stopped if it may be required again for review.

Once the task, Pull Request and Loom demonstration no longer require the environment, the EC2 instance can be terminated.

Temporary Security Group rules, such as unrestricted access to port `2020`, should also be removed or restricted after the demonstration.

---

## 27. Loom Demonstration

Loom Video:

https://www.loom.com/share/045e862ba4304c828f005fc6d530797b

The video demonstrates:

1. AWS EC2 instance configuration
2. EC2 instance type and storage
3. Security Group configuration
4. SSH connection using MobaXterm
5. Docker installation and verification
6. Docker Compose installation
7. EC2 memory and swap configuration
8. GitHub project and Task 7 branch
9. Docker Compose configuration
10. Twenty CRM deployment
11. Container status and healthcheck
12. Docker networking
13. Twenty CRM health verification
14. Browser-based application verification
15. Deployment issues and their solutions
16. Basic EC2 concepts
17. Security considerations

---

## 28. Git Branch and Pull Request

Task 7 branch:

```text
abhishek-task-7
```
---

## 29. Conclusion

The Twenty CRM application was successfully deployed on an AWS EC2 instance using Docker and Docker Compose.

During this task, an Amazon Linux 2023 EC2 instance was configured with the required compute, storage and network settings. Docker and Docker Compose were installed and configured, and a Docker Buildx compatibility issue was resolved.

A 2 GiB swap file was also configured to improve stability on the memory-constrained `t3.small` instance.

The Twenty CRM container successfully reached the healthy state, the health endpoint returned a successful response, Docker container-to-container connectivity was verified, and the Twenty CRM web interface was successfully accessed through the EC2 public IP.

This task provided practical experience with AWS EC2, Security Groups, SSH, EBS storage, Docker, Docker Compose, container networking, healthchecks, resource management and basic cloud deployment troubleshooting.
