#!/bin/bash
set -e

echo "Starting Twenty CRM S3 deployment..."

apt-get update
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

S3_BUCKET="${s3_bucket_name}"
AWS_REGION="${aws_region}"

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
  -e APP_SECRET=twenty-s3-task-secret-not-for-production \
  twentycrm/twenty-app-dev:latest

echo "Twenty CRM container started with S3 storage configuration."
