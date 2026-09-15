# --- Use the existing/default VPC. Do NOT create a new VPC. ---

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ALBs require subnets in at least 2 different Availability Zones.
# Fetch details for every default subnet, then pick one per distinct AZ.
data "aws_subnet" "all" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

locals {
  # One subnet ID per distinct AZ, first one found per AZ wins.
  subnet_ids_by_az = {
    for s in data.aws_subnet.all : s.availability_zone => s.id...
  }
  alb_subnet_ids = [for az, ids in local.subnet_ids_by_az : ids[0]]

  # Single subnet for the EC2 instance itself.
  ec2_subnet_id = local.alb_subnet_ids[0]
}
