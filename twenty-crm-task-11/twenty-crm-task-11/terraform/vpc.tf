############################################
# VPC - use the account's existing default VPC
############################################

# Looks up the default VPC that AWS creates automatically in every region,
# instead of creating a new one.
data "aws_vpc" "default" {
  default = true
}

# All subnets that belong to the default VPC.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
