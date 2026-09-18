data "aws_vpc" "default" {
  default = true
}

data "aws_iam_instance_profile" "ec2_s3" {
  name = "EC2S3AccessRole"
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  vpc_id                    = data.aws_vpc.default.id
  key_name                  = var.key_name
  iam_instance_profile_name = data.aws_iam_instance_profile.ec2_s3.name
  project_name              = var.project_name
  environment               = "production"

  ssh_cidr = "103.171.55.112/32"
  crm_cidr = "0.0.0.0/0"
}

module "s3" {
  source = "./modules/s3"

  bucket_name  = var.bucket_name
  project_name = var.project_name
  environment  = "production"
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
}