# -----------------------------------------------------------------------------
# Data Sources: Default VPC and Default Subnets
# -----------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# -----------------------------------------------------------------------------
# EC2 SSH Key Pair (Note: Key pair tags omitted per IAM policy restrictions)
# -----------------------------------------------------------------------------
resource "aws_key_pair" "task17_key" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "twenty_crm_sg" {
  name_prefix = "${var.project_name}-sg-"
  description = "Security group for Twenty CRM EC2 instance (Task 17)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM Web application"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Task        = "Task-17"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance for Twenty CRM
# -----------------------------------------------------------------------------
resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  key_name                    = aws_key_pair.task17_key.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name        = "${var.project_name}-root-volume"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = var.project_name
    Environment = var.environment
    Project     = var.project_name
    Task        = "Task-17"
    ManagedBy   = "Terraform"
  }
}
