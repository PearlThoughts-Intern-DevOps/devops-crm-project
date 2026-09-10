#!/bin/bash

set -euxo pipefail

exec > >(tee /var/log/task13-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Task 13 User Data Started ==="

# Update packages
apt-get update -y
apt-get upgrade -y

# Install required dependencies
apt-get install -y \
  docker.io \
  curl \
  unzip \
  ca-certificates
# Configure 2 GB swap
if ! swapon --show | grep -q '/swapfile'; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "Swap configuration:"
free -h

# Install AWS CLI if not already available
if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
fi

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Wait for Docker
until docker info >/dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 5
done

echo "Docker is ready"

# Configuration
AWS_REGION="${aws_region}"
S3_BUCKET_NAME="${s3_bucket_name}"
IMAGE_TAG="${image_tag}"

TWENTY_IMAGE="twentycrm/twenty-app-dev:$${IMAGE_TAG}"

# Pull Twenty CRM image with retry logic
MAX_RETRIES=30
RETRY_INTERVAL=20

for attempt in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $${attempt}/$${MAX_RETRIES}: Pulling Twenty CRM image..."

  if docker pull "$${TWENTY_IMAGE}"; then
    echo "Twenty CRM image pulled successfully."
    break
  fi

  if [ "$${attempt}" -eq "$${MAX_RETRIES}" ]; then
    echo "Failed to pull Twenty CRM image after $${MAX_RETRIES} attempts."
    exit 1
  fi

  echo "Image not available yet. Retrying in $${RETRY_INTERVAL} seconds..."
  sleep "$${RETRY_INTERVAL}"
done

# Remove any previous Twenty container
docker rm -f twenty-server 2>/dev/null || true

# Get EC2 public IP using IMDSv2
METADATA_TOKEN=$(curl -sX PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -s \
  -H "X-aws-ec2-metadata-token: $${METADATA_TOKEN}" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

echo "EC2 Public IP: $${PUBLIC_IP}"

# Create Twenty CRM container
docker run -d \
  --name twenty-server \
  --restart unless-stopped \
  -p 8080:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL="http://$${PUBLIC_IP}:8080" \
  -e STORAGE_TYPE="S3" \
  -e STORAGE_S3_REGION="$${AWS_REGION}" \
  -e STORAGE_S3_NAME="$${S3_BUCKET_NAME}" \
  -e STORAGE_S3_ENDPOINT="https://s3.$${AWS_REGION}.amazonaws.com" \
  "$${TWENTY_IMAGE}"

echo "Twenty CRM container started."

# Wait for Twenty CRM to become healthy
for attempt in $(seq 1 30); do
  if curl -fsS --max-time 10 http://localhost:8080 >/dev/null 2>&1; then
    echo "Twenty CRM is responding."
    break
  fi

  echo "Waiting for Twenty CRM to start... attempt $${attempt}/30"
  sleep 10
done

echo "=== Task 13 User Data Completed ==="
