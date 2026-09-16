# ============================================================
# main.tf — Task 16
# Default VPC + EC2 only — no ALB needed
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Task        = "task-16"
    ManagedBy   = "terraform"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "defaultForAz"
    values = ["true"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow app port from internet + SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "App port from internet"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-sg"
  })
}

module "ec2" {
  source = "./modules/ec2"

  project_name         = var.project_name
  vpc_id               = data.aws_vpc.default.id
  subnet_id            = tolist(data.aws_subnets.default.ids)[0]
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  key_pair_name        = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile_name
  volume_size          = var.volume_size
  volume_type          = "gp3"
  extra_sg_ids         = [aws_security_group.ec2.id]
  ingress_rules        = []

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region     = var.aws_region
    app_port       = var.app_port
    app_name       = var.project_name
    twenty_image   = var.twenty_image
    encryption_key = var.encryption_key
    app_secret     = var.app_secret
    pg_password    = var.pg_password
    server_url     = "http://localhost:${var.app_port}"
  })

  tags = local.common_tags
}
