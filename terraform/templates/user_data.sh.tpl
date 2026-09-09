#!/bin/bash
# user_data.sh.tpl
#
# Rendered by Terraform's templatefile() with:
#   aws_region          - the AWS region (for ECR auth)
#   ecr_repository_url  - the ECR repository URL created by Terraform
#   image_tag           - the tag to pull (matches what's pushed locally)
#
# Runs automatically on first boot via EC2 user data. Logs go to
# /var/log/user-data.log so progress/issues can be inspected via SSH
# even though nobody is watching this run interactively.

set -uo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Twenty CRM EC2 bootstrap started at $(date) ==="

# ---------------------------------------------------------------------
# 1. Install Docker and required dependencies
# ---------------------------------------------------------------------
echo "=== Installing Docker ==="
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# ec2-user isn't needed here since this script runs as root, but
# adding it anyway makes manual `docker` commands work without sudo
# for anyone who SSHes in afterward.
usermod -aG docker ec2-user || true

# ---------------------------------------------------------------------
# 2. Authenticate with Amazon ECR
# ---------------------------------------------------------------------
# awscli v2 ships preinstalled on Amazon Linux 2023. Credentials come
# from the IAM instance profile attached to this instance (see iam.tf)
# -- no access keys are stored anywhere on this machine.
echo "=== Authenticating with Amazon ECR ==="
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_repository_url}

# ---------------------------------------------------------------------
# 3. Attempt to pull the image, retrying periodically until available
# ---------------------------------------------------------------------
# The EC2 instance is created by `terraform apply` BEFORE the image is
# built/pushed (that happens afterward, from the local machine using
# the ECR URL from Terraform's output) -- so the image may genuinely
# not exist in ECR yet on first boot. Retry with a fixed delay instead
# of failing immediately.
IMAGE="${ecr_repository_url}:${image_tag}"
MAX_ATTEMPTS=30
DELAY_SECONDS=30

echo "=== Waiting for image $${IMAGE} to become available in ECR ==="
for attempt in $(seq 1 $${MAX_ATTEMPTS}); do
  if docker pull "$${IMAGE}"; then
    echo "=== Image pulled successfully on attempt $${attempt} ==="
    break
  fi
  echo "=== Attempt $${attempt}/$${MAX_ATTEMPTS} failed, retrying in $${DELAY_SECONDS}s ==="
  sleep "$${DELAY_SECONDS}"
done

if ! docker image inspect "$${IMAGE}" > /dev/null 2>&1; then
  echo "=== ERROR: image never became available after $${MAX_ATTEMPTS} attempts ==="
  exit 1
fi

# ---------------------------------------------------------------------
# 4. Run the Twenty CRM application
# ---------------------------------------------------------------------
# The app image alone can't run standalone -- it's a CLI-driven process
# (see Dockerfile) that syncs into a separately-running Twenty CRM
# server. Write a minimal docker-compose file so both come up together,
# same architecture as the earlier Docker Containerization task.
echo "=== Writing docker-compose.yml and starting the application ==="
mkdir -p /opt/twenty-crm
cat > /opt/twenty-crm/docker-compose.yml << COMPOSE_EOF
services:
  twenty:
    image: twentycrm/twenty-app-dev:latest
    container_name: twenty-crm-server
    ports:
      - "2020:2020"
    volumes:
      - twenty-server-data:/app/data
    restart: unless-stopped

  app:
    image: $${IMAGE}
    container_name: devops-crm-app
    depends_on:
      - twenty
    network_mode: "service:twenty"
    environment:
      - NODE_ENV=production
    volumes:
      - twenty-cli-config:/app/.twenty

volumes:
  twenty-server-data:
  twenty-cli-config:
COMPOSE_EOF

# docker-compose (not the built-in compose plugin) is used here for
# consistency with earlier tasks on this same Amazon Linux 2023 AMI,
# where the compose plugin isn't available via dnf.
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd /opt/twenty-crm
/usr/local/bin/docker-compose up -d

echo "=== Twenty CRM bootstrap completed at $(date) ==="
echo "=== NOTE: the app container still needs one-time CLI authentication ==="
echo "===       (docker-compose exec app yarn twenty remote:add --url http://localhost:2020 --api-key '<key>') ==="
echo "===       this cannot be automated here since it requires a key generated from the running Twenty UI ==="
