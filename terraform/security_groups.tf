resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.owner}-${var.environment}-alb-sg"
  description = "Security group for the Twenty CRM Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from the internet"
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
    Name        = "${var.project_name}-${var.owner}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.owner}-${var.environment}-ec2-sg"
  description = "Security group for the Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Twenty CRM traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}-ec2-sg"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}
