#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/twenty-user-data.log | logger -t twenty-user-data -s 2>/dev/console) 2>&1

echo "=========================================================="
echo "Starting Twenty CRM EC2 Bootstrap behind ALB (Task 15)"
echo "Timestamp: $(date -u)"
echo "=========================================================="

APP_PORT="${app_port}"
echo "Configuration:"
echo "  Target Port: $${APP_PORT}"

# 1. Configure 2GB Swap space for t3.small stability (prevent OOM)
echo "=== Step 1: Configuring 2GB Swap Space ==="
if [ ! -f /swapfile ]; then
  echo "Allocating swapfile..."
  fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
  echo "Swap configured successfully:"
  free -h
fi

# 2. Install Docker and dependencies (Ubuntu and Amazon Linux compatible)
echo "=== Step 2: Installing Docker and required tools ==="
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y docker.io curl openssl
  systemctl enable --now docker
  usermod -aG docker ubuntu || true
elif command -v dnf >/dev/null 2>&1; then
  dnf update -y
  dnf install -y docker curl openssl
  systemctl enable --now docker
  usermod -aG docker ec2-user || true
fi

while ! docker info >/dev/null 2>&1; do
  echo "Waiting for Docker daemon to start..."
  sleep 2
done
echo "Docker daemon is active."

# 3. Create Docker network for container communication
echo "=== Step 3: Creating Docker network ==="
docker network create twenty-network 2>/dev/null || true

# 4. Run PostgreSQL 16
echo "=== Step 4: Starting PostgreSQL container ==="
docker rm -f twenty-db 2>/dev/null || true
docker run -d \
  --name twenty-db \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=twenty-task15-password \
  -e POSTGRES_DB=default \
  postgres:16-alpine

echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if docker exec twenty-db pg_isready -U postgres >/dev/null 2>&1; then
    echo "PostgreSQL is ready."
    break
  fi
  sleep 2
done

# 5. Run Redis 7
echo "=== Step 5: Starting Redis container ==="
docker rm -f twenty-redis 2>/dev/null || true
docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7-alpine

# 6. Run Twenty CRM production container
echo "=== Step 6: Starting Twenty CRM container on port $${APP_PORT} ==="
APP_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)

docker rm -f twenty-crm 2>/dev/null || true
docker run -d \
  --name twenty-crm \
  --network twenty-network \
  --restart unless-stopped \
  -p "$${APP_PORT}:3000" \
  -e NODE_PORT=3000 \
  -e SERVER_URL="http://0.0.0.0:$${APP_PORT}" \
  -e NODE_ENV=production \
  -e APP_SECRET="$APP_SECRET" \
  -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e FALLBACK_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e PG_DATABASE_URL=postgres://postgres:twenty-task15-password@twenty-db:5432/default \
  -e REDIS_URL=redis://twenty-redis:6379 \
  twentycrm/twenty:latest

echo "Twenty CRM container started."
docker ps -a

# 7. Local verification loop
echo "=== Step 7: Verifying Twenty CRM readiness ==="
for i in {1..40}; do
  if curl -fs "http://localhost:$${APP_PORT}/" >/dev/null 2>&1; then
    echo "Twenty CRM is healthy and responding on port $${APP_PORT} at $(date -u)!"
    break
  fi
  echo "Waiting for Twenty CRM to respond... attempt $${i}/40"
  sleep 5
done

echo "=== Twenty CRM EC2 Bootstrap Complete ==="
