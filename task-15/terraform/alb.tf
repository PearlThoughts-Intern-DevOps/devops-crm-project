# ---------------------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------------------
resource "aws_lb" "twenty_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.alb_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ---------------------------------------------------------------------------
# Target Group for Twenty CRM (port 3000) with an HTTP health check
# ---------------------------------------------------------------------------
resource "aws_lb_target_group" "twenty_tg" {
  name     = "${var.project_name}-tg"
  port     = var.twenty_app_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Register the EC2 instance with the target group
resource "aws_lb_target_group_attachment" "twenty_attach" {
  target_group_arn = aws_lb_target_group.twenty_tg.arn
  target_id        = aws_instance.twenty_crm.id
  port             = var.twenty_app_port
}

# ---------------------------------------------------------------------------
# ALB Listener on port 80, forwarding to the target group
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "twenty_listener" {
  load_balancer_arn = aws_lb.twenty_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_tg.arn
  }
}


resource "aws_lb_target_group" "log_tg" {
  name        = "twenty-crm-task15-log-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id   # match your actual vpc data source name
  target_type = "instance"

  health_check {
    path                = "/"
    matcher             = "200,301,302,404"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "log_tg_attach" {
  target_group_arn = aws_lb_target_group.log_tg.arn
  target_id        = aws_instance.twenty_crm.id
  port             = 8080
}

resource "aws_lb_listener" "log_listener" {
  load_balancer_arn = aws_lb.twenty_alb.arn   # match your actual ALB resource name
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.log_tg.arn
  }
}