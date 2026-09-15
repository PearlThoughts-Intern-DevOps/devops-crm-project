resource "aws_lb" "twenty_crm" {
  name               = "twenty-crm-task15-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    "subnet-078d52bfe579c74f2",
    "subnet-01c70bb1575c44cb0",
    "subnet-0937ebb78ba697604",
    "subnet-05defbfbcbbf25e7d",
    "subnet-0c6bba0e768ce1f0d",
    "subnet-00df5fa2bef88e251"
  ]

  tags = {
    Name    = "twenty-crm-task15-alb"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name     = "twenty-crm-task15-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

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
    Name    = "twenty-crm-task15-tg"
    Project = var.project_name
  }
}

resource "aws_lb_listener" "twenty_crm" {
  load_balancer_arn = aws_lb.twenty_crm.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_crm.arn
  }
}