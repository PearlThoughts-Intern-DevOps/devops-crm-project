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

data "aws_subnet" "alb_second" {
  id = data.aws_subnets.default.ids[1]
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound HTTP from the internet to the ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow Twenty CRM traffic only from the ALB, plus SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH for troubleshooting"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.56.142.191/32"]
  }

  ingress {
    description     = "TEMP: log server port from ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Twenty CRM app port from ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound (docker pulls, package installs)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_instance" "twenty" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.root_volume_size
  }

  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -e

    if command -v apt-get >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose-v2
      systemctl enable docker
      systemctl start docker
    elif command -v dnf >/dev/null 2>&1; then
      dnf install -y docker
      systemctl enable docker
      systemctl start docker
    else
      echo "Unsupported operating system"
      exit 1
    fi

    mkdir -p /opt/twenty

    cat > /opt/twenty/docker-compose.yml <<'COMPOSE'
    services:
      postgres:
        image: postgres:16
        container_name: twenty-postgres
        restart: unless-stopped
        environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: twenty
        volumes:
          - postgres_data:/var/lib/postgresql/data
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U postgres -d twenty"]
          interval: 10s
          timeout: 5s
          retries: 15

      redis:
        image: redis:7-alpine
        container_name: twenty-redis
        restart: unless-stopped

      twenty:
        image: twentycrm/twenty:latest
        container_name: twenty
        restart: unless-stopped
        depends_on:
          postgres:
            condition: service_healthy
          redis:
            condition: service_started
        ports:
          - "3000:3000"
        environment:
          NODE_PORT: 3000
          SERVER_URL: http://localhost:3000
          PG_DATABASE_URL: postgres://postgres:postgres@postgres:5432/twenty
          REDIS_URL: redis://redis:6379
          STORAGE_TYPE: local
          ENABLE_DB_MIGRATIONS: "true"

    volumes:
      postgres_data:
    COMPOSE

    cd /opt/twenty
    docker compose up -d
  EOF_USERDATA

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}

resource "aws_lb" "twenty" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    "subnet-00df5fa2bef88e251",
    "subnet-01c70bb1575c44cb0",
    "subnet-05defbfbcbbf25e7d",
    "subnet-078d52bfe579c74f2",
    "subnet-0937ebb78ba697604",
    "subnet-0c6bba0e768ce1f0d"
  ]

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "twenty" {
  name     = "${var.project_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-tg"
    Project = var.project_name
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

  lifecycle {
    ignore_changes = [default_action]
  }
}
