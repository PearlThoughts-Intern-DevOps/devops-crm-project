
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
  security_group_id = aws_security_group.twenty.id
  description       = "Allow public access to Twenty CRM"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.application_port
  to_port           = var.application_port
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.twenty.id
  description       = "Allow outbound traffic for packages and container images"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}