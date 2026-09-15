#!/bin/bash

apt-get update -y
apt-get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable docker
systemctl start docker

mkdir -p /opt/twenty

cat > /opt/twenty/docker-compose.yml <<'EOF'
services:

  twenty:
    image: twentycrm/twenty:latest
    container_name: twenty-crm
    ports:
      - "2020:3000"
    environment:
      SERVER_URL: http://localhost:2020
      PG_DATABASE_URL: postgres://twenty:twenty@postgres:5432/default
      REDIS_URL: redis://redis:6379
      STORAGE_TYPE: local
      APP_SECRET: twenty-task-15-secret
      NODE_ENV: production
      DISABLE_DB_MIGRATIONS: "false"
      DISABLE_CRON_JOBS_REGISTRATION: "false"
      IS_BILLING_ENABLED: "false"
    volumes:
      - twenty-storage:/app/packages/twenty-server/.local-storage
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - twenty-network

  postgres:
    image: postgres:16-alpine
    container_name: twenty-postgres
    environment:
      POSTGRES_USER: twenty
      POSTGRES_PASSWORD: twenty
      POSTGRES_DB: default
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U twenty -d default"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - twenty-network

  redis:
    image: redis:7-alpine
    container_name: twenty-redis
    command: ["redis-server", "--maxmemory-policy", "noeviction"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - twenty-network

volumes:
  twenty-storage:
  postgres-data:

networks:
  twenty-network:
    driver: bridge
EOF

cd /opt/twenty
docker compose up -d