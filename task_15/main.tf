terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "public" {
  id = var.subnet_id
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP traffic to Twenty CRM ALB"
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

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow Twenty CRM traffic from ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Twenty CRM traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    description = "Temporary SSH access for Task 15 verification"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.185.39.17/32"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.public.id
  key_name      = var.key_name

  security_group_id = aws_security_group.ec2.id

  user_data_file = "${path.module}/user_data.sh"

  twenty_image = var.twenty_image

  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = data.aws_vpc.default.id

  alb_subnet_ids = data.aws_subnets.default_vpc.ids

  alb_security_group_id = aws_security_group.alb.id

  ec2_instance_id = module.ec2.instance_id
}
