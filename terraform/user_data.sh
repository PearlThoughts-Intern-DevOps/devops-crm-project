#!/bin/bash
set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM setup..."

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

ECR_REPOSITORY_URL="${ecr_repository_url}"
AWS_REGION="us-east-1"
IMAGE="$ECR_REPOSITORY_URL:latest"

echo "ECR Repository: $ECR_REPOSITORY_URL"
echo "Image: $IMAGE"

until aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_REPOSITORY_URL"
do
  echo "ECR login failed. Retrying in 30 seconds..."
  sleep 30
done

echo "ECR authentication successful."

until docker pull "$IMAGE"
do
  echo "Image not available yet. Retrying in 30 seconds..."
  sleep 30

  aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REPOSITORY_URL"
done

echo "Image pulled successfully."

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL=http://0.0.0.0:2020 \
  -e NODE_ENV=development \
  -e APP_SECRET=twenty-task12-development-secret \
  "$IMAGE"

echo "Twenty CRM container started."

docker ps
