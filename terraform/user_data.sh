#!/bin/bash

# Update Ubuntu
apt-get update -y

# Install Docker and AWS CLI
apt-get install -y docker.io awscli

# Start Docker
systemctl start docker
systemctl enable docker

# Login to ECR
aws ecr get-login-password --region ${aws_region} | \
docker login --username AWS --password-stdin ${ecr_repository_url}

# Wait for Twenty CRM image
while ! docker pull ${ecr_repository_url}:latest
do
    echo "Waiting for Twenty CRM image in ECR..."
    sleep 30
done

# Run Twenty CRM
docker run -d \
    --name twenty-crm \
    --restart unless-stopped \
    -p ${host_port}:${twenty_container_port} \
    ${ecr_repository_url}:latest