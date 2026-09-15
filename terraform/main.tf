terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

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

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "NM_015"
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  user_data = <<-USERDATA
    #!/bin/bash

    apt-get update -y
    apt-get install -y docker.io

    systemctl enable docker
    systemctl start docker

    docker pull twentycrm/twenty-app-dev:latest

    docker run -d \
      --name twenty \
      --restart unless-stopped \
      -p 2020:2020 \
      twentycrm/twenty-app-dev:latest
  USERDATA

  tags = {
    Name = "twenty-crm"
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name     = "twenty-crm-tg-nagendra15"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = tostring(var.app_port)
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "twenty-crm-tg"
  }
}

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = aws_instance.twenty_crm.id
  port             = var.app_port
}

resource "aws_lb" "twenty_crm" {
  name               = "twenty-crm-alb-nagendra15"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "twenty-crm-alb"
  }
}

resource "aws_lb_listener" "twenty_crm" {
  load_balancer_arn = aws_lb.twenty_crm.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_crm.arn
  }
}
