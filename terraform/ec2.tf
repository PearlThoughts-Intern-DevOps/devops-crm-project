locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "twenty" {
  name_prefix = "${local.name_prefix}-"
  description = "Access rules for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.twenty.id
  description       = "SSH from the configured IPv4 network"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "application" {
  security_group_id = aws_security_group.twenty.id
  description       = "Twenty CRM from the configured IPv4 network"
  cidr_ipv4         = var.application_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = var.application_port
  to_port           = var.application_port
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.twenty.id
  description       = "Outbound HTTPS for image pulls and downloads"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-root"
    })
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}
