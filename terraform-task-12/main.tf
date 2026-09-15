# Get the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Create ECR repository
resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "twenty-crm"
    Task = "task-12"
  }
}

# Security Group for EC2
resource "aws_security_group" "twenty" {
  name        = "twenty-crm-task12-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Twenty CRM application
  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = [var.allowed_app_cidr]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "twenty-crm-task12-sg"
    Project = "devops-crm-project"
    Task    = "12"
  }
}

# EC2 instance
resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  iam_instance_profile        = "EC2ECRPullRole"
  associate_public_ip_address = true

  # Replace EC2 when user_data.sh changes
  user_data_replace_on_change = true

  lifecycle {
    create_before_destroy = true
  }

  # 20 GiB gp3 root volume
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # EC2 User Data
  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region         = var.aws_region
    ecr_repository_url = aws_ecr_repository.twenty.repository_url
  })

  tags = {
    Name = "jatin-crm-task12"
    Task = "task-12"
  }
}