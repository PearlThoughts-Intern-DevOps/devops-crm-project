# ============================================================
# main.tf — Task 17
# Terraform scope: bare EC2 in default VPC
# All app configuration is handled by Ansible
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Task        = "task-17"
    ManagedBy   = "terraform"
  }
}

# ── Networking ─────────────────────────────────────────────

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

# ── Security Group ─────────────────────────────────────────

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow app port + SSH for ${var.project_name}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Application port from internet"
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

# ── EC2 Module ─────────────────────────────────────────────

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
  user_data            = ""
  tags                 = local.common_tags
}
