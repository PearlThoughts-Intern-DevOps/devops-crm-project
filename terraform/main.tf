# ============================================================
# Existing Default VPC
# ============================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# ============================================================
# Specific Amazon Linux 2023 AMI
# ============================================================

data "aws_ami" "amazon_linux" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-081b0a6eac00b4f53"]
  }
}

# ============================================================
# Security Group
# ============================================================

data "aws_security_group" "twenty_crm" {
  id = "sg-0c7378db08ee3b97f"
}

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "twenty-crm"
    Environment = "dev"
    Project     = "twenty-crm"
  }
}

# ============================================================
# Existing IAM Instance Profile for EC2 ECR Pull
# ============================================================

data "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "EC2ECRPullRole"
}

# ============================================================
# EC2 Instance
# ============================================================

resource "aws_instance" "twenty_crm" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  user_data_replace_on_change = true

  vpc_security_group_ids = [
    data.aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_ecr_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_repository_url = aws_ecr_repository.twenty_crm.repository_url
  })

  tags = {
    Name        = "twenty-crm-server"
    Environment = "dev"
    Project     = "twenty-crm"
  }
}
