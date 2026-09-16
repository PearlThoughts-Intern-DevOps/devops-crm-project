resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  user_data_replace_on_change = true

  user_data = <<EOF_USERDATA
#!/bin/bash
set -eux

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker pull ${var.twenty_image}

docker rm -f twenty 2>/dev/null || true

docker run -d \
  --name twenty \
  --restart unless-stopped \
  --health-cmd='node -e "const fs=require(\"fs\");const x=fs.readFileSync(\"/proc/net/tcp6\",\"utf8\");process.exit(x.split(\"\\n\").some(l=>l.includes(\":07E4 \")&&l.trim().endsWith(\"0A\"))?0:1)"' \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=60s \
  -p ${var.app_port}:2020 \
  -e NODE_PORT=2020 \
  -v twenty-data:/app/docker-data \
  ${var.twenty_image}

echo "Twenty CRM deployment with restart policy and health check completed."
EOF_USERDATA

  tags = {
    Name        = var.instance_name
    Project     = var.project
    Task        = var.task
    Environment = var.environment
  }
}
