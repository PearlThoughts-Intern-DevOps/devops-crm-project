module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  owner           = var.owner
  environment     = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                     = var.ami_id
  instance_type              = var.instance_type
  subnet_id                  = data.aws_subnets.default_vpc.ids[0]
  security_group_id          = data.aws_security_group.default.id
  key_name                   = var.key_name
  iam_instance_profile_name  = data.aws_iam_instance_profile.s3_access.name
  project_name               = var.project_name
  owner                      = var.owner
  environment                = var.environment

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region  = var.aws_region
    bucket_name = module.s3.bucket_name
  })
}

# Preserve the existing Terraform state addresses during the module refactor.
moved {
  from = aws_instance.twenty
  to   = module.ec2.aws_instance.this
}

moved {
  from = aws_s3_bucket.twenty_storage
  to   = module.s3.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.twenty_storage
  to   = module.s3.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_versioning.twenty_storage
  to   = module.s3.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.twenty_storage
  to   = module.s3.aws_s3_bucket_server_side_encryption_configuration.this
}
