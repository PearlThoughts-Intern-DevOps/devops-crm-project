# -----------------------------------------------------------------------------
# ALB Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ${var.name} Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Application Load Balancer (ALB)
# -----------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb"
    }
  )
}

# -----------------------------------------------------------------------------
# Target Group
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# ALB Listener
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-listener-80"
    }
  )
}
