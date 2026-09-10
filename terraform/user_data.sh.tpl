#!/bin/bash
set -euxo pipefail

# --- Install Docker + Docker Compose plugin ---
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

# --- Clone the app repo and check out the target branch ---
mkdir -p /opt/app
git clone --branch ${github_branch} --single-branch ${github_repo_url} /opt/app/devops-crm-project
cd /opt/app/devops-crm-project

# --- Write env vars so docker-compose picks up the Terraform-created bucket ---
cat > .env <<EOF
AWS_REGION=${aws_region}
STORAGE_TYPE=s3
STORAGE_S3_REGION=${aws_region}
STORAGE_S3_NAME=${s3_bucket_name}
S3_BUCKET_NAME=${s3_bucket_name}
EOF

# --- Bring the stack up ---
# NOTE: this instance uses its attached IAM role (EC2S3AccessRole) for
# S3 access — do NOT put access keys in .env.
docker compose build
docker compose up -d
