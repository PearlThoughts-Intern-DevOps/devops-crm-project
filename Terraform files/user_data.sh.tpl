#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y ca-certificates curl gnupg git

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu || true

mkdir -p /opt/app
git clone --branch ${github_branch} --single-branch ${github_repo_url} /opt/app/devops-crm-project
cd /opt/app/devops-crm-project

cat > .env <<EOF
AWS_REGION=${aws_region}
STORAGE_TYPE=S_3
STORAGE_S3_REGION=${aws_region}
STORAGE_S3_NAME=${s3_bucket_name}
S3_BUCKET_NAME=${s3_bucket_name}
ECR_REPOSITORY_URL=${ecr_repository_url}
EOF

# NOTE: this instance uses its attached IAM role (EC2S3AccessRole) for
# S3/ECR access — do NOT put access keys in .env.
docker compose build
docker compose up -d
