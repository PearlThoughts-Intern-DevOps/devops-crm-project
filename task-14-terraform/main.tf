data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
}

module "ec2" {
  source = "./modules/ec2"

  instance_name        = var.instance_name
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  subnet_id            = data.aws_subnets.default.ids[0]
  vpc_id               = data.aws_vpc.default.id
  key_name             = var.key_name
  ssh_allowed_cidr     = var.ssh_allowed_cidr
  crm_allowed_cidr     = var.crm_allowed_cidr
  iam_instance_profile = var.iam_instance_profile
  ecr_repository_url   = module.ecr.repository_url
  s3_bucket_name       = module.s3.bucket_name
  aws_region           = var.aws_region
}
