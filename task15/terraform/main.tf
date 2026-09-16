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

module "ec2" {
  source = "./modules/ec2"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = data.aws_vpc.default.id
  subnet_id             = data.aws_subnet.selected.id
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  backend_port          = var.backend_port
  root_volume_size      = var.root_volume_size
  alb_security_group_id = aws_security_group.alb.id
}