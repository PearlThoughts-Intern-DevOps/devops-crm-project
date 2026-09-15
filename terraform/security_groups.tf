resource "aws_security_group" "alb" {
  name        = "twenty-crm-alb-sg-nagendra15"
  description = "Security group for Twenty CRM ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = var.alb_port
    to_port     = var.alb_port
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
    Name = "twenty-crm-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "twenty-crm-ec2-sg-nagendra15"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "twenty-crm-ec2-sg"
  }
}
