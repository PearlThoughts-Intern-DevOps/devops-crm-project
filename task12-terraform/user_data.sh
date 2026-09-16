#!/bin/bash
set -e

REGION="us-east-1"
ECR_REPOSITORY="twenty-crm"
ECR_REGISTRY="579138738751.dkr.ecr.us-east-1.amazonaws.com"
IMAGE_TAG="latest"

NETWORK_NAME="twenty-network"
DB_CONTAINER="twenty-db"
REDIS_CONTAINER="twenty-redis"
SERVER_CONTAINER="twenty-server"
WORKER_CONTAINER="twenty-worker"

dnf update -y
dnf install -y docker awscli curl openssl

systemctl enable --now docker

# Login to ECR
aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Pull required images
docker pull "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
docker pull postgres:16
docker pull redis:latest

# Create Docker network
docker network create "$NETWORK_NAME" 2>/dev/null || true

# Create persistent volumes
docker volume create twenty-db-data
docker volume create twenty-server-data

# Remove old containers if they exist
docker rm -f "$SERVER_CONTAINER" "$WORKER_CONTAINER" "$DB_CONTAINER" "$REDIS_CONTAINER" 2>/dev/null || true

# Start PostgreSQL
docker run -d \
  --name "$DB_CONTAINER" \
  --network "$NETWORK_NAME" \
  --restart unless-stopped \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -v twenty-db-data:/var/lib/postgresql/data \
  postgres:16

# Start Redis
docker run -d \
  --name "$REDIS_CONTAINER" \
  --network "$NETWORK_NAME" \
  --restart unless-stopped \
  redis:latest \
  --maxmemory-policy noeviction

# Wait for PostgreSQL
until docker exec "$DB_CONTAINER" pg_isready -U postgres -d default >/dev/null 2>&1
do
  echo "Waiting for PostgreSQL..."
  sleep 3
done

# Wait for Redis
until docker exec "$REDIS_CONTAINER" redis-cli ping >/dev/null 2>&1
do
  echo "Waiting for Redis..."
  sleep 3
done

# Get EC2 public IP using IMDSv2
TOKEN=$(curl -sS -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

PUBLIC_IP=$(curl -sS \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

SERVER_URL="http://${PUBLIC_IP}:2020"

# Generate application secrets
ENCRYPTION_KEY=$(openssl rand -hex 32)
FALLBACK_ENCRYPTION_KEY=$(openssl rand -hex 32)
APP_SECRET=$(openssl rand -hex 32)

# Start Twenty server
docker run -d \
  --name "$SERVER_CONTAINER" \
  --network "$NETWORK_NAME" \
  --restart unless-stopped \
  -p 2020:3000 \
  -e NODE_PORT=3000 \
  -e PG_DATABASE_URL="postgres://postgres:postgres@${DB_CONTAINER}:5432/default" \
  -e REDIS_URL="redis://${REDIS_CONTAINER}:6379" \
  -e SERVER_URL="$SERVER_URL" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$FALLBACK_ENCRYPTION_KEY" \
  -e APP_SECRET="$APP_SECRET" \
  -v twenty-server-data:/app/packages/twenty-server/.local-storage \
  "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

# Start Twenty worker
docker run -d \
  --name "$WORKER_CONTAINER" \
  --network "$NETWORK_NAME" \
  --restart unless-stopped \
  -e PG_DATABASE_URL="postgres://postgres:postgres@${DB_CONTAINER}:5432/default" \
  -e REDIS_URL="redis://${REDIS_CONTAINER}:6379" \
  -e SERVER_URL="$SERVER_URL" \
  -e DISABLE_DB_MIGRATIONS=true \
  -e DISABLE_CRON_JOBS_REGISTRATION=true \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$FALLBACK_ENCRYPTION_KEY" \
  -e APP_SECRET="$APP_SECRET" \
  -v twenty-server-data:/app/packages/twenty-server/.local-storage \
  "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" \
  yarn worker:prod

echo "Twenty CRM deployment started."
echo "Twenty CRM URL: $SERVER_URL"
