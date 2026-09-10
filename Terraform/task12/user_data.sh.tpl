#!/bin/bash
set -x
exec > /var/log/user-data.log 2>&1

# --- Install Docker ---
apt update -y
apt install -y ca-certificates curl gnupg unzip
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable docker
systemctl start docker

# --- Install AWS CLI v2 ---
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install

# --- Authenticate Docker with ECR ---
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repo_url}

# --- Retry pulling the image until it's available ---
IMAGE="${ecr_repo_url}:latest"
MAX_ATTEMPTS=30
ATTEMPT=1

until docker pull "$IMAGE"; do
  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "Image pull failed after $MAX_ATTEMPTS attempts. Giving up."
    exit 1
  fi
  echo "Attempt $ATTEMPT: image not available yet, retrying in 30s..."
  ATTEMPT=$((ATTEMPT+1))
  aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repo_url}
  sleep 30
done

echo "Image pulled successfully. Starting Twenty CRM..."

# --- Run the app ---
# NOTE: the image built from this repo's Dockerfile (Task 5) is a Twenty SDK
# dev-sync tool, not a standalone server - see README.md "Issues encountered"
# for the manual deployment steps actually used to get the app fully running
# (official twentycrm/twenty image + Postgres + Redis on this instance).
docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p ${app_port}:3000 \
  "$IMAGE"

echo "Twenty CRM container started."