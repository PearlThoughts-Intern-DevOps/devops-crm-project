#!/bin/bash

set -e

dnf update -y
dnf install -y docker curl

systemctl enable --now docker

mkdir -p /opt/twenty
cd /opt/twenty

TOKEN=$(curl -sS -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/api/token)

PUBLIC_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/public-ipv4)

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64 | tr -d "\n")

cat > docker-compose.yml <<'COMPOSE'
services:
  server:
    image: twentycrm/twenty:latest
    ports:
      - "3000:3000"
    environment:
      NODE_PORT: 3000
      PG_DATABASE_URL: postgres://postgres:postgres@db:5432/default
      SERVER_URL: http://$${PUBLIC_IP}:3000
      REDIS_URL: redis://redis:6379
      STORAGE_TYPE: s3
      STORAGE_S3_REGION: $${AWS_REGION}
      STORAGE_S3_NAME: $${S3_BUCKET}
      APP_SECRET: $${APP_SECRET}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: always

  worker:
    image: twentycrm/twenty:latest
    command: ["yarn", "worker:prod"]
    environment:
      PG_DATABASE_URL: postgres://postgres:postgres@db:5432/default
      SERVER_URL: http://$${PUBLIC_IP}:3000
      REDIS_URL: redis://redis:6379
      DISABLE_DB_MIGRATIONS: "true"
      DISABLE_CRON_JOBS_REGISTRATION: "true"
      STORAGE_TYPE: s3
      STORAGE_S3_REGION: $${AWS_REGION}
      STORAGE_S3_NAME: $${S3_BUCKET}
      APP_SECRET: $${APP_SECRET}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      db:
        condition: service_healthy
      server:
        condition: service_healthy
    restart: always

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: default
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -h localhost -d postgres"]
      interval: 5s
      timeout: 5s
      retries: 10
    restart: always

  redis:
    image: redis
    command: ["--maxmemory-policy", "noeviction"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10
    restart: always

volumes:
  db-data:
COMPOSE

cat > .env <<ENV
AWS_REGION=${aws_region}
S3_BUCKET=${s3_bucket_name}
APP_SECRET=task13-twenty-crm-secret-change-me
ENCRYPTION_KEY=$${ENCRYPTION_KEY}
PUBLIC_IP=$${PUBLIC_IP}
ENV

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose pull
docker compose up -d

echo "Twenty CRM Docker Compose deployment completed."
