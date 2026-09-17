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
  region = "us-east-1"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "twenty" {
  name        = "twenty-task17-sg"
  description = "Security group for Twenty CRM Task 17"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Twenty CRM
  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-task17-sg"
  }
}

# EC2 Instance
resource "aws_instance" "twenty" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.small"

  # Default VPC subnet
  subnet_id = data.aws_subnets.default.ids[0]

  # Key pair created for Task 17
  key_name = "ambu-task17-key"

  # Security group
  vpc_security_group_ids = [
    aws_security_group.twenty.id
  ]

  # Assign public IP
  associate_public_ip_address = true

  tags = {
    Name = "twenty-task17"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.twenty.id
}

output "public_ip" {
  value = aws_instance.twenty.public_ip
}

output "public_dns" {
  value = aws_instance.twenty.public_dns
}