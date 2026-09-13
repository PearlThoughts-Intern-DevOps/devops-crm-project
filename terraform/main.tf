module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
  project     = var.project
  task        = var.task
  environment = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project         = var.project
  task            = var.task
  environment     = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = local.default_subnet_id
  security_group_ids   = [aws_security_group.twenty_crm.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_access.name
  instance_name        = var.instance_name
  app_port             = var.app_port
  twenty_image         = var.twenty_image
  s3_bucket_name       = module.s3.bucket_name
  aws_region           = var.aws_region
  project              = var.project
  task                 = var.task
  environment          = var.environment
}

moved {
  from = aws_instance.twenty_crm
  to   = module.ec2.aws_instance.twenty_crm
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
