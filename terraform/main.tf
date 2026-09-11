module "s3" {
  source = "./modules/s3"

  bucket_prefix = var.s3_bucket_prefix
  project_name  = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "ec2" {
  source = "./modules/ec2"

  aws_region                = var.aws_region
  instance_type             = var.instance_type
  ami_id                    = var.ami_id
  key_name                  = var.key_name
  twenty_container_port     = var.twenty_container_port
  host_port                 = var.host_port
  project_name              = var.project_name
  iam_instance_profile_name = var.iam_instance_profile_name
  s3_bucket_name            = module.s3.bucket_name
  ecr_repository_url        = module.ecr.repository_url
}