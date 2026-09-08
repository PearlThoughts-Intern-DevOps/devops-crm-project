resource "aws_security_group" "twenty_crm" {
  name        = "twenty-crm-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = local.default_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-crm-sg"
  }
}
