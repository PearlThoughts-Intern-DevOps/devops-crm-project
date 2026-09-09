#!/bin/bash
set -euo pipefail

LOG=/var/log/twenty-crm-bootstrap.log
exec > >(tee -a $LOG) 2>&1

echo "=== Twenty CRM bootstrap started: $(date) ==="

AWS_REGION="${aws_region}"
ECR_REPO_URL="${ecr_repo_url}"
ECR_IMAGE_TAG="${ecr_image_tag}"
APP_PORT="${app_port}"
ECR_REGISTRY="$(echo "$ECR_REPO_URL" | cut -d'/' -f1)"

export DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# 1. Install Docker and dependencies (Ubuntu 20.04)
# ---------------------------------------------------------------------------
apt-get update -y
apt-get install -y ca-certificates curl gnupg unzip

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

# ---------------------------------------------------------------------------
# 2. Authenticate Docker with ECR
# ---------------------------------------------------------------------------
authenticate_ecr() {
  echo "Authenticating with ECR: $ECR_REGISTRY"
  aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REGISTRY"
}

until authenticate_ecr; do
  echo "ECR auth failed, retrying in 10s..."
  sleep 10
done

# ---------------------------------------------------------------------------
# 3. Retry-pull the Twenty CRM image until it is available
# ---------------------------------------------------------------------------
IMAGE="$ECR_REPO_URL:$ECR_IMAGE_TAG"
MAX_ATTEMPTS=60
ATTEMPT=1

echo "Pulling image: $IMAGE"
until docker pull "$IMAGE"; do
  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "ERROR: image not available after $MAX_ATTEMPTS attempts. Giving up."
    exit 1
  fi
  echo "Image not available yet (attempt $ATTEMPT/$MAX_ATTEMPTS). Retrying in 30s..."
  authenticate_ecr || true
  sleep 30
  ATTEMPT=$((ATTEMPT + 1))
done

echo "Image pulled successfully."

# ---------------------------------------------------------------------------
# 4. Run Twenty CRM
# ---------------------------------------------------------------------------
mkdir -p /opt/twenty-crm
cat > /opt/twenty-crm/docker-compose.yml <<COMPOSE
version: "3.8"
services:
  db:
    image: postgres:16
    restart: always
    environment:
      POSTGRES_USER: twenty
      POSTGRES_PASSWORD: twenty
      POSTGRES_DB: default
    volumes:
      - db-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    restart: always

  server:
    image: $IMAGE
    restart: always
    depends_on:
      - db
      - redis
    ports:
      - "$APP_PORT:3000"
    environment:
      PG_DATABASE_URL: postgres://twenty:twenty@db:5432/default
      REDIS_URL: redis://redis:6379
      SERVER_URL: http://localhost:$APP_PORT
      APP_SECRET: replace-with-a-generated-secret

volumes:
  db-data:
COMPOSE

cd /opt/twenty-crm
docker compose up -d

echo "=== Twenty CRM bootstrap finished: $(date) ==="