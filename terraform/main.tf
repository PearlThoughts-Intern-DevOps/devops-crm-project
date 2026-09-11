# ============================================================
# EXISTING DEFAULT VPC
# ============================================================

data "aws_vpc" "default" {
  default = true
}


# ============================================================
# EXISTING SUBNETS IN DEFAULT VPC
# ============================================================

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ============================================================
# SELECT FIRST EXISTING SUBNET
# ============================================================

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}


# ============================================================
# EXISTING IAM INSTANCE PROFILE
# ============================================================

data "aws_iam_instance_profile" "ec2_s3" {
  name = var.iam_instance_profile
}


# ============================================================
# S3 MODULE
# ============================================================

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  tags         = var.tags
}


# ============================================================
# ECR MODULE
# ============================================================

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  tags            = var.tags
}


# ============================================================
# EC2 MODULE
# ============================================================

module "ec2" {
  source = "./modules/ec2"

  aws_region           = var.aws_region
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  project_name         = var.project_name
  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name
  repo_url             = var.repo_url
  repo_branch          = var.repo_branch
  app_port             = var.app_port
  bucket_name          = module.s3.bucket_name
  vpc_id               = data.aws_vpc.default.id
  subnet_id            = data.aws_subnet.selected.id
  tags                 = var.tags

  depends_on = [module.s3]
}

moved {
  from = random_id.bucket_suffix
  to   = module.s3.random_id.bucket_suffix
}

moved {
  from = aws_s3_bucket.crm_storage
  to   = module.s3.aws_s3_bucket.crm_storage
}

moved {
  from = aws_s3_bucket_versioning.crm_storage
  to   = module.s3.aws_s3_bucket_versioning.crm_storage
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.crm_storage
  to   = module.s3.aws_s3_bucket_server_side_encryption_configuration.crm_storage
}

moved {
  from = aws_s3_bucket_public_access_block.crm_storage
  to   = module.s3.aws_s3_bucket_public_access_block.crm_storage
}

moved {
  from = tls_private_key.crm_key
  to   = module.ec2.tls_private_key.crm_key
}

moved {
  from = aws_key_pair.crm_key
  to   = module.ec2.aws_key_pair.crm_key
}

moved {
  from = local_file.pem_file
  to   = module.ec2.local_file.pem_file
}

moved {
  from = aws_security_group.crm_sg
  to   = module.ec2.aws_security_group.crm_sg
}

moved {
  from = aws_instance.crm_server
  to   = module.ec2.aws_instance.crm_server
}