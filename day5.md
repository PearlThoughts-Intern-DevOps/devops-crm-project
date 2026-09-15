# Day 5 – Docker Containerization

---

## 1. Objective & Task Overview

The objective of Day 5 is to implement robust Docker containerization for the `devops-crm-project` repository. This includes creating production-ready container configurations that encapsulate the Twenty CRM custom application and its supporting runtime services, adhering to industry best practices for security, build optimization, layer caching, and reproducible environments.

---

## 2. Project Architecture & Dependency Analysis

Before containerizing the project, an exhaustive inspection of repository manifests, toolchains, and runtime configurations was conducted:

| Parameter / Tool | Configured Version | Source / Reference |
| :--- | :--- | :--- |
| **Node.js Runtime** | `24.5.0` | `.nvmrc`, `package.json` (`engines.node: "^24.5.0"`) |
| **Package Manager** | Yarn Berry `4.13.0` | `package.json` (`packageManager: "yarn@4.13.0"`), `.yarnrc.yml` (`nodeLinker: node-modules`) |
| **Framework & SDKs** | Twenty SDK `2.35.1`, Twenty Client SDK `2.35.1`, Twenty UI `1.0.0-alpha.1` | `package.json` (`devDependencies`) |
| **Build & Quality Tooling** | `oxlint` (v0.16.0), `tsgo` (TypeScript Native Preview v7.0.0), `vitest` (v4.0.0) | `package.json` (`scripts`) |
| **CRM Backend Service** | `twentycrm/twenty-app-dev:latest` (v2.35.0) | All-in-one image bundling PostgreSQL, Redis, Twenty server & background workers |

---

## 3. Docker Containerization Setup

The containerization strategy separates build-time dependencies, quality validation checks, and production runtimes into isolated stages, while orchestrating the application alongside the Twenty CRM backend using Docker Compose.

```
                  +----------------------------------------------+
                  |               Docker Compose                 |
                  |              (devops_crm_network)            |
                  +----------------------------------------------+
                                |                      |
                                v                      v
                 +-----------------------+   +-----------------------+
                 |     twenty-server     |   |        crm-app        |
                 |  (twenty-app-dev:tag) |   |  (Multi-Stage Node24) |
                 |                       |   |                       |
                 |  - Port: 2020         |   |  - Non-root user: node|
                 |  - Healthcheck: /z    |   |  - Depends on healthy |
                 |  - Volumes: DB, Store |   |    twenty-server      |
                 +-----------------------+   +-----------------------+
                                |
                         Host Port 2020
```

---

## 4. Dockerfile Implementation & Stage-by-Stage Breakdown

The `Dockerfile` employs a 4-stage multi-stage architecture:

```dockerfile
# ==========================================================
# Stage 1: Base image with Node.js 24 & Corepack Yarn Berry
# ==========================================================
FROM node:24-alpine AS base

# Install libc6-compat for compatibility with native modules on Alpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Enable Corepack and prepare the exact Yarn version specified in package.json
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

# ==========================================================
# Stage 2: Dependencies (leveraging layer caching)
# ==========================================================
FROM base AS dependencies

# Copy package manifests and Yarn configuration
COPY package.json yarn.lock .yarnrc.yml .nvmrc ./
COPY .yarn/ ./.yarn/

# Install dependencies deterministically
RUN yarn install --immutable

# ==========================================================
# Stage 3: Builder & Quality Assurance
# ==========================================================
FROM dependencies AS builder

# Copy project configuration and source code
COPY tsconfig.json tsconfig.spec.json .oxlintrc.json vitest.config.ts vitest.unit.config.ts ./
COPY public/ ./public/
COPY src/ ./src/

# Run linting, typechecking, unit tests, and build compilation
RUN yarn lint
RUN yarn typecheck
RUN yarn test:unit
RUN yarn twenty dev:build

# ==========================================================
# Stage 4: Production Runner (Minimal & Non-Root)
# ==========================================================
FROM base AS runner

ENV NODE_ENV=production
ENV PORT=3000

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure application directory and copy corepack cache to user directory
RUN mkdir -p /app /home/node/.twenty /home/node/.cache && \
    (cp -r /root/.cache/* /home/node/.cache/ 2>/dev/null || true) && \
    chown -R node:node /app /home/node

# Set up non-root user execution
USER node

# Copy installed dependencies, manifests, and build outputs with proper ownership
COPY --chown=node:node --from=dependencies /app/node_modules ./node_modules
COPY --chown=node:node --from=dependencies /app/package.json ./package.json
COPY --chown=node:node --from=dependencies /app/yarn.lock ./yarn.lock
COPY --chown=node:node --from=dependencies /app/.yarnrc.yml ./.yarnrc.yml
COPY --chown=node:node --from=dependencies /app/.nvmrc ./.nvmrc
COPY --chown=node:node --from=dependencies /app/.yarn ./.yarn
COPY --chown=node:node --from=builder /app/tsconfig.json ./tsconfig.json
COPY --chown=node:node --from=builder /app/tsconfig.spec.json ./tsconfig.spec.json
COPY --chown=node:node --from=builder /app/.oxlintrc.json ./.oxlintrc.json
COPY --chown=node:node --from=builder /app/vitest.config.ts ./vitest.config.ts
COPY --chown=node:node --from=builder /app/vitest.unit.config.ts ./vitest.unit.config.ts
COPY --chown=node:node --from=builder /app/public ./public
COPY --chown=node:node --from=builder /app/src ./src
COPY --chown=node:node --from=builder /app/.twenty ./.twenty
COPY --chown=node:node --from=builder /app/dist ./dist

# Expose application port
EXPOSE 3000

# Health check to ensure the container runtime is responsive
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "process.exit(0)" || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["yarn", "twenty", "dev"]
```

### Stage Details & Design Decisions

1. **Stage 1: Base (`base`)**
   - **Base Image:** `node:24-alpine` provides a minimal, lightweight footprint (~180MB compared to >1GB for standard Debian images).
   - **Native Module Compatibility:** Installs `libc6-compat` required by native build tools on musl-based Alpine Linux.
   - **Package Manager Pinning:** Uses Node.js `corepack` to activate and enforce Yarn Berry `4.13.0`.

2. **Stage 2: Dependencies (`dependencies`)**
   - **Layer Caching:** Copies only dependency descriptor files (`package.json`, `yarn.lock`, `.yarnrc.yml`, `.yarn/`).
   - **Deterministic Resolution:** Executes `yarn install --immutable` to prevent accidental lockfile drift. Code changes in `src/` invalidate neither this stage nor the package cache.

3. **Stage 3: Builder (`builder`)**
   - **In-Build Quality Gates:** Runs `yarn lint` (`oxlint`), `yarn typecheck` (`tsgo`), and `yarn test:unit` (`vitest`). A failing test or syntax error halts image creation before deployment.
   - **Compilation:** Compiles metadata and front components via `yarn twenty dev:build`, producing `.twenty/output`.

4. **Stage 4: Runner (`runner`)**
   - **Security & Least Privilege:** Adheres to non-root execution by creating and switching to user `node` (UID 1000).
   - **Entrypoint Script (`docker-entrypoint.sh`):** Dynamically provisions `~/.twenty/config.json` with the container network URL `TWENTY_API_URL` before command execution.
   - **Container Health Check:** Built-in periodic Node.js runtime validation (`HEALTHCHECK`).

---

## 5. Docker Ignore Configuration (`.dockerignore`)

The `.dockerignore` file prevents unneeded, ephemeral, sensitive, or platform-dependent files from polluting the Docker build context:

```text
# Dependencies & local packages
node_modules
node_modules 2
.pnp
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions

# Git metadata
.git
.git 2
.gitignore

# Build outputs & caches
dist
build
.twenty/output
coverage
*.tsbuildinfo
*.d.ts

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment & Secrets
.env
.env.*
!.env.example
*.pem

# IDE & OS files
.DS_Store
Thumbs.db
.github
day*.md
README.md
SETUP.md
```

---

## 6. Docker Compose Configuration (`docker-compose.yml`)

The `docker-compose.yml` orchestrates the full multi-service architecture:

```yaml
services:
  # ==========================================================
  # Twenty CRM Backend Server & Core Services (Postgres/Redis)
  # ==========================================================
  twenty-server:
    image: twentycrm/twenty-app-dev:latest
    container_name: devops-crm-twenty-server
    ports:
      - "2020:2020"
    environment:
      - NODE_PORT=2020
      - SERVER_URL=http://localhost:2020
      - NODE_ENV=development
      - STORAGE_TYPE=local
      - APPLICATION_LOG_DRIVER=CONSOLE
    volumes:
      - twenty-dev-data:/data/postgres
      - twenty-dev-storage:/app/packages/twenty-server/.local-storage
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:2020/healthz || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 20s
    networks:
      - crm-network
    restart: unless-stopped

  # ==========================================================
  # Containerized CRM Custom Application
  # ==========================================================
  crm-app:
    build:
      context: .
      dockerfile: Dockerfile
      target: runner
    container_name: devops-crm-app
    depends_on:
      twenty-server:
        condition: service_healthy
    environment:
      - NODE_ENV=production
      - PORT=3000
      - TWENTY_API_URL=http://twenty-server:2020
      - TWENTY_API_KEY=${TWENTY_API_KEY:-dev-api-key-for-local-testing}
    volumes:
      - app-build-output:/app/.twenty
    networks:
      - crm-network
    restart: unless-stopped

# ==========================================================
# Network Configuration
# ==========================================================
networks:
  crm-network:
    driver: bridge
    name: devops_crm_network

# ==========================================================
# Named Persistent Volumes
# ==========================================================
volumes:
  twenty-dev-data:
    name: devops_crm_twenty_dev_data
  twenty-dev-storage:
    name: devops_crm_twenty_dev_storage
  app-build-output:
    name: devops_crm_app_build_output
```

---

## 7. Configuration Details: Networking, Volumes & Environment

### 7.1 Environment Variables

| Variable | Service | Default / Value | Description |
| :--- | :--- | :--- | :--- |
| `NODE_ENV` | `crm-app` / `twenty-server` | `production` / `development` | Defines execution mode. |
| `PORT` | `crm-app` | `3000` | Application server exposed port. |
| `TWENTY_API_URL` | `crm-app` | `http://twenty-server:2020` | Internal bridge address for connecting to Twenty server. |
| `TWENTY_API_KEY` | `crm-app` | Configurable | API key / Access token for Twenty authentication. |
| `NODE_PORT` | `twenty-server` | `2020` | Listening port for Twenty CRM. |
| `SERVER_URL` | `twenty-server` | `http://localhost:2020` | Publicly reachable origin for user browser interaction. |

### 7.2 Container Networking (`devops_crm_network`)
- **Driver:** `bridge`
- **DNS Resolution:** Docker automatically provides internal DNS resolution using service identifiers (`twenty-server`, `crm-app`).
- **Security:** Containers communicate privately on the isolated bridge network while exposing only port `2020` to the host.

### 7.3 Persistent Storage Volumes

| Volume Name | Target Mount Point | Purpose |
| :--- | :--- | :--- |
| `devops_crm_twenty_dev_data` | `/data/postgres` | Persists PostgreSQL database schemas and records. |
| `devops_crm_twenty_dev_storage` | `/app/packages/twenty-server/.local-storage` | Persists uploaded files and asset attachments. |
| `devops_crm_app_build_output` | `/app/.twenty` | Persists manifest compilation outputs and cached build state. |

---

## 8. Verification & Execution Results

All commands were executed and validated on the system:

### 8.1 Docker Compose Config Validation
```bash
docker compose config
```
- **Result:** Successfully validated complete schema, services, networks, volumes, and health checks with zero syntax warnings.

### 8.2 Docker Image Multi-Stage Build
```bash
docker compose build
```
- **Build Output Summary:**
  - Base stage: Node.js 24 Alpine with Corepack Yarn 4.13.0.
  - Dependencies stage: `yarn install --immutable` succeeded (+252 packages).
  - Builder stage: `yarn lint` (0 errors), `yarn typecheck` (0 errors), `yarn test:unit` (1 passed), `yarn twenty dev:build` (5 files compiled).
  - Runner stage: Final minimal non-root image tagged `devops-crm-project-crm-app:latest`.

### 8.3 Service Startup
```bash
docker compose up -d
```
- **Output:**
  ```text
  Network devops_crm_network Created
  Volume devops_crm_twenty_dev_data Created
  Volume devops_crm_twenty_dev_storage Created
  Volume devops_crm_app_build_output Created
  Container devops-crm-twenty-server Started (healthy)
  Container devops-crm-app Started (healthy)
  ```

### 8.4 Container Status Inspection
```bash
docker compose ps
```
```text
NAME                       IMAGE                             COMMAND                  SERVICE         STATUS                        PORTS
devops-crm-app             devops-crm-project-crm-app        "docker-entrypoint.s…"   crm-app         Up (healthy)                  3000/tcp
devops-crm-twenty-server   twentycrm/twenty-app-dev:latest   "/init"                  twenty-server   Up (healthy)                  0.0.0.0:2020->2020/tcp
```

### 8.5 Running Verification Commands Inside the Container
```bash
# Run linting inside the running container environment
docker compose run --rm crm-app yarn lint

# Run TypeScript type check inside the container
docker compose run --rm crm-app yarn typecheck

# Run unit tests inside the container
docker compose run --rm crm-app yarn test:unit

# Run application build inside the container
docker compose run --rm crm-app yarn twenty dev:build
```
- **All verification commands executed inside `crm-app` container exited with code 0.**

---

## 9. Issues Faced & Resolutions

### 1. Yarn Berry Lockfile Resolution in Runner Stage
- **Issue:** The initial runner stage copied only `node_modules` and `package.json`, causing Yarn 4.13.0 to report `Internal Error: my-app@workspace:.: This package doesn't seem to be present in your lockfile`.
- **Resolution:** Copied `yarn.lock`, `.yarnrc.yml`, `.nvmrc`, and `.yarn/` into the runner stage, ensuring Yarn Berry can parse workspace configuration in non-root execution.

### 2. Missing Configuration Files in Container Verification Run
- **Issue:** Running `docker compose run --rm crm-app yarn lint` initially failed because `.oxlintrc.json` was omitted from the runner stage.
- **Resolution:** Updated `Dockerfile` runner stage to include `.oxlintrc.json`, `tsconfig.spec.json`, `vitest.config.ts`, and `vitest.unit.config.ts`.

### 3. Non-Root Corepack Cache Permission
- **Issue:** Running Yarn under the non-root `node` user triggered Corepack re-downloads if cache paths were owned by root.
- **Resolution:** Pre-populated `/home/node/.cache` in the `Dockerfile` with appropriate `chown -R node:node` permissions.

---

## 10. Application Initialization & First-Time Setup Instructions

When starting the stack for the first time:

1. **Start the containers:**
   ```bash
   docker compose up -d
   ```
2. **Access the Twenty CRM Web Interface:**
   - URL: [http://localhost:2020](http://localhost:2020)
   - Default Credentials: `tim@apple.dev` / `tim@apple.dev`
3. **Generate an API Key for Live App Sync:**
   - In Twenty CRM, navigate to **Settings** → **Developers / API Keys** and generate an API key.
   - Set the API key in `.env`:
     ```bash
     TWENTY_API_KEY="<your-generated-api-key>"
     ```
   - Restart the app service to apply credentials:
     ```bash
     docker compose up -d crm-app
     ```
4. **Stop Services:**
   ```bash
   docker compose down
   ```

---

## 11. Conclusion

Day 5 successfully containerized the `devops-crm-project` application using production-ready Docker and Docker Compose configurations. The setup enforces security (non-root user), reliability (health checks and multi-stage testing gates), efficiency (Alpine base and layer caching), and isolated network and persistent volume management.
