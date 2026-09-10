module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  ami_id             = var.ec2_ami_id
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.subnet_id
  aws_region = var.aws_region
  iam_instance_profile = "EC2ECRPullRole"
  ecr_repository_url = module.ecr.repository_url
  docker_image_tag   = "latest"
  application_port   = var.twenty_crm_port
}

module "ecr" {
  source = "./modules/ecr"

  project_name    = var.project_name
  repository_name = var.ecr_repository_name
}
