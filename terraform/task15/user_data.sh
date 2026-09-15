#!/bin/bash

set -e

LOG_FILE="/var/log/task15-user-data.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Task 15 EC2 Setup Started ====="

# --------------------------------------------------
# 1. Update Ubuntu
# --------------------------------------------------

apt-get update -y
apt-get upgrade -y

# --------------------------------------------------
# 2. Install required packages
# --------------------------------------------------

apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# --------------------------------------------------
# 3. Configure 2 GB Swap
# --------------------------------------------------

if ! swapon --show | grep -q "/swapfile"; then
    echo "Creating 2 GB swap..."

    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    echo "/swapfile none swap sw 0 0" >> /etc/fstab
fi

echo "===== Memory Status ====="
free -h

# --------------------------------------------------
# 4. Install Docker
# --------------------------------------------------

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
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

echo "===== Docker Version ====="
docker --version

docker compose version

# --------------------------------------------------
# 5. Create Twenty CRM Directory
# --------------------------------------------------

mkdir -p /opt/twenty
cd /opt/twenty

# --------------------------------------------------
# 6. Create Docker Compose
# --------------------------------------------------

cat > docker-compose.yml <<'EOF'
services:

  twenty-postgres:
    image: postgres:16-alpine
    container_name: twenty-postgres
    restart: unless-stopped

    environment:
      POSTGRES_DB: twenty
      POSTGRES_USER: twenty
      POSTGRES_PASSWORD: twenty_password

    volumes:
      - twenty-postgres-data:/var/lib/postgresql/data

    healthcheck:
      test:
        [
          "CMD-SHELL",
          "pg_isready -U twenty -d twenty"
        ]
      interval: 10s
      timeout: 5s
      retries: 10

    mem_limit: 512m
    mem_reservation: 256m

  twenty-redis:
    image: redis:7-alpine
    container_name: twenty-redis
    restart: unless-stopped

    command:
      - redis-server
      - --maxmemory
      - 256mb
      - --maxmemory-policy
      - allkeys-lru

    mem_limit: 256m
    mem_reservation: 128m

  twenty:
    image: twentycrm/twenty:v2.38.1
    container_name: twenty
    restart: unless-stopped

    ports:
      - "8080:3000"

    environment:
      SERVER_URL: http://${alb_dns_name}

      PG_DATABASE_URL: postgres://twenty:twenty_password@twenty-postgres:5432/twenty

      REDIS_URL: redis://twenty-redis:6379
      ENCRYPTION_KEY: "${encryption_key}"

      SIGN_IN_PREFILLED: "true"
      NODE_OPTIONS: "--max-old-space-size=768"

    depends_on:
      twenty-postgres:
        condition: service_healthy

      twenty-redis:
        condition: service_started

    mem_limit: 768m
    mem_reservation: 512m

volumes:

  twenty-postgres-data:

EOF

# --------------------------------------------------
# 7. Start Twenty CRM
# --------------------------------------------------

echo "===== Starting Twenty CRM ====="

docker compose pull
docker compose up -d

# --------------------------------------------------
# 8. Wait for Containers
# --------------------------------------------------

echo "===== Waiting for Twenty CRM ====="

sleep 30

docker compose ps

# --------------------------------------------------
# 9. Display Memory Usage
# --------------------------------------------------

echo "===== Docker Memory Usage ====="

docker stats --no-stream || true

# --------------------------------------------------
# 10. Display Local Health
# --------------------------------------------------

echo "===== Checking Twenty CRM ====="

for i in {1..12}; do

    if curl -fsS http://localhost:8080/ >/dev/null 2>&1; then
        echo "Twenty CRM is responding on port 8080."
        break
    fi

    echo "Waiting for Twenty CRM... attempt $i/12"
    sleep 10

done

echo "===== Final Container Status ====="

docker compose ps

echo "===== Task 15 EC2 Setup Completed ====="
