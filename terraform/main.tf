# --- Data Sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group ---
resource "aws_security_group" "twenty_crm_sg" {
  name        = "twenty-crm-s3-sg"
  description = "Allow SSH and Twenty CRM traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Amazon S3 Bucket ---
resource "aws_s3_bucket" "twenty_crm" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "Twenty-CRM-S3-Task13"
    Environment = "Internship"
    ManagedBy   = "Terraform"
  }
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

resource "aws_s3_bucket_public_access_block" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- EC2 Instance ---
resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  key_name               = "twenty-key"
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.name

  user_data = <<-USERDATA
#!/bin/bash
set -e
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /home/ec2-user/twenty-crm
cd /home/ec2-user/twenty-crm

cat > docker-compose.yml << 'COMPOSEOF'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: default
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:alpine

  server:
    image: twentycrm/twenty:latest
    ports:
      - "2020:3000"
    environment:
      SERVER_URL: http://localhost:2020
      FRONTEND_URL: http://localhost:2020
      PG_DATABASE_URL: postgres://postgres:postgres@postgres:5432/default
      REDIS_URL: redis://redis:6379
      STORAGE_S3_REGION: ${var.aws_region}
      STORAGE_S3_NAME: ${aws_s3_bucket.twenty_crm.bucket}
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

volumes:
  pgdata:
COMPOSEOF

docker-compose up -d
USERDATA

  tags = {
    Name = "Twenty-CRM"
  }
}




resource "aws_iam_role" "ec2_s3_access_role" {
  name = "EC2S3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "EC2S3AccessRole"
  role = aws_iam_role.ec2_s3_access_role.name
}
