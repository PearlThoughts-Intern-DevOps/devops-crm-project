# -----------------------------------------------------------------------------
# 1. VPC Configuration (Existing / Default AWS VPC)
# -----------------------------------------------------------------------------
# References the existing default VPC if no custom vpc_id is passed
data "aws_vpc" "default" {
  default = var.vpc_id == null ? true : false
  id      = var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------------------------------------------------------
# 2. Security Group for Twenty CRM EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.environment}-twenty-crm-sg"
  description = "Security group for Twenty CRM application and management"
  vpc_id      = data.aws_vpc.default.id

  # SSH access for server administration
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Standard HTTP access
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Twenty CRM default web service port
  ingress {
    description = "Twenty CRM application port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound access for container pulls, packages, and updates
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-twenty-crm-sg"
  }
}

# -----------------------------------------------------------------------------
# 3. EC2 Instance for Twenty CRM Application
# -----------------------------------------------------------------------------
resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id != null ? var.subnet_id : element(tolist(data.aws_subnets.default.ids), 0)
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }
}

# -----------------------------------------------------------------------------
# 4. Amazon ECR Repository for Twenty CRM Docker Images
# -----------------------------------------------------------------------------
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}