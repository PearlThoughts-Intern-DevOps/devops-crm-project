#!/bin/bash
set -e

echo "Starting Twenty CRM Task 15 deployment..."

apt-get update
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

# Add 2 GiB swap if swap is not already configured
if [ "$(swapon --show | wc -l)" -eq 0 ]; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

docker rm -f twenty-crm 2>/dev/null || true

docker pull twentycrm/twenty-app-dev:latest

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL=http://localhost:2020 \
  -e PG_DATABASE_URL=postgres://twenty:twenty@localhost:5432/default \
  -e REDIS_URL=redis://localhost:6379 \
  -e APP_SECRET=twenty-task15-secret-not-for-production \
  twentycrm/twenty-app-dev:latest

echo "Twenty CRM container started."
