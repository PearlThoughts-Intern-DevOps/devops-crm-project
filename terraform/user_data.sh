#!/bin/bash

set -e

dnf update -y

# Install Docker
dnf install -y docker

# Start Docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to use Docker
usermod -aG docker ec2-user

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
  https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify Compose
docker compose version

# Create Twenty directory
mkdir -p /opt/twenty
cd /opt/twenty

cat > docker-compose.yml <<EOF
services:

  postgres:
    image: postgres:16-alpine
    container_name: twenty-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: twenty-postgres-password
      POSTGRES_DB: twenty
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d twenty"]
      interval: 5s
      timeout: 5s
      retries: 10

  twenty:
    image: twentycrm/twenty:latest
    container_name: twenty
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "3000:3000"
    environment:
      PG_DATABASE_URL: postgresql://postgres:twenty-postgres-password@postgres:5432/twenty
      STORAGE_TYPE: s3
      STORAGE_S3_BUCKET: ${s3_bucket}
      STORAGE_S3_REGION: ${aws_region}
      AWS_REGION: ${aws_region}

volumes:
  postgres_data:
EOF

docker compose up -d