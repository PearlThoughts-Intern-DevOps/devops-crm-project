# Task 7: AWS EC2 Deployment

## Objective

Deploy the `devops-crm-project` application to an AWS EC2 instance using the Docker and Docker Compose configuration created in the previous task.

The deployment uses:

- AWS EC2
- Amazon Linux 2023
- Docker
- Docker Compose
- Docker Buildx
- Twenty CRM server
- The custom `devops-crm-project` application
- An uploaded ZIP archive instead of cloning the internship repository

The application was successfully deployed and synchronized with the Twenty CRM server.

---

## Architecture

The application consists of two cooperating containers running on the EC2 instance:

```text
                    Internet
                       |
                       | TCP 2020
                       v
              +-------------------+
              |    AWS EC2        |
              |    t3.small       |
              |                   |
              |  +-------------+  |
              |  | Twenty CRM  |  |
              |  | Server      |  |
              |  | Port 2020   |  |
              |  +------+------+  |
              |         |         |
              |         | Shared  |
              |         | Network |
              |         v         |
              |  +-------------+  |
              |  | devops-crm- |  |
              |  | app         |  |
              |  | Twenty CLI  |  |
              |  +-------------+  |
              +-------------------+
```

### Services

#### `twenty`

The Twenty CRM development server.

```yaml
image: twentycrm/twenty-app-dev:latest
```

It exposes:

```text
2020:2020
```

The container uses a persistent Docker volume for server data.

#### `app`

The custom `devops-crm-project` application.

It is built from the project's Dockerfile and runs:

```bash
yarn twenty dev
```

The application uses:

```yaml
network_mode: "service:twenty"
```

This allows the application container to share the Twenty container's network namespace so that:

```text
localhost:2020
```

resolves to the Twenty server.

---

# 1. AWS EC2 Instance

An EC2 instance was created for the deployment.

| Configuration | Value |
|---|---|
| Instance name | `task7-netaji` |
| Instance type | `t3.small` |
| Operating system | Amazon Linux 2023 |
| Availability Zone | `us-east-1c` |
| Root storage | 20 GiB |
| Public IPv4 | `3.88.100.151` |
| SSH user | `ec2-user` |

The instance passed all AWS status checks and was in the `Running` state.

> **Note:** The public IPv4 address is assigned dynamically by AWS and may change if the instance is stopped and started.

---

# 2. Security Group

The EC2 instance requires SSH access for administration and TCP port `2020` for the Twenty CRM web interface.

Required inbound rules:

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 22 | My IP | SSH administration |
| TCP | 2020 | Required external access | Twenty CRM web interface |

The application was successfully accessed from a browser using:

```text
http://3.88.100.151:2020
```

---

# 3. Connect to EC2

The EC2 instance was accessed from the local WSL terminal using SSH:

```bash
ssh -i ~/.ssh/task7-netaji.pem ec2-user@3.88.100.151
```

Amazon Linux was verified after connecting.

---

# 4. Configure Swap

Because the `t3.small` instance has approximately 2 GiB of RAM, a 2 GiB swap file was configured to provide additional virtual memory during Docker image builds and application synchronization.

Commands used:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

The swap configuration was verified with:

```bash
swapon --show
```

The result showed:

```text
/swapfile    file    2G
```

---

# 5. Install Docker

Docker was installed using Amazon Linux's package manager:

```bash
sudo dnf update -y
sudo dnf install -y docker
```

The Docker service was started and enabled:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

The service was verified:

```bash
sudo systemctl is-active docker
```

Docker was also verified with:

```bash
docker --version
```

The deployed environment used Docker:

```text
Docker version 25.0.14
```

The `ec2-user` was added to the Docker group:

```bash
sudo usermod -aG docker ec2-user
newgrp docker
```

Docker functionality was tested using:

```bash
docker run hello-world
```

The test completed successfully.

---

# 6. Configure Docker Buildx

The Docker Compose build required a newer Docker Buildx version than the version initially available on Amazon Linux.

Buildx `v0.36.1` was installed manually:

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -fL \
  https://github.com/docker/buildx/releases/download/v0.36.1/buildx-v0.36.1.linux-amd64 \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
```

Version verification:

```bash
docker buildx version
```

Result:

```text
github.com/docker/buildx v0.36.1
```

---

# 7. Install Docker Compose

Docker Compose was installed as a standalone binary:

```bash
sudo curl -SL \
  https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

Version verification:

```bash
docker-compose version
```

Result:

```text
Docker Compose version v5.5.1
```

---

# 8. Transfer Application to EC2

The deployment was performed using the application ZIP rather than cloning the repository on EC2.

The project ZIP was transferred from the local WSL environment using:

```bash
scp -i ~/.ssh/task7-netaji.pem \
  ~/workspace/internship/PearlThoughts/devops-crm-project-task7.zip \
  ec2-user@3.88.100.151:/home/ec2-user/
```

The ZIP was extracted on EC2:

```bash
unzip -q ~/devops-crm-project-task7.zip
```

The project was extracted into:

```text
~/devops-crm-project
```

---

# 9. Validate Docker Compose Configuration

Before starting the services, the Compose configuration was validated:

```bash
docker-compose config
```

The configuration successfully resolved the two services:

```text
twenty
app
```

The `twenty` service exposes port:

```text
2020
```

The `app` service uses:

```yaml
network_mode: "service:twenty"
```

---

# 10. Start Twenty CRM

The Twenty CRM image was pulled:

```bash
docker-compose pull twenty
```

Twenty was then started:

```bash
docker-compose up -d twenty
```

The container was verified:

```bash
docker ps
```

The result included:

```text
twenty-crm-server
```

with:

```text
0.0.0.0:2020->2020/tcp
```

---

# 11. Verify Twenty CRM

The Twenty server was tested locally from the EC2 instance:

```bash
curl -I http://localhost:2020
```

The server returned:

```text
HTTP/1.1 200 OK
```

A second HTTP status check also returned:

```text
HTTP Status: 200
```

The service was then accessed externally from a Windows browser:

```text
http://3.88.100.151:2020
```

The Twenty CRM interface loaded successfully.

---

# 12. Start the Application

The application was built and started using:

```bash
docker-compose up -d --build app
```

Docker successfully built the application image:

```text
devops-crm-project-app
```

and started:

```text
devops-crm-app
```

---

# 13. Application Authentication

The Twenty CLI initially reported:

```text
Authentication failed.
```

The CLI supports non-interactive authentication through an API key.

The authentication command used was:

```bash
docker-compose exec app yarn twenty remote:add \
  --url http://localhost:2020 \
  --api-key 'API_KEY'
```

The API key was generated through the Twenty CRM interface.

The key was **not committed to the repository or documentation**.

Authentication succeeded with:

```text
✓ Remote "localhost" added (http://localhost:2020) via API key.
✓ Default remote set to "localhost".
```

---

# 14. Application Synchronization Issue

After authentication, the first application synchronization failed with:

```text
INVALID_PAGE_LAYOUT_WIDGET_DATA
```

The specific error was:

```text
Position layoutMode "GRID" does not match
tab layoutMode "VERTICAL_LIST"
```

The application contained a widget using a grid position:

```ts
gridPosition: {
  row: 0,
  column: 0,
  rowSpan: 12,
  columnSpan: 12,
}
```

while its parent tab was configured as:

```ts
PageLayoutTabLayoutMode.VERTICAL_LIST
```

The tab layout was changed to:

```ts
PageLayoutTabLayoutMode.GRID
```

This made the tab layout compatible with the widget's grid positioning.

The updated source was transferred to EC2 again using a ZIP archive.

---

# 15. Successful Application Synchronization

After rebuilding the application with the corrected page layout:

```bash
docker-compose up -d --build app
```

the application successfully synchronized with Twenty CRM.

The final application status was:

```text
Overall Status: ✓ Synced

Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done

Entities ✓ 7 synced
```

This confirms that the application was successfully deployed and synchronized with the Twenty CRM server.

---

# 16. Final Container Verification

The final Docker status was verified using:

```bash
docker ps
```

The two running containers were:

```text
devops-crm-app
twenty-crm-server
```

The Twenty server exposed:

```text
0.0.0.0:2020->2020/tcp
```

Compose status was also verified:

```bash
docker-compose ps
```

Both services showed:

```text
Up
```

---

# 17. Browser Verification

The deployed Twenty CRM instance was accessible externally through:

```text
http://3.88.100.151:2020
```

The custom application appeared in the Twenty CRM interface as:

```text
My app
```

The application page displayed:

```text
My app

Was installed successfully.
You can now add content to your app.
```

This confirms that the application was installed successfully into the deployed Twenty CRM instance.

---

# 18. Deployment Evidence

The following screenshots/evidence were collected during the deployment:

### AWS EC2

- EC2 instance `task7-netaji`
- Instance state: Running
- Instance type: `t3.small`
- Status checks: `3/3 checks passed`

### Twenty CRM

- Browser access to:
  ```text
  http://3.88.100.151:2020
  ```
- Twenty CRM Companies page
- `My app` page showing successful installation

### Application synchronization

Terminal output showing:

```text
Overall Status: ✓ Synced
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Entities ✓ 7 synced
```

### Docker

Terminal output showing:

```text
devops-crm-app       Up
twenty-crm-server    Up
```

---

# 19. Issues Faced and Resolutions

### 19.1 Docker Buildx version

The initially available Buildx version was not sufficient for the Compose build.

**Resolution:** Installed Buildx `v0.36.1` manually as a Docker CLI plugin.

---

### 19.2 Limited EC2 memory

The `t3.small` instance has approximately 2 GiB RAM.

**Resolution:** Added a 2 GiB swap file to provide additional virtual memory during Docker builds and application synchronization.

---

### 19.3 Browser-based CLI authentication

The Twenty CLI authentication flow attempted to open a browser and use a localhost callback:

```text
127.0.0.1:<temporary-port>/callback
```

This is inconvenient when the CLI runs inside the EC2 container.

**Resolution:** Used the CLI's supported API-key authentication:

```bash
yarn twenty remote:add --url http://localhost:2020 --api-key ...
```

---

### 19.4 Page layout synchronization error

The application synchronization initially failed because a grid-positioned widget was placed inside a vertical-list layout.

**Resolution:** Changed the parent page layout from:

```ts
PageLayoutTabLayoutMode.VERTICAL_LIST
```

to:

```ts
PageLayoutTabLayoutMode.GRID
```

The application subsequently synchronized successfully.

---

### 19.5 App container recreation

Because the application uses:

```yaml
network_mode: "service:twenty"
```

the app container was recreated manually when required:

```bash
docker-compose stop app
docker-compose rm -f app
docker-compose up -d app
```

The Twenty server and its persistent data volume were preserved.

---

# 20. Important Security Considerations

- The EC2 private key was kept outside the project repository.
- SSH access was restricted to the required source IP.
- API keys were not committed to Git.
- API keys should never be included in screenshots or documentation.
- The API key used during testing should be revoked if it was accidentally exposed.
- The EC2 instance should be stopped or terminated when the deployment environment is no longer required to avoid unnecessary AWS charges.

---

# 21. Final Result

The `devops-crm-project` was successfully deployed to AWS EC2.

Final environment:

```text
AWS EC2
 └── Amazon Linux 2023
      ├── Docker
      ├── Docker Compose
      ├── Twenty CRM Server
      │    └── Port 2020
      │
      └── devops-crm-app
           └── Twenty CLI
                └── Application synchronized
```

Final application status:

```text
✓ Application Initialization
✓ Resources Build
✓ Resources Upload
✓ Manifest Build
✓ Application Synchronization
✓ 7 Entities Synced
```

The deployed application was also successfully opened from a browser through the EC2 public IP.

---

# What I Learned

- How to provision and configure an AWS EC2 instance for a Docker-based application.
- How to install and configure Docker and Docker Compose on Amazon Linux 2023.
- How Docker Buildx affects modern Compose builds.
- How swap can help when deploying applications on a small EC2 instance.
- How to deploy an application to EC2 using an uploaded ZIP instead of cloning a repository.
- How Docker Compose can coordinate the Twenty CRM server and the custom application.
- Why `network_mode: "service:twenty"` is required when the Twenty CLI expects the server at `localhost:2020`.
- How to authenticate a containerized Twenty CLI using an API key.
- How to diagnose and resolve Twenty application synchronization errors.
- How to verify a successful deployment through Docker status, application logs, HTTP checks, AWS status checks, and browser access.
