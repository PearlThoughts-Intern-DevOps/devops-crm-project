# We reuse the AWS account's default VPC and default subnets instead of
# creating a new VPC, per task scope ("use the existing/default AWS VPC
# setup where applicable").

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick a single default subnet to launch the EC2 instance into.
data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}
