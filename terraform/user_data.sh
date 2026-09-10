#!/bin/bash

set -euxo pipefail

exec > >(tee /var/log/task13-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Task 13 - Twenty CRM Deployment"
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
    awscli


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
# 8. VERIFY DOCKERFILE AND COMPOSE
# ============================================================

echo "Checking project files..."

ls -la

if [ ! -f Dockerfile ]; then
    echo "ERROR: Dockerfile not found."
    exit 1
fi

if [ ! -f docker-compose.yml ]; then
    echo "ERROR: docker-compose.yml not found."
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
STORAGE_TYPE=s3
STORAGE_S3_REGION=${aws_region}
STORAGE_S3_NAME=${bucket_name}
AWS_REGION=${aws_region}
EOF



# ============================================================
# 11. DISPLAY NON-SECRET CONFIGURATION
# ============================================================

echo "=========================================="
echo "Twenty CRM S3 configuration"
echo "=========================================="

grep -E \
  'STORAGE_TYPE|STORAGE_S3_REGION|STORAGE_S3_NAME|AWS_REGION|TWENTY_PORT' \
  .env


# ============================================================
# 12. START PEARLTHOUGHTS TWENTY CRM
# ============================================================

echo "Starting Twenty CRM..."

docker-compose up -d


# ============================================================
# 13. WAIT FOR CONTAINERS
# ============================================================

echo "Waiting for containers..."

sleep 20


# ============================================================
# 14. SHOW CONTAINER STATUS
# ============================================================

docker-compose ps

docker ps


# ============================================================
# 15. APPLICATION CHECK
# ============================================================

echo "Testing Twenty CRM..."

MAX_RETRIES=30
RETRY_COUNT=0

while [ "$${RETRY_COUNT}" -lt "$${MAX_RETRIES}" ]; do

    if curl -fsS "http://localhost:${app_port}" >/dev/null 2>&1; then

        echo "Twenty CRM is responding."
        break

    fi

    echo "Twenty CRM not ready. Retry $${RETRY_COUNT}/$${MAX_RETRIES}"

    sleep 10

    RETRY_COUNT=$((RETRY_COUNT + 1))

done


if [ "$${RETRY_COUNT}" -eq "$${MAX_RETRIES}" ]; then

    echo "WARNING: Twenty CRM did not respond within the retry period."

    docker ps

    docker-compose logs --tail=100

else

    echo "Twenty CRM is running successfully."

fi


echo "=========================================="
echo "Task 13 bootstrap completed"
echo "Completed: $(date)"
echo "=========================================="