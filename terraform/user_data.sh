#!/bin/bash
set -u

# Install Docker and AWS CLI
dnf update -y
dnf install -y docker awscli

# Start Docker
systemctl enable --now docker

# Allow ec2-user to use Docker
usermod -aG docker ec2-user

# Terraform variables
AWS_REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository}"
IMAGE_TAG="${image_tag}"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Build ECR image URL
ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
CRM_IMAGE="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

echo "ECR image: $CRM_IMAGE"

# Login to ECR
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Create Docker network
docker network create crm-network 2>/dev/null || true

# Start PostgreSQL
docker run -d \
  --name twenty_crm_db \
  --network crm-network \
  --restart unless-stopped \
  -e POSTGRES_DB=default \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:16-alpine

# Start Redis
docker run -d \
  --name twenty_crm_cache \
  --network crm-network \
  --restart unless-stopped \
  redis:7-alpine \
  --maxmemory-policy noeviction

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."

for i in {1..30}; do
  if docker exec twenty_crm_db pg_isready -U postgres -d default >/dev/null 2>&1; then
    echo "PostgreSQL is ready."
    break
  fi

  sleep 5
done

# Pull Twenty CRM image with retries
MAX_RETRIES=30
RETRY_INTERVAL=30

for ((i=1; i<=MAX_RETRIES; i++)); do

  echo "Attempt $i/$MAX_RETRIES: pulling $CRM_IMAGE"

  if docker pull "$CRM_IMAGE"; then

    echo "Twenty CRM image pulled successfully."

    docker rm -f twenty_crm_app 2>/dev/null || true

    docker run -d \
      --name twenty_crm_app \
      --network crm-network \
      --restart unless-stopped \
      -p 3000:3000 \
      -e PG_DATABASE_URL="postgres://postgres:postgres@twenty_crm_db:5432/default" \
      -e REDIS_URL="redis://twenty_crm_cache:6379" \
      -e SERVER_URL="http://localhost:3000" \
      -e PORT="3000" \
      -e NODE_PORT="3000" \
      -e STORAGE_TYPE="local" \
      -e DISABLE_CRON_JOBS_REGISTRATION="false" \
      -e DISABLE_DB_MIGRATIONS="false" \
      "$CRM_IMAGE"

    echo "Twenty CRM started successfully."
    exit 0
  fi

  echo "Image not available yet. Retrying in $RETRY_INTERVAL seconds..."
  sleep "$RETRY_INTERVAL"

done

echo "Failed to pull Twenty CRM image."
exit 1