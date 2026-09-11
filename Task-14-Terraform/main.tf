data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

module "s3" {
  source = "./modules/s3"

  s3_bucket_name = var.s3_bucket_name
}

module "ec2" {
  source = "./modules/ec2"

  aws_region           = var.aws_region
  instance_name        = var.instance_name
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  key_name             = var.key_name
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  iam_instance_profile = var.iam_instance_profile
  docker_image         = var.docker_image

  vpc_id         = data.aws_vpc.default.id
  subnet_id      = data.aws_subnet.selected.id
  s3_bucket_name = module.s3.bucket_name
}
