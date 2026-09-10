# -------------------------------------------------------------------
# Existing/default VPC
# -------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# Select an existing default subnet from the default VPC.
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

# -------------------------------------------------------------------
# IAM role and instance profile for EC2
# -------------------------------------------------------------------

resource "aws_iam_role" "ec2_ecr_pull" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.instance_name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_pull.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_ecr_pull" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_ecr_pull.name

  tags = {
    Name = "${var.instance_name}-profile"
  }
}

# -------------------------------------------------------------------
# Security group for Twenty CRM
# -------------------------------------------------------------------

resource "aws_security_group" "twenty_crm" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Twenty CRM Task 12"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.twenty_port
    to_port     = var.twenty_port
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
    Name = "${var.instance_name}-sg"
  }
}

# -------------------------------------------------------------------
# Amazon ECR repository
# -------------------------------------------------------------------

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repository_name
  }
}

# -------------------------------------------------------------------
# EC2 instance
# -------------------------------------------------------------------

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ecr_pull.name

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region       = var.aws_region
    ecr_repository   = aws_ecr_repository.twenty_crm.repository_url
    image_tag        = var.image_tag
    container_name   = var.container_name
    host_port        = var.twenty_port
    container_port   = var.twenty_port
    image_wait_secs  = var.image_wait_secs
    max_pull_retries = var.max_pull_retries
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}

