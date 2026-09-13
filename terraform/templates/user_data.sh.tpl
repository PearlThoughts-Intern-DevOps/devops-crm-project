#!/bin/bash

set -uo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Twenty CRM S3 bootstrap started at $(date) ==="

echo "=== Installing Docker ==="
dnf update -y
dnf install -y docker openssl

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user || true

echo "=== Adding 2GB swap ==="
# Running 4 separate containers (Twenty server, Twenty worker, Postgres,
# Redis) simultaneously on a t3.small's 2GB RAM caused severe memory
# pressure without this -- SSH itself became unresponsive during the
# migration-heavy startup phase. This exact swap setup resolved the
# identical symptom in an earlier task on the same instance type.
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

echo "=== Installing Docker Compose v2 ==="
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
  https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "=== Verifying Docker Compose ==="
docker compose version

echo "=== Preparing Twenty CRM directory ==="
mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

echo "=== Generating Twenty encryption key ==="
ENCRYPTION_KEY=$(openssl rand -hex 32)

cat > /opt/twenty-crm/.env <<ENV_EOF
ENCRYPTION_KEY=$${ENCRYPTION_KEY}
STORAGE_TYPE=S_3
STORAGE_S3_REGION=${aws_region}
STORAGE_S3_NAME=${bucket_name}
ENV_EOF

chmod 600 /opt/twenty-crm/.env

echo "=== Creating Docker Compose configuration ==="

cat > /opt/twenty-crm/docker-compose.yml <<COMPOSE_EOF
services:

  server:
    image: twentycrm/twenty:latest
    container_name: twenty-crm-server
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      NODE_PORT: 3000
      SERVER_URL: ${server_url}
      PG_DATABASE_URL: postgresql://postgres:postgres@db:5432/twenty
      REDIS_URL: redis://redis:6379
      STORAGE_TYPE: S_3
      STORAGE_S3_REGION: ${aws_region}
      STORAGE_S3_NAME: ${bucket_name}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      - db
      - redis

  worker:
    image: twentycrm/twenty:latest
    container_name: twenty-crm-worker
    restart: unless-stopped
    command: ["yarn", "worker:prod"]
    environment:
      NODE_PORT: 3000
      PG_DATABASE_URL: postgresql://postgres:postgres@db:5432/twenty
      REDIS_URL: redis://redis:6379
      STORAGE_TYPE: S_3
      STORAGE_S3_REGION: ${aws_region}
      STORAGE_S3_NAME: ${bucket_name}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    container_name: twenty-crm-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: twenty
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - twenty-db-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    container_name: twenty-crm-redis
    restart: unless-stopped
    volumes:
      - twenty-redis-data:/data

volumes:
  twenty-db-data:
  twenty-redis-data:
COMPOSE_EOF

echo "=== Validating Docker Compose configuration ==="
docker compose -f /opt/twenty-crm/docker-compose.yml config >/dev/null

echo "=== Starting Twenty CRM ==="
cd /opt/twenty-crm
docker compose up -d

echo "=== Docker containers ==="
docker compose ps

echo "=== Twenty CRM S3 bootstrap completed at $(date) ==="
echo "=== S3 bucket: ${bucket_name} ==="
