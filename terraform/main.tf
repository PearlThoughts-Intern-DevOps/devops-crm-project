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
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_id    = data.aws_vpc.default.id
  subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name        = "twenty-crm-ansible"
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
