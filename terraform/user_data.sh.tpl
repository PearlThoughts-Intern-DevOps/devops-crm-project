#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

echo "========================================="
echo "  Twenty CRM Bootstrap Started"
echo "  $(date -u)"
echo "========================================="

echo "[1/7] Installing Docker..."
apt-get update -y
apt-get install -y docker.io curl
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
echo "Docker: $(docker --version)"

echo "[2/7] Adding 3GB swap..."
fallocate -l 3G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=10
echo "Memory: $(free -h | grep Mem)"

echo "[3/7] Getting server URL..."
SERVER_URL="${server_url}"
echo "Server URL: $SERVER_URL"

echo "[4/7] Creating Docker network..."
docker network create twenty-network || true

echo "[5/7] Starting PostgreSQL..."
docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  --memory 256m \
  --memory-swap 512m \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD="${pg_password}" \
  -v twenty-db-data:/var/lib/postgresql/data \
  postgres:16-alpine

echo "Starting Redis..."
docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  --memory 128m \
  --memory-swap 256m \
  redis:7-alpine \
  redis-server --maxmemory 100mb --maxmemory-policy noeviction

echo "Waiting 45s for DB and Redis..."
sleep 45

echo "Checking DB is ready..."
until docker exec twenty-db pg_isready -U postgres; do
  echo "DB not ready, waiting 5s..."
  sleep 5
done
echo "DB ready"

echo "[6/7] Starting Twenty CRM..."
docker run -d \
  --name twenty-crm \
  --network twenty-network \
  --restart unless-stopped \
  --memory 768m \
  --memory-swap 2048m \
  --health-cmd="curl -f http://localhost:3000/healthz || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=90s \
  -p "${app_port}:3000" \
  -e NODE_PORT=3000 \
  -e NODE_ENV=production \
  -e NODE_OPTIONS="--max-old-space-size=640" \
  -e SERVER_URL="$SERVER_URL" \
  -e PG_DATABASE_URL="postgres://postgres:${pg_password}@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e ENCRYPTION_KEY="${encryption_key}" \
  -e APP_SECRET="${app_secret}" \
  -e STORAGE_TYPE=local \
  "${twenty_image}"

echo "Waiting 120s for migrations..."
sleep 120

echo "[7/7] Starting Twenty Worker..."
docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  --memory 384m \
  --memory-swap 768m \
  --health-cmd="ps aux | grep 'worker:prod' | grep -v grep || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=60s \
  -e NODE_ENV=production \
  -e NODE_OPTIONS="--max-old-space-size=320" \
  -e SERVER_URL="$SERVER_URL" \
  -e PG_DATABASE_URL="postgres://postgres:${pg_password}@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e ENCRYPTION_KEY="${encryption_key}" \
  -e APP_SECRET="${app_secret}" \
  -e DISABLE_DB_MIGRATIONS=true \
  -e DISABLE_CRON_JOBS_REGISTRATION=true \
  -e STORAGE_TYPE=local \
  "${twenty_image}" \
  yarn worker:prod

echo "========================================="
echo "  Bootstrap Complete"
echo "  Server URL: $SERVER_URL"
echo "  $(date -u)"
echo "========================================="
docker ps -a
free -h
