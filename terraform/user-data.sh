#!/bin/bash

# Update packages
dnf update -y

# Install Docker and AWS CLI
dnf install -y docker awscli

# Start Docker
systemctl start docker
systemctl enable docker

# ECR details
REGION="${aws_region}"
ECR_URL="${ecr_repository_url}"
IMAGE="${ecr_repository_url}:latest"

# Login to ECR
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ECR_URL

# Try to pull the image until it is available
while ! docker pull $IMAGE
do
    echo "Image not available yet. Retrying in 30 seconds..."
    sleep 30
done

# Run Twenty CRM
docker run -d \
    --name twenty-crm \
    --restart unless-stopped \
    -p ${app_port}:3000 \
    $IMAGE

echo "Twenty CRM started successfully."