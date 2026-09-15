data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM Backend"
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Project     = var.project_name
    Environment = var.environment
    Task        = "14"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  iam_instance_profile = var.iam_instance_profile

  user_data = <<-USERDATA
    #!/bin/bash
    set -eux
    exec >> /var/log/twenty-crm-user-data.log 2>&1

    apt-get update -y

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      unzip \
      awscli \
      docker.io \
      docker-compose-v2 \
      openssl

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    mkdir -p /opt/twenty-crm
    cd /opt/twenty-crm

    AWS_REGION="${var.aws_region}"
    S3_BUCKET="${var.s3_bucket_name}"

    IMDS_TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    PUBLIC_IP=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $${IMDS_TOKEN}" \
      http://169.254.169.254/latest/meta-data/public-ipv4)

    SERVER_URL="http://$${PUBLIC_IP}:${var.backend_port}"

    ENCRYPTION_KEY=$(openssl rand -hex 32)

    cat > /opt/twenty-crm/docker-compose.yml <<COMPOSE
    services:

      twenty-server:
        image: twentycrm/twenty:latest
        container_name: twenty-server

        ports:
          - "${var.backend_port}:3000"

        environment:
          NODE_PORT: "3000"
          SERVER_URL: "$${SERVER_URL}"
          ENCRYPTION_KEY: "$${ENCRYPTION_KEY}"

          PG_DATABASE_URL: "postgres://postgres:postgres@postgres:5432/twenty"
          REDIS_URL: "redis://redis:6379"

          STORAGE_TYPE: "S_3"
          STORAGE_S3_REGION: "$${AWS_REGION}"
          STORAGE_S3_NAME: "$${S3_BUCKET}"

          NODE_ENV: "production"

        restart: unless-stopped

      postgres:
        image: postgres:16
        container_name: twenty-postgres

        environment:
          POSTGRES_DB: twenty
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres

        volumes:
          - twenty-postgres-data:/var/lib/postgresql/data

        restart: unless-stopped

      redis:
        image: redis:7
        container_name: twenty-redis

        command: ["redis-server", "--maxmemory-policy", "noeviction"]

        restart: unless-stopped

    volumes:
      twenty-postgres-data:
    COMPOSE

    docker compose -f /opt/twenty-crm/docker-compose.yml up -d
  USERDATA

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    Task        = "14"
  }
}
