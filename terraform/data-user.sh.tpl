#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

echo "========================================="
echo "  Twenty CRM Bootstrap Started"
echo "  $(date -u)"
echo "========================================="

echo "[1/4] Installing Docker and AWS CLI..."
apt-get update -y
apt-get install -y docker.io awscli curl

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Docker version: $(docker --version)"
echo "AWS CLI version: $(aws --version)"

# Variables passed from Terraform templatefile()
AWS_REGION="${aws_region}"
APP_PORT="${app_port}"
APP_NAME="${app_name}"
S3_BUCKET="${s3_bucket_name}"

echo "[2/4] Pulling Twenty CRM image from Docker Hub..."
docker pull twentycrm/twenty:latest

echo "[3/4] Starting Twenty CRM with S3 as storage backend..."
docker rm -f "$APP_NAME" 2>/dev/null || true

docker run -d \
  --name "$APP_NAME" \
  --restart unless-stopped \
  -p "$APP_PORT:3000" \
  -e NODE_ENV=production \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET" \
  twentycrm/twenty:latest

echo "[4/4] Bootstrap complete!"
echo "========================================="
echo "  App : http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):$APP_PORT"
echo "  S3  : $S3_BUCKET"
echo "  $(date -u)"
echo "========================================="

