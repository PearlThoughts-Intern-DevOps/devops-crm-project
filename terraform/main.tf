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
}

# -----------------------------------------------------------------------------
# Module: ECR
# -----------------------------------------------------------------------------

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Module: S3
# -----------------------------------------------------------------------------

module "s3" {
  source = "./modules/s3"

  bucket_name_prefix = "${var.project_name}-${var.environment}-storage"
  force_destroy      = true

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Module: EC2
# -----------------------------------------------------------------------------

module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = data.aws_subnet.selected.id
  vpc_id               = data.aws_vpc.default.id
  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile
  root_volume_size     = var.root_volume_size
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  app_port             = var.app_port

  project_name = var.project_name
  environment  = var.environment

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region         = var.aws_region
    app_port           = var.app_port
    ecr_repository_url = module.ecr.repository_url
    s3_bucket_name     = module.s3.bucket_name
  })

  tags = local.common_tags
}