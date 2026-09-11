#!/bin/bash
set -uo pipefail

LOG_FILE=/var/log/twenty-crm-userdata.log
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Twenty CRM bootstrap starting at $(date) ==="

# --- 0. Basic system setup ---
systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
systemctl start ssh 2>/dev/null || systemctl start sshd 2>/dev/null || true
ufw disable 2>/dev/null || true

# --- 1. Swap ---
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile || true
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# --- 2. Install Docker + AWS CLI + OpenSSL + Curl ---
for i in 1 2 3; do
  if apt-get update -y; then
    break
  fi
  echo "apt-get update retry $i..."
  sleep 10
done

DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io awscli openssl curl

systemctl enable docker
systemctl start docker

# --- 3. Create Docker network ---
docker network create twenty-net 2>/dev/null || true

# --- 4. Start PostgreSQL ---
docker rm -f twenty-db 2>/dev/null || true

docker run -d \
  --name twenty-db \
  --restart unless-stopped \
  --network twenty-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=default \
  -v twenty-db-data:/var/lib/postgresql/data \
  postgres:16

# --- 5. Start Redis ---
docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --restart unless-stopped \
  --network twenty-net \
  -v twenty-redis-data:/data \
  redis:7

# --- 6. Wait for PostgreSQL ---
echo "Waiting for PostgreSQL..."

for i in $(seq 1 30); do
  if docker exec twenty-db pg_isready -U postgres -d default >/dev/null 2>&1; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "PostgreSQL not ready yet... attempt $i/30"
  sleep 5
done

# --- 7. Login to ECR ---
for i in 1 2 3 4 5; do
  if aws ecr get-login-password --region "${aws_region}" \
       | docker login --username AWS --password-stdin "${ecr_repository_url}"; then
    echo "ECR login OK"
    break
  fi
  echo "ECR login retry $i..."
  sleep 15
done

# --- 8. Pull Twenty image ---
MAX_RETRIES=20
attempt=1

until docker pull "${ecr_repository_url}:latest"; do
  if [ "$attempt" -ge "$MAX_RETRIES" ]; then
    echo "ERROR: Twenty image never became available"
    exit 1
  fi
  echo "Pull attempt $attempt/$MAX_RETRIES failed"
  sleep 30
  attempt=$((attempt + 1))
done

# --- 9. Generate application secret ---
APP_SECRET=$(openssl rand -hex 32)

# --- 10. Get EC2 public IP using IMDSv2 ---
TOKEN=$(curl -sS -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -sS \
  -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  "http://169.254.169.254/latest/meta-data/public-ipv4")

echo "EC2 public IP: $${PUBLIC_IP}"

# --- 11. Remove old Twenty container if present ---
docker rm -f twenty-crm 2>/dev/null || true

# --- 12. Start Twenty CRM ---
docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  --network twenty-net \
  -p ${app_port}:3000 \
  -e NODE_PORT=3000 \
  -e SERVER_URL="http://$${PUBLIC_IP}:${app_port}" \
  -e PG_DATABASE_URL="postgres://postgres:postgres@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e STORAGE_TYPE=local \
  -e APP_SECRET="$${APP_SECRET}" \
  -e IS_BILLING_ENABLED=false \
  "${ecr_repository_url}:latest"

# --- 13. Wait for Twenty CRM ---
echo "Waiting for Twenty CRM..."

for i in $(seq 1 60); do
    if curl -fsS "http://localhost:${app_port}" >/dev/null 2>&1; then 
    echo "Twenty CRM is healthy"
    break
  fi
  echo "Twenty CRM not ready yet... attempt $i/60"
  sleep 5
done

echo "=== Twenty CRM bootstrap completed at $(date) ==="

docker ps