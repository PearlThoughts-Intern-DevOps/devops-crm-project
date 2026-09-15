module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  environment     = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  aws_region            = var.aws_region
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id
  instance_profile_name = var.instance_profile_name
  project_name          = var.project_name
  key_name              = var.key_name
  ssh_cidr              = var.ssh_cidr
  environment           = var.environment

  s3_bucket_name = module.s3.bucket_name
}