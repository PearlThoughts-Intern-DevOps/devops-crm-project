#!/bin/bash

set -euxo pipefail

exec > >(tee /var/log/task15-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Task 15 - Twenty CRM Deployment"
echo "Started: $(date)"
echo "=========================================="

# ============================================================
# 1. CREATE 4GB SWAP
# ============================================================

if [ ! -f /swapfile ]; then

    echo "Creating 4GB swap..."

    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    echo "/swapfile none swap sw 0 0" >> /etc/fstab

fi


# ============================================================
# 2. UPDATE AMAZON LINUX
# ============================================================

dnf update -y


# ============================================================
# 3. INSTALL REQUIRED PACKAGES
# ============================================================

dnf install -y \
    docker \
    git \
    openssl \
    curl


# ============================================================
# 4. START DOCKER
# ============================================================

systemctl enable docker
systemctl start docker

docker --version


# ============================================================
# 5. INSTALL DOCKER COMPOSE
# ============================================================

if docker compose version >/dev/null 2>&1; then

    echo "Docker Compose plugin already available."

else

    echo "Installing Docker Compose..."

    curl -fSL \
      https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
      -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose

fi

docker-compose --version


# ============================================================
# 6. CREATE APPLICATION DIRECTORY
# ============================================================

mkdir -p /opt/twenty-crm

cd /opt/twenty-crm


# ============================================================
# 7. CLONE PEARLTHOUGHTS REPOSITORY
# ============================================================

if [ ! -d "devops-crm-project" ]; then

    git clone \
      --depth 1 \
      --branch "${repo_branch}" \
      "${repo_url}" \
      devops-crm-project

fi

cd /opt/twenty-crm/devops-crm-project


echo "Repository:"
echo "${repo_url}"

echo "Branch:"
git branch --show-current


# ============================================================
# 8. VERIFY PROJECT FILES
# ============================================================

echo "Checking project files..."

ls -la

if [ ! -f Dockerfile ]; then
    echo "ERROR: Dockerfile not found."
    exit 1
fi


# ============================================================
# 9. GENERATE APPLICATION SECRET
# ============================================================

APP_SECRET="$${APP_SECRET:-$(openssl rand -hex 32)}"


# ============================================================
# 10. CREATE ENVIRONMENT FILE
# ============================================================

cat > .env <<EOF
PG_DATABASE_USER=postgres
PG_DATABASE_PASSWORD=postgrespassword123
PG_DATABASE_NAME=default
APP_SECRET="$APP_SECRET"
AWS_REGION=${aws_region}
TWENTY_PORT=${app_port}
SERVER_URL=http://localhost:${app_port}
EOF


# ============================================================
# 11. CREATE TASK 15 DOCKER COMPOSE
# ============================================================

cat > docker-compose.yml <<'EOF'
services:

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: $${PG_DATABASE_USER:-postgres}
      POSTGRES_PASSWORD: $${PG_DATABASE_PASSWORD:-postgres}
      POSTGRES_DB: $${PG_DATABASE_NAME:-default}
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "pg_isready -U $${PG_DATABASE_USER:-postgres} -d $${PG_DATABASE_NAME:-default}"
        ]
      interval: 5s
      timeout: 5s
      retries: 10
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - twenty-net

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10
    volumes:
      - redis-data:/data
    networks:
      - twenty-net

  twenty-server:
    image: twentycrm/twenty:latest
    restart: unless-stopped
    environment:
      NODE_PORT: 3000
      PG_DATABASE_URL: postgres://$${PG_DATABASE_USER:-postgres}:$${PG_DATABASE_PASSWORD:-postgres}@db:5432/$${PG_DATABASE_NAME:-default}
      REDIS_URL: redis://redis:6379
      SERVER_URL: $${SERVER_URL:-http://localhost:3000}
      APP_SECRET: $${APP_SECRET:?APP_SECRET must be set in .env}
      STORAGE_TYPE: local
    ports:
      - "$${TWENTY_PORT:-3000}:3000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test:
        [
          "CMD",
          "curl",
          "-f",
          "http://localhost:3000/healthz"
        ]
      interval: 10s
      timeout: 5s
      retries: 30
      start_period: 180s
    networks:
      - twenty-net

  app:
    build:
      context: .
      dockerfile: Dockerfile
    restart: "no"
    environment:
      TWENTY_API_URL: http://twenty-server:3000
    depends_on:
      twenty-server:
        condition: service_healthy
    networks:
      - twenty-net

networks:
  twenty-net:
    driver: bridge

volumes:
  db-data:
  redis-data:
EOF


# ============================================================
# 12. VALIDATE DOCKER COMPOSE
# ============================================================

docker-compose config


# ============================================================
# 13. START TWENTY CRM
# ============================================================

echo "Starting Twenty CRM..."

docker-compose up -d


# ============================================================
# 14. WAIT FOR APPLICATION
# ============================================================

echo "Waiting for Twenty CRM..."

MAX_RETRIES=30
RETRY_COUNT=0

while [ "$${RETRY_COUNT}" -lt "$${MAX_RETRIES}" ]; do

    if curl -fsS "http://localhost:${app_port}/healthz" >/dev/null 2>&1; then

        echo "Twenty CRM is responding."

        break

    fi

    echo "Twenty CRM not ready. Retry $${RETRY_COUNT}/$${MAX_RETRIES}"

    sleep 10

    RETRY_COUNT=$((RETRY_COUNT + 1))

done


# ============================================================
# 15. SHOW CONTAINER STATUS
# ============================================================

echo "=========================================="
echo "Docker container status"
echo "=========================================="

docker-compose ps

docker ps


# ============================================================
# 16. FINAL APPLICATION CHECK
# ============================================================

if [ "$${RETRY_COUNT}" -eq "$${MAX_RETRIES}" ]; then

    echo "WARNING: Twenty CRM did not respond within retry period."

    docker-compose logs --tail=100

else

    echo "Twenty CRM is running successfully."

fi


echo "=========================================="
echo "Task 15 bootstrap completed"
echo "Completed: $(date)"
echo "=========================================="