# ============================================================
# Task 14 - Twenty CRM Terraform Modules
# ============================================================

# ------------------------------------------------------------
# Existing Default VPC
# ------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# ============================================================
# S3 Module
# ============================================================

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
}

# ============================================================
# ECR Module
# ============================================================

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

# ============================================================
# EC2 Module
# ============================================================

module "ec2" {
  source = "./modules/ec2"

  aws_region           = var.aws_region
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  security_group_id    = var.security_group_id
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  s3_bucket_name       = module.s3.bucket_name
}
