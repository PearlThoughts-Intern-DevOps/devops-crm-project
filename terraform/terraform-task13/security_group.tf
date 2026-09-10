resource "aws_security_group" "twenty_crm" {
  name        = "launch-wizard-5"
  description = "launch-wizard-5 created 2026-09-10T10:16:04.200Z"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.171.55.112/32"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "twenty-crm-task13-sg"
    Project = "twenty-crm"
  }
}