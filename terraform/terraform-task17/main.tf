terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.small"
  key_name      = "Ekta-task17-key"


  subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name = "twenty-crm-task-17"
  }
}