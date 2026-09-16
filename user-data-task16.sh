#!/bin/bash
set -euo pipefail
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========================================="
echo "  Starting Twenty CRM Bootstrap (Task 16)"
echo "  $(date -u)"
echo "========================================="

# 1. Swap space setup (2GB) to ensure stability on t3.small
if [ ! -f /swapfile ]; then
    echo "Creating 2GB swapfile..."
    fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
    sysctl vm.swappiness=10
fi

# 2. Install Docker and utilities
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io curl jq openssl
systemctl daemon-reload
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Wait for Docker daemon
until docker info >/dev/null 2>&1; do
    echo "Waiting for Docker daemon..."
    sleep 2
done
echo "Docker daemon is active."

# 3. Pull Twenty CRM image
echo "Pulling twentycrm/twenty-app-dev:latest..."
docker pull twentycrm/twenty-app-dev:latest

# 4. Launch Twenty CRM container with restart policy and health check
echo "Launching twenty-crm container..."
docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL="http://localhost:2020" \
  -e APP_SECRET="twenty-failure-recovery-secret-task16-mohit" \
  -e SIGN_IN_PREFILLED=true \
  --health-cmd="curl -f http://localhost:2020/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-start-period=120s \
  --health-retries=3 \
  twentycrm/twenty-app-dev:latest

echo "Container launched."
docker ps -a
docker inspect twenty-crm --format='Name={{.Name}} RestartPolicy={{.HostConfig.RestartPolicy.Name}} Status={{.State.Status}}'

echo "Twenty CRM bootstrap complete at $(date -u)"
