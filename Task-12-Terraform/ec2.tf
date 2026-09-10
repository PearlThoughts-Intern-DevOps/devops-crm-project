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
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  # Existing IAM instance profile supplied for this task.
  # No new IAM role is created by Terraform.
  iam_instance_profile = var.iam_instance_profile

  # Task requirement: 20 GiB root volume.
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # The previous EC2 had an 8 GiB root volume.
  # Create a correctly sized replacement instead of modifying
  # the existing volume, because ec2:ModifyVolume is unavailable.
  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
    #!/bin/bash

    set -u

    exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

    echo "===== Twenty CRM bootstrap started ====="

    # ------------------------------------------------------------
    # Create 2 GiB swap for t3.small
    # ------------------------------------------------------------

    echo "Checking swap configuration..."

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

    echo "Configuring swap behavior..."
    echo "vm.swappiness=10" > /etc/sysctl.d/99-twenty-crm.conf
    sysctl -p /etc/sysctl.d/99-twenty-crm.conf

    # ------------------------------------------------------------
    # Install required dependencies
    # ------------------------------------------------------------

    echo "Updating Ubuntu packages..."
    apt-get update -y

    echo "Installing Docker, AWS CLI and Git..."
    apt-get install -y docker.io awscli git

    echo "Enabling Docker..."
    systemctl enable docker
    systemctl start docker

    # ------------------------------------------------------------
    # Wait for Docker
    # ------------------------------------------------------------

    until docker info >/dev/null 2>&1; do
      echo "Waiting for Docker daemon..."
      sleep 5
    done

    echo "Docker daemon is ready."

    # ------------------------------------------------------------
    # Clone application repository
    # ------------------------------------------------------------

    APP_DIR="/opt/devops-crm-project"
    REPOSITORY_URL="https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
    REPOSITORY_BRANCH="Puneet-Task-10"

    echo "Cloning application repository..."

    rm -rf "$${APP_DIR}"

    git clone \
      --branch "$${REPOSITORY_BRANCH}" \
      --single-branch \
      "$${REPOSITORY_URL}" \
      "$${APP_DIR}"

    if [ ! -d "$${APP_DIR}" ]; then
      echo "Repository clone failed."
      exit 1
    fi

    echo "Repository cloned successfully."
    echo "Application directory: $${APP_DIR}"

    cd "$${APP_DIR}"

    echo "Current Git branch:"
    git branch --show-current

    # ------------------------------------------------------------
    # Configure ECR image
    # ------------------------------------------------------------

    ECR_REGISTRY="${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    ECR_REPOSITORY="${aws_ecr_repository.twenty_crm.name}"
    IMAGE_TAG="${var.docker_image_tag}"
    IMAGE_URI="$${ECR_REGISTRY}/$${ECR_REPOSITORY}:$${IMAGE_TAG}"

    echo "ECR Registry: $${ECR_REGISTRY}"
    echo "ECR Repository: $${ECR_REPOSITORY}"
    echo "Docker Image: $${IMAGE_URI}"

    # ------------------------------------------------------------
    # Authenticate with ECR and pull image
    #
    # The image may not exist when EC2 starts because the image
    # is pushed separately. Retry until it becomes available.
    # ------------------------------------------------------------

    while true; do
      echo "Authenticating with Amazon ECR..."

      if aws ecr get-login-password \
          --region "${var.aws_region}" | \
          docker login \
          --username AWS \
          --password-stdin "$${ECR_REGISTRY}"; then

        echo "ECR authentication successful."

        echo "Attempting to pull $${IMAGE_URI}..."

        if docker pull "$${IMAGE_URI}"; then
          echo "Successfully pulled Twenty CRM image."
          break
        fi

        echo "ECR image pull failed."
      else
        echo "ECR authentication failed."
      fi

      echo "Image is not available yet."
      echo "Retrying in 30 seconds..."
      sleep 30
    done

    # ------------------------------------------------------------
    # Start Twenty CRM
    # ------------------------------------------------------------

    echo "Removing previous Twenty CRM container if present..."
    docker rm -f twenty-crm 2>/dev/null || true

    echo "Starting Twenty CRM container..."

    docker run -d \
      --name twenty-crm \
      --restart unless-stopped \
      -p 2020:2020 \
      "$${IMAGE_URI}"

    # ------------------------------------------------------------
    # Verification
    # ------------------------------------------------------------

    echo "===== Container status ====="
    docker ps

    echo "===== Docker images ====="
    docker images

    echo "===== Repository status ====="
    cd "$${APP_DIR}"
    git status --short

    echo "===== Twenty CRM bootstrap completed ====="
  EOF

  tags = {
    Name        = var.instance_name
    Application = "Twenty CRM"
  }
}