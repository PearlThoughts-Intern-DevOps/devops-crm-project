#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

# --- Start a tiny log server immediately so we can watch progress remotely
cd /var/log
nohup python3 -m http.server 8080 > /var/log/logserver.log 2>&1 &

echo "=== DISK SPACE AT START ==="
df -h /

# --- Install Docker & the Compose plugin (skip buildx, not needed for compose up)
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Free apt cache immediately, we don't need it again
apt-get clean
rm -rf /var/lib/apt/lists/*

systemctl enable docker
systemctl start docker

echo "=== DOCKER INSTALLED, DISK SPACE NOW: ==="
df -h /

echo "=== STARTING TWENTY CRM INSTALL ==="

mkdir -p /opt/twenty
cd /opt/twenty

curl -sLo docker-compose.yml https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml
curl -sLo .env https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/.env.example

sed -i "s|^SERVER_URL=.*|SERVER_URL=${server_url}|" .env
echo "ENCRYPTION_KEY=$(openssl rand -base64 32)" >> .env
echo "PG_DATABASE_PASSWORD=$(openssl rand -hex 32)" >> .env

# Don't let a failed 'up' kill the script before we capture logs
docker compose up -d || true

echo "=== DOCKER COMPOSE PS ==="
docker compose ps

echo "=== SERVER CONTAINER LOGS ==="
docker compose logs server --no-color || true

echo "=== DB CONTAINER LOGS ==="
docker compose logs db --no-color || true

echo "=== USER DATA SCRIPT FINISHED ==="
sleep 10
docker compose ps
echo "=== FINAL DISK SPACE ==="
df -h /