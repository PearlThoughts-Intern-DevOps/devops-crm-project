terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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

data "aws_security_group" "twenty_crm" {
  filter {
    name   = "group-name"
    values = ["twenty-crm-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_ecr_repository" "twenty_crm" {
  name = var.ecr_repository_name
}

data "aws_iam_instance_profile" "ec2_ecr" {
  name = "EC2ECRPullRole"
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    data.aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_ecr.name

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region         = var.aws_region
    ecr_repository_url = data.aws_ecr_repository.twenty_crm.repository_url
    image_tag          = var.image_tag
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    data.aws_ecr_repository.twenty_crm
  ]
}
