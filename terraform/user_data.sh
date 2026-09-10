#!/bin/bash

# Update Ubuntu
apt-get update -y

# Install Docker and AWS CLI
apt-get install -y docker.io awscli

# Start Docker
systemctl enable docker
systemctl start docker

# Pull the official Twenty CRM image
docker pull twentycrm/twenty:latest

# Run Twenty CRM with S3 storage configuration
docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p ${host_port}:${twenty_container_port} \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION=${aws_region} \
  -e STORAGE_S3_NAME=${s3_bucket_name} \
  twentycrm/twenty:latest