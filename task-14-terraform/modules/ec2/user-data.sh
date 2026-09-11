#!/bin/bash
set -e

echo "Starting Twenty CRM Task 14 deployment..."

apt-get update
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

AWS_REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository_url}"
S3_BUCKET="${s3_bucket_name}"

aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_REPOSITORY"

docker pull "$ECR_REPOSITORY:latest"

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL=http://localhost:2020 \
  -e PG_DATABASE_URL=postgres://twenty:twenty@localhost:5432/default \
  -e REDIS_URL=redis://localhost:6379 \
  -e STORAGE_TYPE=S3 \
  -e STORAGE_S3_REGION="$AWS_REGION" \
  -e STORAGE_S3_NAME="$S3_BUCKET" \
  -e APP_SECRET=twenty-task14-secret-not-for-production \
  "$ECR_REPOSITORY:latest"

echo "Twenty CRM container started."
