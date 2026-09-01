# Task 5: Docker Containerization

## 1. Objective

The objective of this task was to containerize the Twenty CRM application and create a Docker-based development environment using Dockerfile and Docker Compose.

The setup includes:

* A custom Docker image for the application
* Twenty CRM service
* Environment variable configuration
* Docker networking
* Persistent volumes
* Healthcheck configuration
* Service dependency management
* Docker Compose based application startup

---

## 2. Application Structure and Dependencies

The project is a Node.js/TypeScript application using Yarn as its package manager.

Important project files used for containerization:

```text
devops-crm-project/
├── .github/
├── .yarn/
├── src/
├── package.json
├── yarn.lock
├── .yarnrc.yml
├── .nvmrc
├── Dockerfile
├── .dockerignore
└── docker-compose.yml
```

The project uses:

* Node.js 24
* Yarn 4.13.0
* TypeScript
* Twenty CRM
* Docker
* Docker Compose

The Node.js version is defined through `.nvmrc`, while the package manager version is defined in `package.json`.

---

## 3. Dockerfile

The application was containerized using a Node.js Alpine image.

The Dockerfile performs the following operations:

1. Uses Node.js 24 Alpine as the base image.
2. Sets `/app` as the working directory.
3. Copies dependency-related files first.
4. Copies the Yarn configuration.
5. Enables Corepack.
6. Installs dependencies using `yarn install --immutable`.
7. Copies the remaining application source code.
8. Builds the application using `yarn twenty dev:build`.
9. Exposes port `2020`.
10. Starts the application using `yarn twenty dev`.

### Dockerfile

```dockerfile
FROM node:24-alpine

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./
COPY .yarn ./.yarn

RUN corepack enable && yarn install --immutable

COPY . .

RUN yarn twenty dev:build

EXPOSE 2020

CMD ["yarn", "twenty", "dev"]
```

### Layer Optimization

Dependency-related files are copied before the application source code. This allows Docker to reuse the dependency installation layer when application source files change.

---

## 4. `.dockerignore`

The `.dockerignore` file prevents unnecessary files from being copied into the Docker build context.

```text
.git
.github
node_modules
dist
.twenty
coverage
__pycache__
*.log

.env
.env.*
!.env.example

Dockerfile
docker-compose.yml
.dockerignore
```

The following are excluded because they are either unnecessary inside the build context or may contain sensitive information:

* Git metadata
* GitHub workflow files
* Existing `node_modules`
* Build output
* Coverage files
* Logs
* Environment files containing secrets

---

## 5. Docker Compose Architecture

Docker Compose is used to run the application together with the Twenty CRM service.

The setup contains two services:

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
        Host machine            Host machine
```

### Services

#### `twenty`

The `twenty` service uses the official Twenty CRM development image:

```text
twentycrm/twenty-app-dev:latest
```

It exposes:

```text
2020:2020
```

The service also uses persistent Docker volumes for PostgreSQL data and local storage.

#### `app`

The `app` service is built from the project's Dockerfile.

It exposes:

```text
3000:2020
```

Inside the Docker network, the application communicates with Twenty using:

```text
http://twenty:2020
```

---

## 6. Environment Variables

Environment variables were configured without committing secrets to Git.

The local `.env` file contains:

```text
TWENTY_API_KEY=<secret>
```

The `.env` file is excluded through `.gitignore`:

```text
.env*
```

The application receives:

```text
TWENTY_API_URL=http://twenty:2020
TWENTY_API_KEY=${TWENTY_API_KEY}
```

The Twenty service uses:

```text
NODE_PORT=2020
SERVER_URL=http://localhost:2020
STORAGE_TYPE=local
```

The API key is therefore supplied through the environment rather than being hard-coded into the Dockerfile or source code.

---

## 7. Networking

Docker Compose automatically creates a project network:

```text
devops-crm-project_default
```

Both services are connected to this network.

The application accesses the Twenty service using the Docker Compose service name:

```text
http://twenty:2020
```

This is preferable to using `localhost` from the application container because `localhost` inside a container refers to that same container.

---

## 8. Ports

The following port mappings are configured:

| Service     | Container Port | Host Port |
| ----------- | -------------: | --------: |
| Twenty CRM  |           2020 |      2020 |
| Application |           2020 |      3000 |

Therefore:

```text
Twenty CRM:
http://localhost:2020

Application:
http://localhost:3000
```

---

## 9. Persistent Volumes

Two named Docker volumes are configured:

```text
twenty-data
twenty-storage
```

They are mounted as:

```text
twenty-data:
  /data/postgres

twenty-storage:
  /app/packages/twenty-server/.local-storage
```

The volumes ensure that database and application storage data can persist across container recreation.

---

## 10. Healthcheck

A Docker healthcheck was added to the Twenty service.

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

The healthcheck verifies that Twenty is actually responding on port `2020`.

A long `start_period` was intentionally configured because Twenty CRM performs database initialization, migrations, application initialization, and other startup operations before the HTTP server becomes ready.

During testing, the service initially took several minutes to become ready. The container eventually reached:

```text
Up ... (healthy)
```

and the following request returned successfully:

```text
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

---

## 11. Service Dependency

The application waits for Twenty to become healthy before starting.

```yaml
depends_on:
  twenty:
    condition: service_healthy
```

This is better than simply using:

```yaml
depends_on:
  - twenty
```

because the latter only guarantees that the container has been started, not that the application inside it is ready to accept requests.

---

## 12. Docker Compose Configuration

The final Docker Compose configuration contains:

```yaml
services:

  twenty:
    image: twentycrm/twenty-app-dev:latest
    container_name: twenty-server
    ports:
      - "2020:2020"
    restart: unless-stopped
    environment:
      NODE_PORT: 2020
      SERVER_URL: http://localhost:2020
      STORAGE_TYPE: local
    healthcheck:
      test:
        - CMD-SHELL
        - wget --no-verbose --tries=1 --spider http://127.0.0.1:2020 || exit 1
      timeout: 10s
      interval: 30s
      retries: 10
      start_period: 10m
    volumes:
      - twenty-data:/data/postgres
      - twenty-storage:/app/packages/twenty-server/.local-storage

  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: devops-crm-app
    depends_on:
      twenty:
        condition: service_healthy
    environment:
      TWENTY_API_URL: http://twenty:2020
      TWENTY_API_KEY: ${TWENTY_API_KEY}
    restart: unless-stopped
    ports:
      - "3000:2020"

volumes:
  twenty-data:
  twenty-storage:
```

---

## 13. Commands Used

### Validate Compose configuration

```bash
docker-compose config --quiet
```

The command completed successfully without configuration errors.

### Build and start containers

```bash
docker-compose up -d
```

### Check container status

```bash
docker-compose ps
```

Expected result:

```text
devops-crm-app    Up
twenty-server     Up (healthy)
```

### View logs

```bash
docker-compose logs --tail=100 twenty
```

### Check Twenty endpoint

```bash
curl -I http://localhost:2020
```

Expected:

```text
HTTP/1.1 200 OK
```

### Test application-to-Twenty connectivity

```bash
docker-compose exec app sh -c 'wget -qO- http://twenty:2020 | head -c 100'
```

The command successfully returned the Twenty CRM HTML response.

### Check environment variables

```bash
docker-compose exec app sh -c 'env | grep -E "^(TWENTY_API_URL|TWENTY_API_KEY)="'
```

### Check Docker images

```bash
docker images
```

### Check persistent volumes

```bash
docker volume ls | grep devops-crm
```

### Restart services

```bash
docker-compose restart
```

After restart, Twenty CRM required several minutes for initialization and eventually became healthy again.

---

## 14. Issues Faced and Solutions

### Issue 1: Twenty container was initially unhealthy

The healthcheck initially returned:

```text
wget: can't connect to remote host (127.0.0.1):2020
Connection refused
```

#### Cause

The Twenty application was still performing its startup process, including database initialization and application initialization. Port `2020` was not listening immediately after the container started.

#### Solution

A longer healthcheck startup period was configured:

```yaml
start_period: 10m
```

The healthcheck continues to test the service during this period without immediately treating the startup delay as a failure.

After initialization completed, the service became:

```text
twenty-server   Up (healthy)
```

---

### Issue 2: Database recovery/startup delay

PostgreSQL logs showed:

```text
database system was not properly shut down;
automatic recovery in progress
```

#### Cause

The PostgreSQL database inside the Twenty container required recovery before becoming ready.

#### Solution

The container was allowed sufficient startup time. The persistent volume was retained so that database data could continue to be used.

---

### Issue 3: Healthcheck failed while application was still starting

During startup, checking:

```bash
docker-compose exec twenty sh -c \
'wget --no-verbose --tries=1 --spider http://127.0.0.1:2020'
```

returned:

```text
Connection refused
```

Later, the same endpoint successfully returned HTTP 200.

This confirmed that the issue was startup readiness rather than an incorrect port configuration.

---

### Issue 4: Secret protection

The API key was required by the application.

#### Solution

The API key was stored in `.env` and referenced through:

```yaml
TWENTY_API_KEY: ${TWENTY_API_KEY}
```

The `.env` file is ignored by Git using:

```text
.env*
```

The Docker image history was also checked to verify that the API key was not baked into the image.

---

## 15. Docker Best Practices Followed

The following Docker practices were applied:

* Used a lightweight `node:24-alpine` base image.
* Used `.dockerignore` to reduce the build context.
* Copied dependency files before source files to improve layer caching.
* Used `yarn install --immutable` for reproducible dependency installation.
* Kept secrets outside the Docker image.
* Used environment variables for runtime configuration.
* Used Docker Compose service names for internal communication.
* Used named volumes for persistent data.
* Added a healthcheck for service readiness.
* Used `depends_on` with `service_healthy`.
* Added `restart: unless-stopped` for service recovery.
* Verified the final configuration using `docker-compose config --quiet`.

### Note on multi-stage builds and non-root execution

A multi-stage build was considered, but the current Twenty development build requires the complete Yarn/project environment during its build and runtime workflow.

The selected `node:24-alpine` image provides a smaller base image while keeping the required tooling available.

The Twenty service also uses its own official development image and internal process configuration, so user execution is controlled by the image rather than by the custom application Dockerfile.

---

## 16. Final Verification

The final Docker Compose environment was successfully started using:

```bash
docker-compose up -d
```

Final container status:

```text
devops-crm-app    Up
twenty-server     Up (healthy)
```

Twenty CRM was accessible through:

```text
http://localhost:2020
```

The application container was exposed through:

```text
http://localhost:3000
```

The Twenty endpoint returned:

```text
HTTP/1.1 200 OK
```

Application-to-Twenty connectivity was also verified from inside the application container.

Therefore, the Docker containerization setup was successfully implemented and verified.

---

## 17. Loom Demonstration

Loom Video: https://www.loom.com/share/6605107421d44967b671fa32642c967f

The video will cover:

1. Project structure
2. Dockerfile
3. `.dockerignore`
4. `docker-compose.yml`
5. Environment variable and secret handling
6. Healthcheck
7. Docker Compose architecture
8. Building the Docker image
9. Starting the services
10. Container health/status
11. Application access
12. Twenty CRM access
13. Verification commands
14. Issues faced and their solutions

The presenter’s face will remain visible throughout the video as required by the task.

---

## 18. Git Branch and Pull Request

Branch:

```text
task-5-abhishek
```

The Docker implementation and documentation will be pushed to the `devops-crm-project` repository and a Pull Request will be created against the appropriate target branch.
