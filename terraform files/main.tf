terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Default VPC + default subnet ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick the first available default subnet
data "aws_subnet" "chosen" {
  id = tolist(data.aws_subnets.default.ids)[0]
}

# --- Security group: SSH + Twenty CRM app port ---
resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.name_prefix}-twenty-crm-task17-sg"
  description = "Allow SSH and Twenty CRM app port"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-twenty-crm-task17-sg"
  }
}

# --- EC2 instance ---
resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.chosen.id
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name_prefix}-twenty-crm-task17"
  }
}
