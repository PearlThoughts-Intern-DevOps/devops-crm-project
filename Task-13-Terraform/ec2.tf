resource "aws_security_group" "twenty_crm" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
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
    Name        = "${var.instance_name}-sg"
    Application = "Twenty CRM"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash

    set -u

    exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

    echo "===== Twenty CRM + S3 bootstrap started ====="

    # ------------------------------------------------------------
    # 1. Configure 2 GiB swap
    # ------------------------------------------------------------

    if ! swapon --show | grep -q "/swapfile"; then
      echo "Creating 2 GiB swap file..."

      fallocate -l 2G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile

      if ! grep -q "^/swapfile " /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
      fi
    fi

    echo "===== Memory status ====="
    free -h

    # ------------------------------------------------------------
    # 2. Update packages
    # ------------------------------------------------------------

    echo "Updating Ubuntu packages..."

    apt-get update -y

    # ------------------------------------------------------------
    # 3. Install Docker and AWS CLI
    # ------------------------------------------------------------

    echo "Installing Docker and AWS CLI..."

    apt-get install -y docker.io awscli

    systemctl enable docker
    systemctl start docker

    until docker info >/dev/null 2>&1; do
      echo "Waiting for Docker daemon..."
      sleep 5
    done

    echo "Docker daemon is ready."

    # ------------------------------------------------------------
    # 4. Configure Twenty CRM S3 storage
    # ------------------------------------------------------------

    export AWS_REGION="${var.aws_region}"
    export S3_BUCKET="${aws_s3_bucket.twenty_crm_storage.bucket}"
    export TWENTY_IMAGE="${var.docker_image}"

    echo "AWS Region: $${AWS_REGION}"
    echo "S3 Bucket: $${S3_BUCKET}"
    echo "Twenty CRM Image: $${TWENTY_IMAGE}"

    # ------------------------------------------------------------
    # 5. Verify EC2 IAM role can access the S3 bucket
    # ------------------------------------------------------------

    echo "Testing S3 access..."

    until aws s3api head-bucket \
      --bucket "$${S3_BUCKET}" \
      --region "$${AWS_REGION}" >/dev/null 2>&1; do

      echo "Waiting for S3 access..."
      sleep 10
    done

    echo "S3 bucket access verified."

    # ------------------------------------------------------------
    # 6. Pull Twenty CRM Docker image
    # ------------------------------------------------------------

    echo "Pulling Twenty CRM Docker image..."

    until docker pull "$${TWENTY_IMAGE}"; do
      echo "Docker image pull failed."
      echo "Retrying in 30 seconds..."
      sleep 30
    done

    echo "Twenty CRM image pulled successfully."

    # ------------------------------------------------------------
    # 7. Remove previous container if present
    # ------------------------------------------------------------

    docker rm -f twenty-crm 2>/dev/null || true

    # ------------------------------------------------------------
    # 8. Start Twenty CRM with S3 configuration
    # ------------------------------------------------------------

    echo "Starting Twenty CRM..."

    docker run -d \
      --name twenty-crm \
      --restart unless-stopped \
      -p 2020:2020 \
      -e STORAGE_TYPE=S3 \
      -e STORAGE_S3_REGION="$${AWS_REGION}" \
      -e STORAGE_S3_NAME="$${S3_BUCKET}" \
      -e STORAGE_S3_ENDPOINT="https://s3.$${AWS_REGION}.amazonaws.com" \
      "$${TWENTY_IMAGE}"

    echo "===== Container status ====="
    docker ps

    echo "===== Twenty CRM + S3 bootstrap completed ====="
  EOF

  tags = {
    Name        = var.instance_name
    Application = "Twenty CRM"
    Storage     = "Amazon S3"
  }
}