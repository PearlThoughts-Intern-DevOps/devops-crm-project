#!/bin/bash

set -euo pipefail

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM setup..."

TWENTY_IMAGE="${twenty_image}"

echo "Twenty CRM image: $TWENTY_IMAGE"

dnf update -y

echo "Installing Docker..."
dnf install -y docker openssl

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Creating Docker network..."
docker network create twenty-network 2>/dev/null || true

echo "Starting PostgreSQL..."

docker rm -f twenty-postgres 2>/dev/null || true

docker run -d \
  --name twenty-postgres \
  --restart always \
  --network twenty-network \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=default \
  postgres:16

echo "Starting Redis..."

docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --restart always \
  --network twenty-network \
  redis:7-alpine

echo "Waiting for PostgreSQL to become ready..."

for i in {1..30}; do
    if docker exec twenty-postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo "PostgreSQL is ready."
        break
    fi

    echo "Waiting for PostgreSQL... attempt $i/30"
    sleep 2
done

echo "Generating encryption key..."

ENCRYPTION_KEY=$(openssl rand -hex 32)

echo "Starting Twenty CRM..."

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart always \
  --network twenty-network \
  -p 3000:3000 \
  -e PG_DATABASE_URL="postgres://postgres:postgres@twenty-postgres:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  --health-cmd='curl -f http://localhost:3000 || exit 1' \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=90s \
  "$TWENTY_IMAGE"

echo "Twenty CRM container created."

echo "Waiting for application startup..."

for i in {1..20}; do
    if curl -f http://localhost:3000 >/dev/null 2>&1; then
        echo "Twenty CRM is responding on port 3000."
        break
    fi

    echo "Waiting for Twenty CRM... attempt $i/20"
    sleep 15
done

echo "Container status:"
docker ps

echo "Twenty CRM health:"
docker inspect twenty-crm \
  --format='{{.State.Health.Status}}' 2>/dev/null || true

echo "Twenty CRM logs:"
docker logs --tail 50 twenty-crm || true

echo "Twenty CRM setup completed."
