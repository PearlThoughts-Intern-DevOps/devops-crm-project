# =========================
# SECURITY GROUP
# =========================

resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.project_name}-crm-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP - keep only if you need direct HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS - keep only if you need direct HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Twenty CRM - ALB will be allowed separately
  # Do NOT expose port 2020 publicly.

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}


# =========================
# EC2 INSTANCE
# =========================

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = "t3.small"

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.twenty_crm_sg.id
  ]

  key_name = var.key_name

  # 20 GB root EBS volume
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash

    apt-get update -y

    apt-get install -y docker.io awscli

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    mkdir -p /home/ubuntu/twenty-crm

    chown -R ubuntu:ubuntu /home/ubuntu/twenty-crm
  EOF

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
