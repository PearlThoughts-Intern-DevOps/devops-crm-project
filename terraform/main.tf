# -----------------------------------------------------------------------------
# Task 17 - Terraform provisions EC2 only. Ansible configures it.
# -----------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "SG for Twenty CRM EC2 (Task 17)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]
  key_name               = var.key_pair_name

  # No user_data - Ansible configures this instance
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}"
  })
}