#!/bin/bash

set -e

dnf update -y

dnf install -y docker curl openssl

systemctl enable docker
systemctl start docker

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Download Twenty Docker files
mkdir -p /opt/twenty
cd /opt/twenty

curl -fsSL \
  https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml \
  -o docker-compose.yml

curl -fsSL \
  https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/.env.example \
  -o .env

# Get latest Twenty release
VERSION=$(curl -fsS \
  https://hub.docker.com/v2/repositories/twentycrm/twenty/tags?page_size=100 \
  | grep -o '"name":"v[0-9]*\.[0-9]*\.[0-9]*"' \
  | cut -d'"' -f4 \
  | sort -V \
  | tail -n1)

# Set Twenty version
sed -i "s/TAG=latest/TAG=$VERSION/g" .env

# Generate required secrets
echo "ENCRYPTION_KEY=$(openssl rand -base64 32)" >> .env
echo "PG_DATABASE_PASSWORD=$(openssl rand -hex 32)" >> .env

# Start Twenty CRM
docker compose up -d

echo "Twenty CRM installation completed."