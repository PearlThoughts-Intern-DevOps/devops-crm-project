# ---------------------------------------------------------------------------
# Networking — use the existing/default VPC. No aws_vpc resource is created.
# Uses aws_vpcs (plural) instead of aws_vpc (singular) because aws_vpc also
# reads DNS attributes via ec2:DescribeVpcAttribute, which this account's
# IAM users are not granted.
# ---------------------------------------------------------------------------

data "aws_vpcs" "default" {
  count = var.use_default_vpc ? 1 : 0

  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

locals {
  vpc_id = var.use_default_vpc ? data.aws_vpcs.default[0].ids[0] : var.existing_vpc_id
}

data "aws_subnets" "in_vpc" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  subnet_id = var.existing_subnet_id != "" ? var.existing_subnet_id : data.aws_subnets.in_vpc.ids[0]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# ---------------------------------------------------------------------------
# ECR
# ---------------------------------------------------------------------------

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.image_mutability
  force_delete         = true # allows `terraform destroy` to remove non-empty repo

  image_scanning_configuration {
    scan_on_push = true
  }
}


# ---------------------------------------------------------------------------
#
#
# If you have iam:CreateRole permission and want Terraform to manage its own
# role instead, swap back to the aws_iam_role / aws_iam_role_policy_attachment
# / aws_iam_instance_profile resources and reference
# aws_iam_instance_profile.ec2_ecr_profile.name on the instance instead.

# ---------------------------------------------------------------------------
# Security Group
# ---------------------------------------------------------------------------

resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and Twenty CRM app traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    description = "Twenty CRM app"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# ---------------------------------------------------------------------------
# EC2 Instance
# ---------------------------------------------------------------------------

resource "aws_instance" "twenty_crm" {
    ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  iam_instance_profile   = var.iam_instance_profile_name
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

    root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region    = var.aws_region
    ecr_repo_url  = aws_ecr_repository.twenty_crm.repository_url
    ecr_image_tag = var.ecr_image_tag
    app_port      = var.app_port
  })

  # Force replacement if user_data changes so the boot script re-runs
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-instance"
  }

  depends_on = [aws_ecr_repository.twenty_crm]
}