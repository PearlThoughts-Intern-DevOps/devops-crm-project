resource "aws_lb" "twenty" {
  name               = "${var.project_name}-${var.owner}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = slice(data.aws_subnets.default.ids, 0, 2)

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_lb_target_group" "twenty" {
  name     = "${var.project_name}-${var.owner}-${var.environment}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "3000"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_lb_target_group_attachment" "twenty" {
  target_group_arn = aws_lb_target_group.twenty.arn
  target_id        = aws_instance.twenty.id
  port             = 3000
}

resource "aws_lb_listener" "twenty" {
  load_balancer_arn = aws_lb.twenty.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty.arn
  }
}
