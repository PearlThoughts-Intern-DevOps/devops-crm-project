resource "aws_security_group" "alb" {
  name        = "twenty-crm-alb-sg"
  description = "Security group for Twenty CRM Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic from the internet"
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

  tags = {
    Name    = "twenty-crm-alb-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "ec2" {
  name        = "twenty-crm-ec2-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Twenty CRM traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "twenty-crm-ec2-sg"
    Project = var.project_name
  }
}

resource "aws_lb" "twenty_crm" {
  name               = "twenty-crm-t15-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]
  subnets         = var.alb_subnet_ids

  tags = {
    Name    = "twenty-crm-t15-alb"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "twenty_crm" {
  name        = "twenty-crm-t15-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

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
    Name    = "twenty-crm-t15-tg"
    Project = var.project_name
  }
}

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = module.ec2.instance_id
  port             = 3000
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