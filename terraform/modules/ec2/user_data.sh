#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

S3_BUCKET_NAME="${s3_bucket_name}"

docker pull twentycrm/twenty-app-dev:latest

docker run -d \
  --name twenty-crm \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL=http://localhost:2020 \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION=us-east-1 \
  -e STORAGE_S3_NAME="$S3_BUCKET_NAME" \
  -e APP_VERSION=v2.37.0 \
  -e NODE_ENV=development \
  -e IS_BILLING_ENABLED=false \
  -e SIGN_IN_PREFILLED=true \
  twentycrm/twenty-app-dev:latest
