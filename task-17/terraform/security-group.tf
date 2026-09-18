resource "aws_security_group" "twenty" {
  name_prefix = "${local.name_prefix}-"
  description = "Task 17 access for SSH and Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.twenty.id
  description       = "SSH access from the administrator public IP"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "twenty" {
  security_group_id = aws_security_group.twenty.id
  description       = "Public access to Twenty CRM"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.application_port
  to_port           = var.application_port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.twenty.id
  description       = "Outbound access for packages and Docker images"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}