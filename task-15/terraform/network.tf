# Use the default VPC in the region
data "aws_vpc" "default" {
  default = true
}

# All subnets that belong to the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ALB needs at least two subnets in two different AZs.
# Pull details for every default subnet so we can pick distinct AZs.
data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

locals {
  # De-duplicate by AZ so the ALB gets one subnet per AZ (min 2 required)
  az_to_subnet = { for s in data.aws_subnet.default : s.availability_zone => s.id... }
  alb_subnet_ids = [for az, ids in local.az_to_subnet : ids[0]]

  # Single subnet used for the EC2 instance itself
  instance_subnet_id = local.alb_subnet_ids[0]
}