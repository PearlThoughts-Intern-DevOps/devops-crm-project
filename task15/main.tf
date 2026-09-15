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

data "aws_subnet" "alb_subnet" {
  id = data.aws_subnets.default.ids[1]
}

resource "aws_security_group" "alb" {
  name        = "task15-alb-sg"
  description = "Security group for Task 15 ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "ec2" {
  name        = "task15-ec2-sg"
  description = "Security group for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "twenty" {
  name               = "task15-twenty-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    data.aws_subnet.selected.id,
    data.aws_subnet.alb_subnet.id
  ]

  tags = {
    Name = "task15-twenty-alb"
  }
}

resource "aws_lb_target_group" "twenty" {
  name        = "task15-twenty-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "3000"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "task15-twenty-tg"
  }
}

resource "aws_instance" "twenty" {
  ami                         = "ami-0b6d9d3d33ba97d99"
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  depends_on = [aws_lb.twenty]

  user_data = <<-USERDATA
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y docker.io curl openssl

    systemctl enable docker
    systemctl start docker

    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    mkdir -p /opt/twenty
    cd /opt/twenty

    curl -fsSL -o .env.example https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/.env.example
    curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/twentyhq/twenty/refs/heads/main/packages/twenty-docker/docker-compose.yml

    cp .env.example .env

    set_env() {
      KEY="$1"
      VALUE="$2"

      if grep -q "^$${KEY}=" .env; then
        sed -i "s|^$${KEY}=.*|$${KEY}=$${VALUE}|" .env
      else
        echo "$${KEY}=$${VALUE}" >> .env
      fi
    }

    set_env SERVER_URL "http://${aws_lb.twenty.dns_name}"
    set_env APP_SECRET "$(openssl rand -base64 32 | tr -d '\\n')"
    set_env ENCRYPTION_KEY "$(openssl rand -base64 32 | tr -d '\\n')"
    set_env FALLBACK_ENCRYPTION_KEY "$(openssl rand -base64 32 | tr -d '\\n')"
    set_env PG_DATABASE_PASSWORD "$(openssl rand -hex 32)"

    docker-compose up -d

    for i in $(seq 1 60); do
      if curl -fsS http://localhost:3000/ > /dev/null; then
        echo "Twenty CRM is healthy"
        exit 0
      fi
      sleep 5
    done

    docker-compose ps
    docker-compose logs --tail=100
    exit 1
  USERDATA

  tags = {
    Name = "task15-twenty-crm"
  }
}

resource "aws_lb_target_group_attachment" "twenty" {
  target_group_arn = aws_lb_target_group.twenty.arn
  target_id        = aws_instance.twenty.id
  port             = 3000
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty.arn
  }
}