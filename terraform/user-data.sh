!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/twenty-user-data.log | logger -t twenty-user-data -s 2>/dev/console) 2>&1

echo "========================================================"
echo "Starting Twenty CRM EC2 Bootstrap with S3 Storage Backend"
echo "Timestamp: $(date -u)"
echo "========================================================"

REGION="${aws_region}"
BUCKET_NAME="${s3_bucket_name}"
IMAGE="${docker_image}"

# 1. 4GB Swap Space for stability on t3.small
echo "=== Step 1: Configuring 4GB Swap Space ==="
if [ ! -f /swapfile ]; then
  fallocate -l 4G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=4096 status=none
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
  free -h
fi

# 2. Install Docker and dependencies
echo "=== Step 2: Installing Docker and tools ==="
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y docker.io awscli curl jq
  systemctl enable --now docker
  usermod -aG docker ubuntu || true
elif command -v dnf >/dev/null 2>&1; then
  dnf update -y
  dnf install -y docker awscli curl jq
  systemctl enable --now docker
  usermod -aG docker ec2-user || true
fi

while ! docker info >/dev/null 2>&1; do
  echo "Waiting for Docker daemon..."
  sleep 2
done

# 3. Pull Twenty CRM Docker Image
echo "=== Step 3: Pulling Twenty CRM Image (${IMAGE}) ==="
docker pull "${IMAGE}"

# 4. Resolve Public IP via IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || echo "")
if [ -n "$TOKEN" ]; then
  PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 || echo "localhost")
else
  PUBLIC_IP="localhost"
fi

# 5. Run Twenty CRM Container configured with S3 storage
echo "=== Step 5: Starting Twenty CRM with S3 Storage Backend ==="
docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  -p 3000:2020 \
  -e NODE_PORT=2020 \
  -e SERVER_URL="http://${PUBLIC_IP}:2020" \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="${REGION}" \
  -e STORAGE_S3_NAME="${BUCKET_NAME}" \
  -e SIGN_IN_PREFILLED=true \
  -e APP_SECRET="twenty-s3-secret-task13-mohit-strongsecret" \
  "${IMAGE}"

echo "=== Step 6: Verifying container startup ==="
sleep 5
docker ps -a

echo "Twenty CRM EC2 bootstrap with S3 backend completed at $(date -u)!"