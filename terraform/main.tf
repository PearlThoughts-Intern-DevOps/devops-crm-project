# provider "aws" {
#   region = "ap-south-1"
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# # resource "aws_instance" "app_server" {
# #   ami           = data.aws_ami.ubuntu.id
# #   instance_type = var.instance_type

# #   tags = { 
# #     Name = var.instance_name
# #   }
# # }


data "aws_vpc" "default" {
  default = true
}

# data "aws_subnet" "selected" {
#   id = var.subnet_id
# }

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.default_vpc.ids[0]
  #   key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
    Project     = var.project_name
  }
}