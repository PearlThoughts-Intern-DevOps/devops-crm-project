resource "aws_security_group" "twenty_crm" {
  name        = "twenty-crm-task12-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "twenty-crm-task12-sg"
  }
}

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags = {
    Environment = "dev"
    Name        = "twenty-crm"
    Project     = "twenty-crm"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]

  user_data = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "twenty-crm-task12-ec2"
  }
}
