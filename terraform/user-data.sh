#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/twenty-user-data.log | logger -t twenty-user-data -s 2>/dev/console) 2>&1

echo "=== Twenty CRM EC2 bootstrap starting at $(date -u) ==="

REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository}"
IMAGE_TAG="${docker_image_tag}"
APP_PORT="${app_port}"
IMAGE="$${ECR_REPOSITORY}:$${IMAGE_TAG}"
REGISTRY="$${ECR_REPOSITORY%%/*}"

# 1. Quick Swap Space (4 GB)
if [ ! -f /swapfile ]; then
  echo "Setting up 4GB swap space..."
  fallocate -l 4G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=4096 status=none
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

# 2. Install Docker and AWS CLI
echo "Installing Docker and AWS CLI..."
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y docker.io awscli curl
  systemctl enable --now docker
  usermod -aG docker ubuntu || true
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y docker awscli curl openssl || true
  systemctl enable --now docker
  usermod -aG docker ec2-user || true
fi

# Ensure docker daemon is ready
while ! docker info >/dev/null 2>&1; do
  echo "Waiting for Docker daemon..."
  sleep 2
done

# 3. Authenticate with ECR and pull image
echo "Authenticating with Amazon ECR ($${REGISTRY})..."
MAX_RETRIES=40
RETRY_INTERVAL=10

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt $${i}/$${MAX_RETRIES}: ECR login and pull..."
  if aws ecr get-login-password --region "$${REGION}" | docker login --username AWS --password-stdin "$${REGISTRY}"; then
    if docker pull "$${IMAGE}"; then
      echo "Successfully pulled $${IMAGE}"
      break
    fi
  fi
  echo "Pull failed or image not ready. Retrying in $${RETRY_INTERVAL} seconds..."
  sleep "$${RETRY_INTERVAL}"
done

# 4. Run Twenty CRM Container
echo "Starting Twenty CRM container on port $${APP_PORT}..."
docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p "$${APP_PORT}:2020" \
  "$${IMAGE}"

echo "=== Twenty CRM EC2 bootstrap finished at $(date -u) ==="
docker ps -a
