#!/bin/bash
set -uo pipefail

exec > >(tee /var/log/user-data.log) 2>&1

echo "===== Twenty CRM setup started ====="

dnf update -y
dnf install -y docker openssl

systemctl enable --now docker

usermod -aG docker ec2-user

mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

ENCRYPTION_KEY=$(openssl rand -hex 32)

cat > /opt/twenty-crm/.env <<ENV_EOF
ENCRYPTION_KEY=$${ENCRYPTION_KEY}
SERVER_URL=${server_url}
PG_DATABASE_URL=postgresql://postgres:postgres@db:5432/twenty
REDIS_URL=redis://redis:6379
NODE_PORT=3000
ENV_EOF

cat > /opt/twenty-crm/docker-compose.yml <<'COMPOSE_EOF'
services:

  server:
    image: twentycrm/twenty:latest
    container_name: twenty-server
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      NODE_PORT: 3000
      SERVER_URL: $${SERVER_URL}
      PG_DATABASE_URL: $${PG_DATABASE_URL}
      REDIS_URL: $${REDIS_URL}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      - db
      - redis

  worker:
    image: twentycrm/twenty:latest
    container_name: twenty-worker
    restart: unless-stopped
    command: ["yarn", "worker:prod"]
    environment:
      NODE_PORT: 3000
      SERVER_URL: $${SERVER_URL}
      PG_DATABASE_URL: $${PG_DATABASE_URL}
      REDIS_URL: $${REDIS_URL}
      ENCRYPTION_KEY: $${ENCRYPTION_KEY}
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    container_name: twenty-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: twenty
    volumes:
      - twenty-postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    container_name: twenty-redis
    restart: unless-stopped

volumes:
  twenty-postgres-data:
COMPOSE_EOF

/usr/local/bin/docker-compose up -d

echo "===== Twenty CRM setup completed ====="
