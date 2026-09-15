#!/bin/bash

set -u

exec > >(tee /var/log/twenty-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========================================="
echo "Starting Twenty CRM setup..."
echo "========================================="

AWS_REGION="${aws_region}"
ECR_REPOSITORY_URL="${ecr_repository_url}"
IMAGE="$ECR_REPOSITORY_URL:latest"

echo "Updating system packages..."
dnf update -y

echo "Installing Docker and AWS CLI..."
dnf install -y docker awscli

echo "Starting Docker..."
systemctl enable docker
systemctl start docker

echo "Docker version:"
docker --version

echo "AWS CLI version:"
aws --version

echo "Logging in to Amazon ECR..."

ECR_REGISTRY="$(echo "$ECR_REPOSITORY_URL" | cut -d/ -f1)"

aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "ECR login successful."

echo "========================================="
echo "Attempting to pull Twenty CRM image..."
echo "========================================="

MAX_ATTEMPTS=30
ATTEMPT=1

while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
    echo "Image pull attempt $ATTEMPT/$MAX_ATTEMPTS..."

    if docker pull "$IMAGE"; then
        echo "Twenty CRM image pulled successfully."
        break
    fi

    if [ "$ATTEMPT" -eq "$MAX_ATTEMPTS" ]; then
        echo "ERROR: Unable to pull Twenty CRM image after $MAX_ATTEMPTS attempts."
        exit 1
    fi

    echo "Image not available yet. Waiting 30 seconds..."
    sleep 30

    ATTEMPT=$((ATTEMPT + 1))
done

echo "========================================="
echo "Creating Docker network..."
echo "========================================="

docker network create twenty-network 2>/dev/null || true

echo "========================================="
echo "Starting PostgreSQL..."
echo "========================================="

docker rm -f postgres 2>/dev/null || true

docker run -d \
    --name postgres \
    --network twenty-network \
    --restart unless-stopped \
    -e POSTGRES_USER=twenty \
    -e POSTGRES_PASSWORD=twenty \
    -e POSTGRES_DB=default \
    -v twenty-postgres-data:/var/lib/postgresql/data \
    postgres:16-alpine

echo "========================================="
echo "Starting Redis..."
echo "========================================="

docker rm -f redis 2>/dev/null || true

docker run -d \
    --name redis \
    --network twenty-network \
    --restart unless-stopped \
    redis:7-alpine

echo "========================================="
echo "Waiting for PostgreSQL..."
echo "========================================="

POSTGRES_ATTEMPTS=1
POSTGRES_MAX_ATTEMPTS=30

while [ "$POSTGRES_ATTEMPTS" -le "$POSTGRES_MAX_ATTEMPTS" ]; do

    if docker exec postgres pg_isready -U twenty -d default; then
        echo "PostgreSQL is ready."
        break
    fi

    echo "PostgreSQL is not ready yet..."
    sleep 5

    POSTGRES_ATTEMPTS=$((POSTGRES_ATTEMPTS + 1))
done

if [ "$POSTGRES_ATTEMPTS" -gt "$POSTGRES_MAX_ATTEMPTS" ]; then
    echo "ERROR: PostgreSQL did not become ready."
    exit 1
fi

echo "========================================="
echo "Waiting for Redis..."
echo "========================================="

REDIS_ATTEMPTS=1
REDIS_MAX_ATTEMPTS=30

while [ "$REDIS_ATTEMPTS" -le "$REDIS_MAX_ATTEMPTS" ]; do

    if docker exec redis redis-cli ping | grep -q PONG; then
        echo "Redis is ready."
        break
    fi

    echo "Redis is not ready yet..."
    sleep 5

    REDIS_ATTEMPTS=$((REDIS_ATTEMPTS + 1))
done

if [ "$REDIS_ATTEMPTS" -gt "$REDIS_MAX_ATTEMPTS" ]; then
    echo "ERROR: Redis did not become ready."
    exit 1
fi

echo "========================================="
echo "Starting Twenty CRM..."
echo "========================================="

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
    --name twenty-crm \
    --network twenty-network \
    --restart unless-stopped \
    -p 2020:2020 \
    -e NODE_PORT=2020 \
    -e APP_SECRET="$(openssl rand -hex 32)" \
    -e PG_DATABASE_URL="postgres://twenty:twenty@postgres:5432/default" \
    -e SERVER_URL="http://localhost:2020" \
    -e REDIS_URL="redis://redis:6379" \
    -e STORAGE_TYPE=local \
    -e IS_BILLING_ENABLED=false \
    -e NODE_ENV=production \
    "$IMAGE"

echo "========================================="
echo "Waiting for Twenty CRM to start..."
echo "========================================="

sleep 60

echo "========================================="
echo "Running containers:"
echo "========================================="

docker ps

echo "========================================="
echo "Checking Twenty CRM HTTP endpoint..."
echo "========================================="

if curl -f http://localhost:2020 > /dev/null 2>&1; then
    echo "Twenty CRM is responding successfully."
else
    echo "WARNING: Twenty CRM HTTP check failed."
    echo "Check: docker logs twenty-crm"
fi

echo "========================================="
echo "Twenty CRM setup completed."
echo "========================================="