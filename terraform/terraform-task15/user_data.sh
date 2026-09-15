#!/bin/bash

set -e

apt-get update -y

apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  openssl

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

mkdir -p /opt/twenty
cd /opt/twenty

curl -fsSL \
  https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml \
  -o docker-compose.yml

curl -fsSL \
  https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/.env.example \
  -o .env

ENCRYPTION_KEY=$(openssl rand -base64 32)
DB_PASSWORD=$(openssl rand -hex 32)

echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env
echo "PG_DATABASE_PASSWORD=${DB_PASSWORD}" >> .env

docker compose up -d