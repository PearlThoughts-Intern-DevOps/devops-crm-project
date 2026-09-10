# ------------------------------------------------------------
# Data sources
# ------------------------------------------------------------

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "existing" {
  id = var.subnet_id
}

# ------------------------------------------------------------
# Security Group
# ------------------------------------------------------------

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and Twenty CRM app traffic"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.36.235.62/32"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 3000
    to_port     = 3000
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
    Name        = "${var.project_name}-sg"
    Project     = var.project_name
    Environment = "task-13"
  }
}

# ------------------------------------------------------------
# S3 Bucket
# ------------------------------------------------------------

resource "aws_s3_bucket" "twenty_crm" {
  bucket_prefix = "${var.project_name}-"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-storage"
    Project     = var.project_name
    Environment = "task-13"
    Purpose     = "Twenty CRM storage"
  }
}

resource "aws_s3_bucket_public_access_block" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------
# EC2 Instance
# ------------------------------------------------------------

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.existing.id
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  # Existing IAM instance profile provided by the assignment.
  iam_instance_profile = var.instance_profile_name

  # SSH key pair
  key_name = "twenty-crm-task13-new"

  # ----------------------------------------------------------
  # EC2 startup script
  # ----------------------------------------------------------

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Install required packages
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2 curl openssl

    # Start Docker
    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    # Create Twenty CRM directory
    mkdir -p /opt/twenty
    cd /opt/twenty

    # Get EC2 public IP using IMDSv2
    TOKEN=$(curl -sS -X PUT \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
      http://169.254.169.254/latest/api/token)

    PUBLIC_IP=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $${TOKEN}" \
      http://169.254.169.254/latest/meta-data/public-ipv4)

    # Generate secrets
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    PG_DATABASE_PASSWORD=$(openssl rand -hex 32)
    APP_SECRET=$(openssl rand -base64 32)

    # Create Twenty CRM environment file
    cat > /opt/twenty/.env <<EOT
    TAG=latest

    SERVER_URL=http://$${PUBLIC_IP}:3000

    PG_DATABASE_USER=postgres
    PG_DATABASE_PASSWORD=$${PG_DATABASE_PASSWORD}
    PG_DATABASE_HOST=db
    PG_DATABASE_PORT=5432
    PG_DATABASE_NAME=default

    DISABLE_DB_MIGRATIONS=false
    DISABLE_CRON_JOBS_REGISTRATION=false

    REDIS_URL=redis://redis:6379

    STORAGE_TYPE=S_3
    STORAGE_S3_REGION=us-east-1
    STORAGE_S3_NAME=${aws_s3_bucket.twenty_crm.id}
    STORAGE_S3_ENDPOINT=

    ENCRYPTION_KEY=$${ENCRYPTION_KEY}
    APP_SECRET=$${APP_SECRET}
    EOT

    # Create Docker Compose configuration
    cat > /opt/twenty/docker-compose.yml <<'EOT'
    name: twenty

    services:

      server:
        image: twentycrm/twenty:$${TAG:-latest}

        volumes:
          - server-local-data:/app/packages/twenty-server/.local-storage

        ports:
          - "3000:3000"

        environment:
          NODE_PORT: 3000

          PG_DATABASE_URL: postgres://$${PG_DATABASE_USER:-postgres}:$${PG_DATABASE_PASSWORD:-postgres}@$${PG_DATABASE_HOST:-db}:$${PG_DATABASE_PORT:-5432}/$${PG_DATABASE_NAME:-default}

          SERVER_URL: $${SERVER_URL}

          REDIS_URL: $${REDIS_URL:-redis://redis:6379}

          DISABLE_DB_MIGRATIONS: $${DISABLE_DB_MIGRATIONS}

          DISABLE_CRON_JOBS_REGISTRATION: $${DISABLE_CRON_JOBS_REGISTRATION}

          STORAGE_TYPE: $${STORAGE_TYPE}

          STORAGE_S3_REGION: $${STORAGE_S3_REGION}

          STORAGE_S3_NAME: $${STORAGE_S3_NAME}

          STORAGE_S3_ENDPOINT: $${STORAGE_S3_ENDPOINT}

          ENCRYPTION_KEY: $${ENCRYPTION_KEY}

          APP_SECRET: $${APP_SECRET}

        depends_on:
          db:
            condition: service_healthy

          redis:
            condition: service_healthy

        healthcheck:
          test: ["CMD-SHELL", "curl --fail http://localhost:3000/healthz || exit 1"]
          interval: 5s
          timeout: 5s
          retries: 20

        restart: always


      worker:
        image: twentycrm/twenty:$${TAG:-latest}

        volumes:
          - server-local-data:/app/packages/twenty-server/.local-storage

        command: ["yarn", "worker:prod"]

        environment:
          PG_DATABASE_URL: postgres://$${PG_DATABASE_USER:-postgres}:$${PG_DATABASE_PASSWORD:-postgres}@$${PG_DATABASE_HOST:-db}:$${PG_DATABASE_PORT:-5432}/$${PG_DATABASE_NAME:-default}

          SERVER_URL: $${SERVER_URL}

          REDIS_URL: $${REDIS_URL:-redis://redis:6379}

          DISABLE_DB_MIGRATIONS: "true"

          DISABLE_CRON_JOBS_REGISTRATION: "true"

          STORAGE_TYPE: $${STORAGE_TYPE}

          STORAGE_S3_REGION: $${STORAGE_S3_REGION}

          STORAGE_S3_NAME: $${STORAGE_S3_NAME}

          STORAGE_S3_ENDPOINT: $${STORAGE_S3_ENDPOINT}

          ENCRYPTION_KEY: $${ENCRYPTION_KEY}

          APP_SECRET: $${APP_SECRET}

        depends_on:
          db:
            condition: service_healthy

          server:
            condition: service_healthy

        restart: always


      db:
        image: postgres:16

        volumes:
          - db-data:/var/lib/postgresql/data

        environment:
          POSTGRES_DB: $${PG_DATABASE_NAME:-default}
          POSTGRES_PASSWORD: $${PG_DATABASE_PASSWORD:-postgres}
          POSTGRES_USER: $${PG_DATABASE_USER:-postgres}

        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U $${PG_DATABASE_USER:-postgres} -h localhost -d postgres"]
          interval: 5s
          timeout: 5s
          retries: 10

        restart: always


      redis:
        image: redis

        restart: always

        command: ["--maxmemory-policy", "noeviction"]

        healthcheck:
          test: ["CMD", "redis-cli", "ping"]
          interval: 5s
          timeout: 5s
          retries: 10


    volumes:
      db-data:

      server-local-data:
    EOT

    # Start Twenty CRM
    cd /opt/twenty

    docker compose pull
    docker compose up -d

    # Display container status
    docker compose ps
  EOF

  tags = {
    Name        = "${var.project_name}-ec2"
    Project     = var.project_name
    Environment = "task-13"
    Application = "Twenty CRM"
  }
}