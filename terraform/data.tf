data "aws_vpcs" "default" {
  filter {
    name   = "is-default"
    values = ["true"]
  }
}

locals {
  vpc_id = data.aws_vpcs.default.ids[0]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}
