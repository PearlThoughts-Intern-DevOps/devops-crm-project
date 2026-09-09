#!/bin/bash

set -x
exec > /var/log/user-data.log 2>&1

echo "Starting bootstrap at $(date)..."

# Add swap
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Install Docker and AWS CLI
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y ca-certificates curl gnupg docker.io docker-compose-v2 awscli

systemctl enable docker
systemctl start docker

# Authenticate with ECR
echo "Authenticating with ECR..."

aws ecr get-login-password --region ${aws_region} | \
docker login --username AWS --password-stdin ${ecr_repo_url}

# Create application directory
mkdir -p /opt/twenty
cd /opt/twenty

# Generate application secret
APP_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)

# Get public IP
TOKEN=$(curl -s -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)

PUBLIC_IP=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4 || true)

[ -z "$PUBLIC_IP" ] && PUBLIC_IP="localhost"

# Create Docker Compose
cat << DOCKERCOMPOSE > docker-compose.yml

services:

  twenty-db:
    image: postgres:16
    container_name: twenty-db
    restart: unless-stopped

    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgrespassword123
      POSTGRES_DB: default

    volumes:
      - pgdata:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d default"]
      interval: 5s
      timeout: 5s
      retries: 15

  twenty-redis:
    image: redis:7-alpine
    container_name: twenty-redis
    restart: unless-stopped

    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10

  twenty-server:
    image: ${ecr_repo_url}:latest
    container_name: twenty-server
    restart: unless-stopped

    depends_on:
      twenty-db:
        condition: service_healthy

      twenty-redis:
        condition: service_healthy

    ports:
      - "${app_port}:3000"

    environment:
      PORT: 3000
      SERVER_URL: http://$${PUBLIC_IP}:${app_port}
      APP_SECRET: $${APP_SECRET}

      PG_DATABASE_URL: postgres://postgres:postgrespassword123@twenty-db:5432/default

      REDIS_URL: redis://twenty-redis:6379

volumes:
  pgdata:

DOCKERCOMPOSE

# Pull image with retry
MAX_ATTEMPTS=15
ATTEMPT=1

until docker compose pull; do

  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "Image pull failed after $MAX_ATTEMPTS attempts."
    exit 1
  fi

  echo "Attempt $ATTEMPT failed. Retrying in 30 seconds..."

  ATTEMPT=$((ATTEMPT+1))

  aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_repo_url}

  sleep 30

done

echo "Image pulled successfully."

# Start Twenty CRM
docker compose up -d

echo "Bootstrap completed successfully at $(date)."
