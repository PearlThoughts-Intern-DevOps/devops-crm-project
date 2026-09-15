#!/bin/bash

set -u

LOG_FILE="/var/log/twenty-task15-user-data.log"
exec > >(tee -a "$LOG_FILE" | logger -t twenty-task15-user-data -s 2>/dev/console) 2>&1

echo "=================================================="
echo "Twenty CRM Task 15 - EC2 User Data"
echo "=================================================="

TWENTY_PORT="${twenty_port}"
INSTANCE_NAME="${instance_name}"

apt-get update -y

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  openssl

DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io

systemctl enable docker
systemctl start docker

docker network create twenty-network 2>/dev/null || true

ENCRYPTION_KEY="$(openssl rand -base64 32)"
FALLBACK_ENCRYPTION_KEY="$(openssl rand -base64 32)"
APP_SECRET="$(openssl rand -base64 32)"
PG_PASSWORD="$(openssl rand -hex 32)"

docker rm -f twenty-db 2>/dev/null || true

docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD="$PG_PASSWORD" \
  postgres:16

DB_READY=0

for attempt in $(seq 1 60); do
  if docker exec twenty-db \
      pg_isready -U postgres -h localhost -d postgres \
      >/dev/null 2>&1; then
    DB_READY=1
    break
  fi
  sleep 2
done

if [ "$DB_READY" -ne 1 ]; then
  docker logs --tail 100 twenty-db 2>&1 || true
  exit 1
fi

docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7 \
  --maxmemory-policy noeviction

REDIS_READY=0

for attempt in $(seq 1 30); do
  if docker exec twenty-redis redis-cli ping 2>/dev/null | grep -q PONG; then
    REDIS_READY=1
    break
  fi
  sleep 2
done

if [ "$REDIS_READY" -ne 1 ]; then
  docker logs --tail 100 twenty-redis 2>&1 || true
  exit 1
fi

docker rm -f twenty-server 2>/dev/null || true
docker rm -f twenty-worker 2>/dev/null || true

docker pull twentycrm/twenty:latest

docker run -d \
  --name twenty-server \
  --network twenty-network \
  --restart unless-stopped \
  -p "$TWENTY_PORT:3000" \
  -e NODE_PORT=3000 \
  -e PG_DATABASE_URL="postgres://postgres:$${PG_PASSWORD}@twenty-db:5432/default" \
  -e SERVER_URL="http://localhost:$${TWENTY_PORT}" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e DISABLE_DB_MIGRATIONS=false \
  -e DISABLE_CRON_JOBS_REGISTRATION=false \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$FALLBACK_ENCRYPTION_KEY" \
  -e APP_SECRET="$APP_SECRET" \
  twentycrm/twenty:latest

docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  twentycrm/twenty:latest \
  yarn worker:prod

HEALTH_SUCCESS=0

for attempt in $(seq 1 120); do
  if curl -fsS \
      "http://127.0.0.1:$${TWENTY_PORT}/healthz" \
      >/dev/null 2>&1; then
    HEALTH_SUCCESS=1
    break
  fi
  sleep 5
done

if [ "$HEALTH_SUCCESS" -ne 1 ]; then
  docker ps -a
  docker logs --tail 200 twenty-server 2>&1 || true
  docker logs --tail 100 twenty-worker 2>&1 || true
  docker logs --tail 100 twenty-db 2>&1 || true
  docker logs --tail 100 twenty-redis 2>&1 || true
  exit 1
fi

echo "Twenty CRM is healthy on port $${TWENTY_PORT}"
echo "Instance: $${INSTANCE_NAME}"
echo "Task 15 deployment completed."
