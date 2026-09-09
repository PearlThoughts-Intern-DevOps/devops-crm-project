# ---------------------------------------------------------
# ECR Repository
# ---------------------------------------------------------

resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Application = "Twenty CRM"
    ManagedBy   = "Terraform"
  }
}


# ---------------------------------------------------------
# EC2 Instance
# ---------------------------------------------------------

resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.selected.id

  # Existing EC2 key pair
  key_name = var.key_name

  # Existing IAM instance profile with ECR pull permissions
  iam_instance_profile = data.aws_iam_instance_profile.ecr_pull.name

  # Public IP required for SSH and accessing Twenty
  associate_public_ip_address = true

  # Root disk
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # -------------------------------------------------------
  # EC2 User Data
  # -------------------------------------------------------

  user_data = <<-EOF
    #!/bin/bash

    set -e

    # Update system packages
    dnf update -y

    # Install Docker and AWS CLI
    dnf install -y docker awscli

    # Start Docker
    systemctl enable docker
    systemctl start docker

    # Allow ec2-user to use Docker
    usermod -aG docker ec2-user

    # AWS/ECR configuration
    AWS_REGION="${var.aws_region}"
    ECR_REPOSITORY="${aws_ecr_repository.twenty.repository_url}"
    IMAGE="$ECR_REPOSITORY:latest"

    # Authenticate with Amazon ECR
    aws ecr get-login-password --region "$AWS_REGION" | \
      docker login \
      --username AWS \
      --password-stdin "$ECR_REPOSITORY"

    # -------------------------------------------------------
    # Wait for Twenty image to become available in ECR
    # -------------------------------------------------------

    MAX_RETRIES=30
    RETRY_INTERVAL=30
    RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do

      echo "Attempting to pull Twenty CRM image..."

      if docker pull "$IMAGE"; then
        echo "Twenty CRM image pulled successfully."
        break
      fi

      RETRY_COUNT=$((RETRY_COUNT + 1))

      echo "Image not available yet."
      echo "Retry $RETRY_COUNT/$MAX_RETRIES"

      sleep $RETRY_INTERVAL
    done

    # -------------------------------------------------------
    # Verify image exists locally
    # -------------------------------------------------------

    if ! docker image inspect "$IMAGE" > /dev/null 2>&1; then
      echo "Failed to pull Twenty CRM image."
      exit 1
    fi

    # -------------------------------------------------------
    # Run Twenty CRM
    # -------------------------------------------------------

    docker run -d \
      --name twenty \
      --restart unless-stopped \
      -p ${var.app_port}:3000 \
      "$IMAGE"

    echo "Twenty CRM container started successfully."

  EOF

  user_data_replace_on_change = true

  tags = {
    Name        = var.ec2_name
    Application = "Twenty CRM"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_ecr_repository.twenty
  ]
}