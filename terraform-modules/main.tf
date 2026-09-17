data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ec2" {
  source        = "./modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repo_name
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}
