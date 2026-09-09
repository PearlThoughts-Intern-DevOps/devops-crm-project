resource "aws_security_group" "twenty_crm" {
  name        = "twenty-crm-ec2-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = [var.crm_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-crm-ec2-sg"
  }
}


resource "aws_instance" "twenty_crm" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  iam_instance_profile = "EC2ECRPullRole"

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash

    set -e

    echo "Starting Twenty CRM EC2 setup..."

    # Install required dependencies
    apt-get update
    apt-get install -y docker.io awscli

    # Start and enable Docker
    systemctl enable docker
    systemctl start docker

    # ECR repository and image
    ECR_REPOSITORY="${aws_ecr_repository.twenty_crm.repository_url}"
    IMAGE="$ECR_REPOSITORY:latest"

    # Authenticate with Amazon ECR
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login \
      --username AWS \
      --password-stdin "$ECR_REPOSITORY"

    # Wait until the Twenty CRM image is available in ECR
    until docker pull "$IMAGE"; do
      echo "Twenty CRM image is not available yet."
      echo "Retrying image pull in 30 seconds..."
      sleep 30
    done

    echo "Twenty CRM image pulled successfully."

    # Remove an existing container if present
    docker rm -f twenty-crm 2>/dev/null || true

    # Start Twenty CRM
    docker run -d --name twenty-crm --restart unless-stopped -p 2020:2020 "$IMAGE"

    echo "Twenty CRM container started successfully."
  EOF

  tags = {
    Name = var.instance_name
  }

  depends_on = [
    aws_ecr_repository.twenty_crm
  ]
}
