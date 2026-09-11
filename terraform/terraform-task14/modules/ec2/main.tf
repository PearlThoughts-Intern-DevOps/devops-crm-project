resource "aws_security_group" "twenty_crm" {
  name        = "launch-wizard-5"
  description = "Twenty CRM security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = [var.crm_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "twenty-crm-task14-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.twenty_crm.id]

  key_name = var.key_name

  iam_instance_profile = var.iam_instance_profile_name

  lifecycle {
    ignore_changes = [
      user_data,
      tags
    ]
  }

  tags = {
    Name        = "twenty-crm"
    Project     = var.project_name
    Environment = var.environment
  }
}