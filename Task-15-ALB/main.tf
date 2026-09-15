data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

data "aws_subnet" "selected_2" {
  id = data.aws_subnets.default.ids[1]
}

resource "aws_security_group" "alb" {
  name        = "${var.instance_name}-alb-sg"
  description = "Security group for Twenty CRM Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
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
    Name        = "${var.instance_name}-alb-sg"
    Application = "Twenty CRM"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.instance_name}-ec2-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Twenty CRM traffic from ALB"
    from_port       = 2020
    to_port         = 2020
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-ec2-sg"
    Application = "Twenty CRM"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash

    set -u

    exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

    echo "===== Twenty CRM bootstrap started ====="

    # Configure swap
    if ! swapon --show | grep -q "/swapfile"; then
      fallocate -l 2G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile

      if ! grep -q "^/swapfile " /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
      fi
    fi

    free -h

    # Update packages
    apt-get update -y

    # Install Docker
    apt-get install -y docker.io

    systemctl enable docker
    systemctl start docker

    until docker info >/dev/null 2>&1; do
      echo "Waiting for Docker daemon..."
      sleep 5
    done

    echo "Docker daemon is ready."

    # Pull Twenty CRM image
    until docker pull "${var.docker_image}"; do
      echo "Docker image pull failed. Retrying in 30 seconds..."
      sleep 30
    done

    # Remove existing container if present
    docker rm -f twenty-crm 2>/dev/null || true

    # Start Twenty CRM
    docker run -d \
      --name twenty-crm \
      --restart unless-stopped \
      -p 2020:2020 \
      "${var.docker_image}"

    echo "===== Container status ====="
    docker ps

    echo "===== Twenty CRM bootstrap completed ====="
  EOF

  tags = {
    Name        = var.instance_name
    Application = "Twenty CRM"
  }
}

resource "aws_lb" "twenty_crm" {
  name               = "twenty-crm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    data.aws_subnet.selected.id,
    data.aws_subnet.selected_2.id
  ]

  tags = {
    Name        = "twenty-crm-alb"
    Application = "Twenty CRM"
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name     = "twenty-crm-tg"
  port     = 2020
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "2020"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = {
    Name        = "twenty-crm-tg"
    Application = "Twenty CRM"
  }
}

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = aws_instance.twenty_crm.id
  port             = 2020
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty_crm.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_crm.arn
  }
}
