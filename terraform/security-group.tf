resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  description = "Allow public HTTP traffic to the Twenty CRM ALB"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Public HTTP access to the ALB"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_twenty" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward traffic from the ALB to Twenty CRM"
  referenced_security_group_id = aws_security_group.twenty.id
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}

resource "aws_security_group" "twenty" {
  name_prefix = "${local.name_prefix}-ec2-"
  description = "Access rules for the Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.twenty.id
  description       = "SSH from the configured administrator IPv4 network"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "application" {
  security_group_id            = aws_security_group.twenty.id
  description                  = "Twenty CRM access from the ALB only"
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.twenty.id
  description       = "Outbound HTTPS for packages and container images"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}