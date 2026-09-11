#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

echo "========================================="
echo "  Twenty CRM Bootstrap Started"
echo "  $(date -u)"
echo "========================================="

echo "[1/5] Installing Docker..."
apt-get update -y
apt-get install -y docker.io curl
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
echo "Docker: $(docker --version)"

# Variables from Terraform
AWS_REGION="${aws_region}"
APP_PORT="${app_port}"
APP_NAME="${app_name}"
S3_BUCKET="${s3_bucket_name}"
TWENTY_IMAGE="${twenty_image}"
ENCRYPTION_KEY="${encryption_key}"
APP_SECRET="${app_secret}"
PG_PASSWORD="${pg_password}"

echo "[2/5] Getting EC2 public IP (IMDSv2)..."
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP: $PUBLIC_IP"

echo "[3/5] Creating Docker network..."
docker network create twenty-network || true

echo "[4/5] Starting PostgreSQL and Redis..."
docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD="$PG_PASSWORD" \
  -v twenty-db-data:/var/lib/postgresql/data \
  postgres:16-alpine

docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7-alpine \
  redis-server --maxmemory-policy noeviction --maxmemory 256mb

echo "Waiting 30s for DB and Redis..."
sleep 30

echo "[5/5] Starting Twenty CRM server..."
docker run -d \
  --name "$APP_NAME" \
  --network twenty-network \
  --restart unless-stopped \
  -p "$APP_PORT:3000" \
  -e NODE_PORT=3000 \
  -e NODE_ENV=production \
  -e SERVER_URL="http://$PUBLIC_IP:$APP_PORT" \
  -e PG_DATABASE_URL="postgres://postgres:$PG_PASSWORD@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e APP_SECRET="$APP_SECRET" \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET" \
  "$TWENTY_IMAGE"

docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e SERVER_URL="http://$PUBLIC_IP:$APP_PORT" \
  -e PG_DATABASE_URL="postgres://postgres:$PG_PASSWORD@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e APP_SECRET="$APP_SECRET" \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET" \
  -e DISABLE_DB_MIGRATIONS=true \
  -e DISABLE_CRON_JOBS_REGISTRATION=true \
  "$TWENTY_IMAGE" \
  yarn worker:prod

echo "========================================="
echo "  App URL: http://$PUBLIC_IP:$APP_PORT"
echo "  S3 Bucket: $S3_BUCKET"
echo "  $(date -u)"
echo "========================================="
