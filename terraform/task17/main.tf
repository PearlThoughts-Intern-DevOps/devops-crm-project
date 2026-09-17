terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "task17" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "task17" {
  key_name   = "twenty-task17-key"
  public_key = tls_private_key.task17.public_key_openssh
}

resource "local_sensitive_file" "task17_private_key" {
  filename        = "${path.module}/twenty-task17-key.pem"
  content         = tls_private_key.task17.private_key_pem
  file_permission = "0600"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "twenty_prabhas" {
  name        = "prabhas-task17-sg"
  description = "Security group for Twenty CRM Task 17"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
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
    Name = "twenty-task17-sg"
  }
}

resource "aws_instance" "prabhas_instance" {
  ami                         = "ami-0b6d9d3d33ba97d99"
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty_prabhas.id]
  key_name                    = aws_key_pair.task17.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "prabhas-task17"
  }
}
