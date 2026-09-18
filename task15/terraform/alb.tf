resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Twenty CRM Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from Internet"
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
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    Task        = "15"
  }
}

resource "aws_lb" "twenty_crm" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
    Task        = "15"
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = var.backend_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Project     = var.project_name
    Environment = var.environment
    Task        = "15"
  }
}

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = module.ec2.instance_id
  port             = var.backend_port
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
