# Use the existing default VPC instead of creating a new VPC.

locals {
  default_vpc_id    = data.aws_vpc.default.id
  default_subnet_id = data.aws_subnets.default.ids[0]
}
