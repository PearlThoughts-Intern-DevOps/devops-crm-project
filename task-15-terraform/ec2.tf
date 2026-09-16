resource "aws_security_group" "alb" {
  name        = "twenty-crm-task15-purva-alb-sg"
  description = "Security group for Twenty CRM Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.alb_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-crm-task15-purva-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "twenty-crm-task15-purva-ec2-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = 2020
    to_port         = 2020
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
    Name = "twenty-crm-task15-purva-ec2-sg"
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name        = var.instance_name
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
