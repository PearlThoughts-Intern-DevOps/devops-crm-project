# ============================================================
# main.tf — Task 15
# Default VPC + EC2 + ALB — cycle-free architecture
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Task        = "task-15"
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

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-alb-sg"
  })
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow app port from ALB only + SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "App port from ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
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

# ── ALB created BEFORE EC2 so we can pass ALB DNS to user_data ──
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = tolist(data.aws_subnets.default.ids)
  instance_id  = module.ec2.instance_id
  app_port     = var.app_port
  alb_sg_id    = aws_security_group.alb.id
  tags         = local.common_tags
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
    server_url     = "http://${module.alb.alb_dns_name}"
  })

  tags = local.common_tags
}
