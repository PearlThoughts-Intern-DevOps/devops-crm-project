#!/bin/bash
set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM Task 13 setup..."

S3_BUCKET_NAME="${s3_bucket_name}"
AWS_REGION="${aws_region}"

echo "S3 Bucket: $S3_BUCKET_NAME"
echo "AWS Region: $AWS_REGION"

dnf update -y
dnf install -y docker awscli openssl

systemctl enable docker
systemctl start docker

echo "Testing AWS identity..."
aws sts get-caller-identity --region "$AWS_REGION"

echo "Testing S3 access..."
aws s3 ls "s3://$S3_BUCKET_NAME" --region "$AWS_REGION" || true

echo "Creating Docker network..."
docker network create twenty-network 2>/dev/null || true

echo "Starting PostgreSQL..."
docker rm -f twenty-db 2>/dev/null || true

docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=twenty-task13-db-password \
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
docker rm -f twenty-worker 2>/dev/null || true

APP_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)

echo "Starting Twenty CRM..."

docker run -d \
  --name twenty-crm \
  --network twenty-network \
  --restart unless-stopped \
  -p 8080:3000 \
  -e NODE_PORT=3000 \
  -e SERVER_URL=http://0.0.0.0:8080 \
  -e NODE_ENV=production \
  -e APP_SECRET="$APP_SECRET" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e PG_DATABASE_URL=postgres://postgres:twenty-task13-db-password@twenty-db:5432/default \
  -e REDIS_URL=redis://twenty-redis:6379 \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET_NAME" \
  twentycrm/twenty:latest

echo "Starting Twenty CRM worker..."

docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e APP_SECRET="$APP_SECRET" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e PG_DATABASE_URL=postgres://postgres:twenty-task13-db-password@twenty-db:5432/default \
  -e REDIS_URL=redis://twenty-redis:6379 \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET_NAME" \
  twentycrm/twenty:latest \
  yarn worker:prod

echo "Twenty CRM containers started."

echo "Running containers:"
docker ps

echo "Twenty CRM storage configuration:"
docker inspect twenty-crm \
  --format '{{range .Config.Env}}{{println .}}{{end}}' | \
  grep -E 'STORAGE_TYPE|STORAGE_S3_REGION|STORAGE_S3_NAME'

echo "Twenty CRM Task 13 setup completed."
