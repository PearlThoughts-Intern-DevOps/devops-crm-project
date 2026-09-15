# --------------------------------------------------
# Default VPC
# --------------------------------------------------

data "aws_vpc" "default" {
  id = var.vpc_id
}

# --------------------------------------------------
# ALB Security Group
# --------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# --------------------------------------------------
# EC2 Security Group
# --------------------------------------------------

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# --------------------------------------------------
# EC2 Instance
# --------------------------------------------------

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # New EC2 key pair
  key_name = "twenty-crm-task15-final-key"

  # Install Docker and deploy Twenty CRM
  user_data = file("${path.module}/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# --------------------------------------------------
# Application Load Balancer
# --------------------------------------------------

resource "aws_lb" "twenty_crm" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  # ALB requires subnets in at least two Availability Zones
  subnets = [
    var.subnet_id,
    var.subnet_id_2
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# --------------------------------------------------
# Target Group
# --------------------------------------------------

resource "aws_lb_target_group" "twenty_crm" {
  name     = "${var.project_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "3000"
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# --------------------------------------------------
# Register EC2 with Target Group
# --------------------------------------------------

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = aws_instance.twenty_crm.id
  port             = 3000
}

# --------------------------------------------------
# ALB Listener
# --------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty_crm.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_crm.arn
  }
}