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

data "aws_iam_instance_profile" "ec2_s3" {
  name = var.iam_instance_profile_name
}

module "s3" {
  source = "./modules/s3"

  s3_bucket_name = var.s3_bucket_name
  project_name   = var.project_name
  environment    = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  environment     = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  subnet_id                 = data.aws_subnet.public.id
  key_name                  = var.key_name
  security_group_id         = data.aws_security_group.twenty_crm.id
  iam_instance_profile_name = data.aws_iam_instance_profile.ec2_s3.name

  user_data_file = "${path.module}/user_data.sh"

  aws_region     = var.aws_region
  s3_bucket_name = module.s3.bucket_name
  s3_bucket_arn  = module.s3.bucket_arn
  twenty_image   = var.twenty_image

  project_name = var.project_name
  environment  = var.environment
}
