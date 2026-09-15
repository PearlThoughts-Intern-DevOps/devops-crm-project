# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

# -----------------------------------------------------------------------------
# Local values
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  # First two subnets from the default VPC (must span 2+ AZs for ALB)
  alb_subnet_ids = slice(data.aws_subnets.default.ids, 0, 2)
}

# -----------------------------------------------------------------------------
# Security Group for the ALB
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for the Twenty CRM Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
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

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Module: EC2
# -----------------------------------------------------------------------------

module "ec2" {
  source = "./modules/ec2"

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = data.aws_subnet.selected.id
  vpc_id           = data.aws_vpc.default.id
  key_name         = var.key_pair_name
  root_volume_size = var.root_volume_size
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_port         = var.app_port

  project_name = var.project_name
  environment  = var.environment

  alb_security_group_id = aws_security_group.alb.id

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region = var.aws_region
    app_port   = var.app_port
  })

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Module: ALB
# -----------------------------------------------------------------------------

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = data.aws_vpc.default.id
  security_group_id = aws_security_group.alb.id
  public_subnet_ids = local.alb_subnet_ids
  app_port          = var.app_port

  instance_id = module.ec2.instance_id

  tags = local.common_tags
}