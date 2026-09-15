#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM Task 15 setup..."

dnf update -y
dnf install -y docker openssl

systemctl enable docker
systemctl start docker

echo "Creating Docker network..."
docker network create twenty-network 2>/dev/null || true

echo "Starting PostgreSQL..."
docker rm -f twenty-db 2>/dev/null || true

docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=twenty-task15-db-password \
  -e POSTGRES_DB=default \
  postgres:16

echo "Waiting for PostgreSQL..."

for i in {1..30}; do
  if docker exec twenty-db pg_isready -U postgres >/dev/null 2>&1; then
    echo "PostgreSQL is ready."
    break
  fi
  sleep 2
done

echo "Starting Redis..."
docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:latest

echo "Pulling Twenty CRM image..."
docker pull twentycrm/twenty:latest

docker rm -f twenty-crm 2>/dev/null || true

APP_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)

echo "Starting Twenty CRM..."

docker run -d \
  --name twenty-crm \
  --network twenty-network \
  --restart unless-stopped \
  -p 8080:3000 \
  -e NODE_PORT=3000 \
  -e SERVER_URL=http://localhost:8080 \
  -e NODE_ENV=production \
  -e APP_SECRET="$APP_SECRET" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e PG_DATABASE_URL=postgres://postgres:twenty-task15-db-password@twenty-db:5432/default \
  -e REDIS_URL=redis://twenty-redis:6379 \
  twentycrm/twenty:latest

echo "Twenty CRM container started."

echo "Running containers:"
docker ps

echo "Waiting for Twenty CRM..."
for i in {1..30}; do
  if curl -fs http://localhost:8080/ >/dev/null 2>&1; then
    echo "Twenty CRM is responding."
    break
  fi
  sleep 5
done

echo "Twenty CRM Task 15 setup completed."
