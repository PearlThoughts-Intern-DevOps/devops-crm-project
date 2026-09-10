#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

echo "========================================="
echo "  Twenty CRM Bootstrap Started"
echo "  $(date -u)"
echo "========================================="

echo "[1/5] Installing Docker and AWS CLI..."
apt-get update -y
apt-get install -y docker.io awscli curl

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Docker: $(docker --version)"
echo "AWS CLI: $(aws --version)"

AWS_REGION="${aws_region}"
ECR_REPO_URL="${ecr_repo_url}"
IMAGE_TAG="${image_tag}"
APP_PORT="${app_port}"
APP_NAME="${app_name}"
FULL_IMAGE="$ECR_REPO_URL:$IMAGE_TAG"

echo "[2/5] Authenticating with ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REPO_URL"

echo "[3/5] Pulling image: $FULL_IMAGE"
MAX_RETRIES=30
RETRY_INTERVAL=60
attempt=1

while [ $attempt -le $MAX_RETRIES ]; do
  echo "Attempt $attempt/$MAX_RETRIES..."
  if docker pull "$FULL_IMAGE"; then
    echo "Image pulled successfully!"
    break
  else
    echo "Retrying in $RETRY_INTERVAL seconds..."
    if [ $attempt -eq $MAX_RETRIES ]; then
      echo "ERROR: Max retries reached."
      exit 1
    fi
    sleep $RETRY_INTERVAL
    aws ecr get-login-password --region "$AWS_REGION" \
      | docker login --username AWS --password-stdin "$ECR_REPO_URL" || true
  fi
  attempt=$((attempt + 1))
done

echo "[4/5] Starting Twenty CRM App..."
docker rm -f "$APP_NAME" 2>/dev/null || true
docker run -d \
  --name "$APP_NAME" \
  --restart unless-stopped \
  -p "$APP_PORT:3000" \
  -e NODE_ENV=production \
  "$FULL_IMAGE"

echo "[5/5] Done!"
echo "========================================="
echo "  App running on port $APP_PORT"
echo "  $(date -u)"
echo "========================================="
