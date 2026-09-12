resource "aws_security_group" "this" {
  name        = var.security_group_name != null ? var.security_group_name : "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Twenty CRM Web UI and API (2020)"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name != null ? var.security_group_name : "${var.name}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
