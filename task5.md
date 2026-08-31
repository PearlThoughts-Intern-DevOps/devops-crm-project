# Task 5 — Docker Containerization

**Project:** `devops-crm-project`
**Branch:** `sakhisurakhya-task-5`

---

## 1. Understanding the Application

This repository is a **Twenty CRM app extension** built using the `twenty-sdk`. It is not a standalone HTTP server.

The `src/` directory contains the application extension code and configuration, including:

* `application-config.ts`
* `front-components/`
* `page-layouts/`
* `navigation-menu-items/`

The extension is built and synchronized with an already-running Twenty CRM server using the Twenty CLI:

```bash
yarn twenty dev
```

The actual Twenty CRM server runs separately using the official Twenty CRM Docker image:

```text
twentycrm/twenty-app-dev
```

Therefore, the Dockerization approach is to containerize the app extension's build and synchronization environment and connect it to the existing Twenty CRM server through a shared Docker network.

---

## 2. Architecture

```text
┌────────────────────────────────────┐
│          twenty-app-dev             │
│     twentycrm/twenty-app-dev        │
│                                    │
│     Twenty CRM Server              │
│     Container Port: 2020           │
│     Host Port: 2020                │
│                                    │
│     http://localhost:2020          │
└────────────────┬───────────────────┘
                 │
                 │ Docker Network
                 │ devops-crm-project_default
                 │
┌────────────────▼───────────────────┐
│       devops-crm-task5-app          │
│                                    │
│       Custom Docker image          │
│       Runs: yarn twenty dev        │
│                                    │
│       No exposed port              │
│       Syncs extension with CRM     │
└────────────────────────────────────┘
                 │
                 ▼
       ┌─────────────────────┐
       │     app-data        │
       │ /home/appuser/.twenty│
       └─────────────────────┘
```

### Components

#### twenty-app-dev

* Official Twenty CRM server container.
* Runs on container port `2020`.
* Publishes port `2020` to the host.
* Provides the actual CRM web interface.
* Maintains its own persistent database and storage volumes.

#### devops-crm-task5-app

* Custom Docker image created for this task.
* Built using the project's `Dockerfile`.
* Runs:

```bash
yarn twenty dev
```

* Builds and continuously synchronizes the CRM application extension.
* Does not expose a web port because it is a CLI synchronization process, not an HTTP server.

### Networking

Both containers communicate through:

```text
devops-crm-project_default
```

The extension container connects to the Twenty CRM server using:

```text
http://twenty-app-dev:2020
```

Docker service/container name resolution is used instead of `localhost`.

Inside the extension container, `localhost` would refer to the extension container itself.

---

## 3. Dockerfile Design

The Dockerfile uses a **multi-stage build**:

```text
builder
   ↓
app
```

### Builder Stage

The builder stage:

1. Uses Node.js Alpine.
2. Enables Corepack.
3. Copies dependency and configuration files.
4. Installs dependencies using Yarn.
5. Copies the project source.
6. Builds the Twenty application extension.

The build command is:

```bash
yarn twenty dev:build
```

The generated build output is stored in:

```text
.twenty/output
```

### Final Application Stage

The final stage:

* Uses `node:24.5.0-alpine`.
* Copies the required application files.
* Copies runtime dependencies.
* Copies the generated `.twenty/output`.
* Creates a dedicated non-root user and group.
* Assigns ownership of application files.
* Creates the Twenty CLI configuration directory.
* Runs the application as the non-root user.

### Non-root Execution

The Dockerfile creates:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
```

The application directory is owned by the new user:

```dockerfile
RUN chown -R appuser:appgroup /app
```

The Twenty CLI configuration directory is also created with the correct ownership:

```dockerfile
RUN mkdir -p /home/appuser/.twenty && chown -R appuser:appgroup /home/appuser/.twenty
```

The container switches from root to:

```dockerfile
USER appuser
```

This follows the Docker security best practice of running application processes as a non-root user.

---

## 4. Environment Variables

The Docker Compose configuration contains:

```yaml
environment:
  NODE_ENV: development
  SERVER_URL: http://twenty-app-dev:2020
  TWENTY_API_KEY: ${TWENTY_API_KEY}
```

### NODE_ENV

The Node.js environment is configured as:

```text
development
```

### SERVER_URL

The internal Docker URL of the Twenty CRM server is:

```text
http://twenty-app-dev:2020
```

This address is used for container-to-container communication.

### TWENTY_API_KEY

The API key is passed at runtime:

```yaml
TWENTY_API_KEY: ${TWENTY_API_KEY}
```

The API key is not hard-coded into the Dockerfile or committed to the repository.

The startup command uses the API key to configure the Twenty CLI remote automatically.

---

## 5. Port Configuration

The actual Twenty CRM server publishes:

```text
2020:2020
```

Therefore, the CRM interface is available from the host at:

```text
http://localhost:2020
```

The custom `devops-crm-task5-app` container does **not** expose any ports because it runs the Twenty CLI and does not provide its own HTTP server.

### Final Port Flow

```text
Browser
   │
   ▼
localhost:2020
   │
   ▼
twenty-app-dev:2020
   ▲
   │
   │ Docker network
   │
devops-crm-task5-app
```

---

## 6. Docker Compose Configuration

The final `docker-compose.yml` is:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: devops-crm-task5-app:latest
    container_name: devops-crm-task5-app
    environment:
      NODE_ENV: development
      SERVER_URL: http://twenty-app-dev:2020
      TWENTY_API_KEY: ${TWENTY_API_KEY}
    volumes:
      - app-data:/home/appuser/.twenty
    networks:
      - crm-network
    restart: unless-stopped

volumes:
  app-data:

networks:
  crm-network:
    external: true
    name: devops-crm-project_default
```

The network is declared as external because the Twenty CRM environment already creates and uses this Docker network.

---

## 7. Volumes

The application container uses the named volume:

```yaml
volumes:
  - app-data:/home/appuser/.twenty
```

This persists the Twenty CLI configuration across container restarts and rebuilds.

The volume can be checked using:

```bash
docker volume ls
```

The volume can be inspected using:

```bash
docker volume inspect devops-crm-project_app-data
```

The container mounts can be inspected using:

```bash
docker inspect devops-crm-task5-app --format "{{json .Mounts}}"
```

The Twenty CRM server maintains its own persistent volumes for database and file storage.

---

## 8. Docker Ignore Configuration

The `.dockerignore` file excludes unnecessary and sensitive files from the Docker build context:

```text
node_modules

.twenty/output

.git

.github

.env

.env.*

*.log

.DS_Store

coverage

dist

build

.vscode

.idea

README.md

CLAUDE.md

AGENTS.md
```

This reduces the Docker build context and prevents unnecessary or sensitive files from being copied into the Docker image.

---

## 9. Commands Used

### Build and Start

```bash
docker compose up -d --build
```

### Check Running Containers

```bash
docker ps
```

### Follow Application Logs

```bash
docker logs -f devops-crm-task5-app
```

### Check Recent Logs

```bash
docker logs devops-crm-task5-app --tail 30
```

### Check Docker Volumes

```bash
docker volume ls
```

### Inspect the Volume

```bash
docker volume inspect devops-crm-project_app-data
```

### Inspect Container Mounts

```bash
docker inspect devops-crm-task5-app --format "{{json .Mounts}}"
```

### Stop the Containers

```bash
docker compose down
```

This removes the Compose container while keeping the named volume.

### Complete Reset

```bash
docker compose down -v
```

This also removes the named volume.

---

## 10. Build Verification

The Docker image was successfully built using:

```bash
docker compose up -d --build
```

The build completed successfully with:

```text
Image devops-crm-task5-app:latest Built
Container devops-crm-task5-app Started
```

The application extension build also completed successfully:

```text
Building application...
Running typecheck...
✓ Build succeeded
```

---

## 11. Container Verification

The running containers were verified using:

```bash
docker ps
```

The following containers were running:

```text
devops-crm-task5-app
twenty-app-dev
```

The Twenty CRM server was available through:

```text
0.0.0.0:2020->2020/tcp
```

The custom application container did not expose a host port, which is expected because it runs the Twenty CLI rather than an HTTP server.

---

## 12. Application Synchronization Verification

The application container logs showed:

```text
Manifest checksums set
Manifest saved to output directory
Computing metadata plan
Syncing manifest
No metadata changes
✓ Synced
```

The Twenty CLI also reported:

```text
Application
Name: My app
Overall Status: ✓ Synced
```

The following operations were successfully completed:

```text
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done
```

The application reported:

```text
Entities ✓ 7 synced
```

---

## 13. Twenty CRM UI Verification

The Twenty CRM web interface was successfully opened at:

```text
http://localhost:2020
```

The installed application extension was visible in the Twenty CRM interface as:

```text
My app
```

The application page was successfully accessible from the Twenty CRM interface.

This confirms that:

1. The Twenty CRM server is running.
2. The custom Docker container can communicate with it.
3. The application extension was successfully synchronized.
4. The application is available through the CRM UI.

---

## 14. Non-root User Verification

The container user was verified using:

```bash
docker exec devops-crm-task5-app id
```

The result was:

```text
uid=100(appuser) gid=101(appgroup) groups=101(appgroup)
```

This confirms that the container is running as `appuser` instead of `root`.

The HOME directory was also verified using:

```bash
docker exec devops-crm-task5-app sh -c "echo $HOME"
```

The result was:

```text
/home/appuser
```

This confirms that the Twenty CLI configuration directory is correctly located under the non-root user's home directory.

---

## 15. Issues Faced and Solutions

### Issue 1 — The repository is an app extension, not a standalone server

**Problem:**

The repository does not contain its own HTTP server. It is a Twenty CRM application extension.

**Solution:**

The Docker image was designed to build and synchronize the extension while connecting to the existing Twenty CRM server.

The actual CRM server runs separately in:

```text
twentycrm/twenty-app-dev
```

---

### Issue 2 — Incorrect port mapping (`2022:2020`)

**Problem:**

Initially, port `2022:2020` was mapped to the custom application container under the assumption that it would serve the CRM UI.

However, the custom container only runs:

```bash
yarn twenty dev
```

and does not provide an HTTP server.

**Diagnosis:**

The CRM UI was being served by the `twenty-app-dev` container on port `2020`.

**Solution:**

The unnecessary port mapping was removed from the custom application container.

The CRM UI is correctly accessed through:

```text
http://localhost:2020
```

---

### Issue 3 — Twenty CLI remote connection problem

**Problem:**

The Twenty CLI `remote:add` command reported a connection error even though the Twenty CRM server was reachable from inside the Docker container.

**Diagnosis:**

Connectivity was verified from inside the container.

The Twenty server was reachable through:

```text
http://twenty-app-dev:2020
```

The API key was also valid.

Therefore, the issue was isolated to the CLI's remote connection/pre-flight behavior rather than Docker networking.

**Solution:**

The Twenty CLI configuration was written directly to:

```text
/home/appuser/.twenty/config.json
```

The container startup command automatically creates the configuration using the supplied `TWENTY_API_KEY`.

The application subsequently synchronized successfully with the Twenty CRM server.

---

### Issue 4 — CLI configuration persistence

**Problem:**

Without a volume, the Twenty CLI configuration would be lost when the container was recreated.

**Solution:**

A named volume was added:

```yaml
volumes:
  - app-data:/home/appuser/.twenty
```

This allows the CLI configuration and authentication information to persist across container restarts and rebuilds.

---

### Issue 5 — Permission error after switching to non-root user

**Problem:**

After changing the container to use `appuser`, the CLI could not write to:

```text
/home/appuser/.twenty
```

This resulted in a permission error:

```text
EACCES: permission denied
```

**Solution:**

The Dockerfile creates the directory and assigns ownership:

```dockerfile
RUN mkdir -p /home/appuser/.twenty && chown -R appuser:appgroup /home/appuser/.twenty
```

The container then runs as:

```dockerfile
USER appuser
```

The previous volume was removed and recreated so that the correct permissions could be applied.

The final container was successfully verified using:

```bash
docker exec devops-crm-task5-app id
```

---

## 16. Final Dockerfile

The final Dockerfile used for Task 5 is:

```dockerfile
FROM node:24.5.0-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts .oxlintrc.json ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


FROM node:24.5.0-alpine AS app

WORKDIR /app

RUN corepack enable

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/tsconfig.spec.json ./
COPY --from=builder /app/vitest.config.ts ./
COPY --from=builder /app/vitest.unit.config.ts ./
COPY --from=builder /app/.oxlintrc.json ./
COPY --from=builder /app/.twenty/output ./.twenty/output

RUN chown -R appuser:appgroup /app
RUN mkdir -p /home/appuser/.twenty && chown -R appuser:appgroup /home/appuser/.twenty

ENV HOME=/home/appuser
ENV NODE_ENV=development

USER appuser

CMD ["sh", "-c", "node -e \"const fs=require('fs'),path=require('path'),p=path.join(process.env.HOME,'.twenty/config.json');fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,JSON.stringify({version:1,remotes:{local:{apiUrl:'http://twenty-app-dev:2020',apiKey:process.env.TWENTY_API_KEY}},defaultRemote:'local'},null,2))\" && yarn twenty dev"]
```

---

## 17. Final Result

The Docker containerization task was successfully completed.

The final setup provides:

* Multi-stage Docker build
* Alpine-based Node.js image
* Dependency layer caching
* `.dockerignore`
* Docker Compose configuration
* Environment variable configuration
* Shared Docker networking
* Named volume for CLI configuration
* Non-root user execution
* Successful Docker image build
* Successful container startup
* Successful Twenty CLI synchronization
* Successful `✓ Synced` verification
* Successful Twenty CRM UI verification
* Successful non-root execution verification

The CRM UI is available at:

```text
http://localhost:2020
```

The application extension successfully synchronizes with the Twenty CRM server through the Docker network.

---

## 18. Loom Video

**Loom Link:** `<add-your-Loom-link-here>`

The Loom video should demonstrate:

1. Project structure.
2. `Dockerfile`.
3. `.dockerignore`.
4. `docker-compose.yml`.
5. Running:

```bash
docker compose up -d --build
```

6. Running:

```bash
docker ps
```

7. Showing both containers running.
8. Running:

```bash
docker logs devops-crm-task5-app --tail 30
```

9. Showing:

```text
✓ Synced
```

10. Opening:

```text
http://localhost:2020
```

11. Showing the **My app** application in Twenty CRM.
12. Showing the non-root verification:

```bash
docker exec devops-crm-task5-app id
```

13. Explaining why the custom container does not expose port `2020` or `2022`.
14. Explaining the Docker network, environment variables, volume, and non-root configuration.

---

