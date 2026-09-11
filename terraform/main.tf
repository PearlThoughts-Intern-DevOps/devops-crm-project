module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  project_name = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
}

module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = var.subnet_id
  security_group_id    = var.security_group_id
  iam_instance_profile = var.iam_instance_profile
  project_name         = var.project_name
  aws_region           = var.aws_region
  s3_bucket_name       = module.s3.bucket_name
}