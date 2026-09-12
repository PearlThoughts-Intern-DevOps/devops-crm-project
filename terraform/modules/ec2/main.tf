resource "aws_security_group" "this" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.twenty_port
    to_port     = var.twenty_port
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

  tags = var.tags
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  iam_instance_profile = var.iam_instance_profile

  user_data = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = var.tags
}

