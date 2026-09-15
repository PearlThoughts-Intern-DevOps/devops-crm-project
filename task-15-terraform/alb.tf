resource "aws_lb" "twenty_crm" {
  name               = "twenty-crm-task15-purva-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    data.aws_subnets.default.ids[0],
    data.aws_subnets.default.ids[1]
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "twenty-crm-task15-purva-alb"
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name        = "twenty-crm-task15-purva-tg"
  port        = 2020
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name        = "twenty-crm-task15-purva-tg"
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "terraform"
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
