# =========================
# VPC MODULE
# =========================

module "vpc" {
  source = "./modules/vpc"
}

# =========================
# EXISTING IAM INSTANCE PROFILE
# =========================

data "aws_iam_instance_profile" "ec2_s3_access" {
  name = "EC2S3AccessRole"
}


# =========================
# S3 MODULE
# =========================

module "s3" {
  source = "./modules/s3"

  bucket_name  = var.bucket_name
  environment  = var.environment
  project_name = var.project_name
}


# =========================
# EC2 MODULE
# =========================


module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.subnet_ids[0]
  key_name             = var.key_name
  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3_access.name

  aws_region     = var.aws_region
  s3_bucket_name = module.s3.bucket_name
  twenty_port    = var.twenty_port

  environment  = var.environment
  project_name = var.project_name

  depends_on = [
    module.s3
  ]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  tags                 = var.tags
}
