data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# =========================================================
# Security Group for ALB
# =========================================================

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Twenty CRM ALB"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP traffic from the internet
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}


# =========================================================
# Security Group for EC2
# =========================================================

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  # Allow Twenty CRM traffic ONLY from the ALB
  ingress {
    description     = "Allow Twenty CRM traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}


# =========================================================
# EC2 Instance
# =========================================================

resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name

  # First subnet from the default VPC
  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  # Install Docker and Twenty CRM
  user_data = file("${path.module}/user_data.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "Twenty-CRM"
  }
}


# =========================================================
# ALB Target Group
# =========================================================

resource "aws_lb_target_group" "twenty" {
  name        = "${var.project_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = data.aws_vpc.default.id

  # Twenty CRM health check
  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "3000"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-target-group"
  }
}


# =========================================================
# Register EC2 Instance with Target Group
# =========================================================

resource "aws_lb_target_group_attachment" "twenty" {
  target_group_arn = aws_lb_target_group.twenty.arn
  target_id        = aws_instance.twenty.id
  port             = 3000
}


# =========================================================
# Application Load Balancer
# =========================================================

resource "aws_lb" "twenty" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  # ALB requires subnets in at least two Availability Zones
  subnets = [
    data.aws_subnets.default.ids[0],
    data.aws_subnets.default.ids[1]
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}


# =========================================================
# ALB Listener
# =========================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty.arn
  }
}
