# A dedicated security group rather than the default one, because
# Ansible needs SSH (22) from the control machine and the app needs to
# be reachable on its port for verification. Both are scoped to a
# single CIDR (your own IP) rather than 0.0.0.0/0.
resource "aws_security_group" "twenty" {
  name        = "${var.project_name}-${var.owner}-${var.environment}-sg"
  description = "SSH for Ansible and HTTP access to Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.twenty.id
  description       = "SSH for the Ansible control machine"
  cidr_ipv4         = var.ssh_ingress_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.twenty.id
  description       = "Twenty CRM application port"
  cidr_ipv4         = var.ssh_ingress_cidr
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.twenty.id
  description       = "Allow all outbound (package installs, image pulls)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
