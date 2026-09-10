#!/bin/bash

set -u

LOG_FILE="/var/log/twenty-task13-user-data.log"
exec > >(tee -a "$LOG_FILE" | logger -t twenty-task13-user-data -s 2>/dev/console) 2>&1

echo "=================================================="
echo "Twenty CRM Task 13 - EC2 User Data"
echo "=================================================="

AWS_REGION="${aws_region}"
S3_BUCKET="${s3_bucket_name}"
TWENTY_PORT="${twenty_port}"
INSTANCE_NAME="${instance_name}"

echo "[INFO] AWS region: $${AWS_REGION}"
echo "[INFO] S3 bucket: $${S3_BUCKET}"
echo "[INFO] Twenty CRM port: $${TWENTY_PORT}"

echo "[INFO] Updating package index..."
apt-get update -y

echo "[INFO] Installing required dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  unzip \
  openssl

echo "[INFO] Installing Docker..."
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io

systemctl enable docker
systemctl start docker

echo "[INFO] Docker version:"
docker --version

echo "[INFO] Creating Docker network..."
docker network create twenty-network 2>/dev/null || true

echo "[INFO] Generating application secrets..."
ENCRYPTION_KEY="$(openssl rand -base64 32)"
FALLBACK_ENCRYPTION_KEY="$(openssl rand -base64 32)"
APP_SECRET="$(openssl rand -base64 32)"
PG_PASSWORD="$(openssl rand -hex 32)"

echo "[INFO] Starting PostgreSQL..."

docker rm -f twenty-db 2>/dev/null || true

docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD="$${PG_PASSWORD}" \
  postgres:16

echo "[INFO] Waiting for PostgreSQL..."

DB_READY=0

for attempt in $(seq 1 60); do
  if docker exec twenty-db \
      pg_isready -U postgres -h localhost -d postgres \
      >/dev/null 2>&1; then
    DB_READY=1
    echo "[OK] PostgreSQL is ready."
    break
  fi

  echo "[INFO] PostgreSQL is not ready yet. Attempt $${attempt}/60"
  sleep 2
done

if [ "$${DB_READY}" -ne 1 ]; then
  echo "[ERROR] PostgreSQL did not become ready."
  docker logs --tail 100 twenty-db 2>&1 || true
  exit 1
fi

echo "[INFO] Starting Redis..."

docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7 \
  --maxmemory-policy noeviction

echo "[INFO] Waiting for Redis..."

REDIS_READY=0

for attempt in $(seq 1 30); do
  if docker exec twenty-redis redis-cli ping 2>/dev/null | grep -q PONG; then
    REDIS_READY=1
    echo "[OK] Redis is ready."
    break
  fi

  echo "[INFO] Redis is not ready yet. Attempt $${attempt}/30"
  sleep 2
done

if [ "$${REDIS_READY}" -ne 1 ]; then
  echo "[ERROR] Redis did not become ready."
  docker logs --tail 100 twenty-redis 2>&1 || true
  exit 1
fi

echo "[INFO] Removing existing Twenty containers..."

docker rm -f twenty-server 2>/dev/null || true
docker rm -f twenty-worker 2>/dev/null || true

echo "[INFO] Pulling Twenty CRM image..."

docker pull twentycrm/twenty:latest

if [ "$?" -ne 0 ]; then
  echo "[ERROR] Failed to pull Twenty CRM image."
  exit 1
fi

echo "[OK] Twenty CRM image pulled successfully."

echo "[INFO] Starting Twenty CRM server..."

docker run -d \
  --name twenty-server \
  --network twenty-network \
  --restart unless-stopped \
  -p "$${TWENTY_PORT}:3000" \
  -e NODE_PORT=3000 \
  -e PG_DATABASE_URL="postgres://postgres:$${PG_PASSWORD}@twenty-db:5432/default" \
  -e SERVER_URL="http://localhost:$${TWENTY_PORT}" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e DISABLE_DB_MIGRATIONS=false \
  -e DISABLE_CRON_JOBS_REGISTRATION=false \
  -e STORAGE_TYPE=S_3 \
  -e STORAGE_S3_REGION="$${AWS_REGION}" \
  -e STORAGE_S3_NAME="$${S3_BUCKET}" \
  -e STORAGE_S3_ENDPOINT="https://s3.$${AWS_REGION}.amazonaws.com" \
  -e ENCRYPTION_KEY="$${ENCRYPTION_KEY}" \
  -e FALLBACK_ENCRYPTION_KEY="$${FALLBACK_ENCRYPTION_KEY}" \
  -e APP_SECRET="$${APP_SECRET}" \
  twentycrm/twenty:latest

if [ "$?" -ne 0 ]; then
  echo "[ERROR] Failed to start Twenty CRM server."
  exit 1
fi

echo "[OK] Twenty CRM server started."

echo "[INFO] Starting Twenty CRM worker..."

docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  twentycrm/twenty:latest \
  yarn worker:prod

if [ "$?" -ne 0 ]; then
  echo "[ERROR] Failed to start Twenty CRM worker."
  exit 1
fi

echo "[OK] Twenty CRM worker started."

echo "[INFO] Waiting for Twenty CRM health endpoint..."

HEALTH_SUCCESS=0

for attempt in $(seq 1 120); do
  if curl -fsS \
      "http://127.0.0.1:$${TWENTY_PORT}/healthz" \
      >/dev/null 2>&1; then

    HEALTH_SUCCESS=1

    echo "[OK] Twenty CRM health check passed on port $${TWENTY_PORT}."
    break
  fi

  echo "[INFO] Twenty CRM is not ready yet. Attempt $${attempt}/120"
  sleep 5
done

if [ "$${HEALTH_SUCCESS}" -ne 1 ]; then
  echo "[ERROR] Twenty CRM did not become ready."

  echo "[INFO] Container status:"
  docker ps -a

  echo "[INFO] Twenty server logs:"
  docker logs --tail 200 twenty-server 2>&1 || true

  echo "[INFO] Twenty worker logs:"
  docker logs --tail 100 twenty-worker 2>&1 || true

  echo "[INFO] PostgreSQL logs:"
  docker logs --tail 100 twenty-db 2>&1 || true

  echo "[INFO] Redis logs:"
  docker logs --tail 100 twenty-redis 2>&1 || true

  exit 1
fi

echo "=================================================="
echo "[OK] Twenty CRM Task 13 deployment completed."
echo "[OK] S3 bucket configured: $${S3_BUCKET}"
echo "[OK] Twenty CRM available on port $${TWENTY_PORT}"
echo "=================================================="

