# -----------------------------------------------------------------------------
# VPC
#
# Per task requirements, this uses the existing/default AWS VPC rather than
# creating a new one. Data sources look up the default VPC and its subnets
# so the EC2 instance can be launched into existing network infrastructure
# without Terraform needing to manage VPC/subnet/routing resources.
# -----------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick the first available subnet in the default VPC for the EC2 instance.
data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}
