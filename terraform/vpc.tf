# ============================================================
# vpc.tf — Use existing default VPC and subnet
# Task 13: Do NOT create a new VPC
# ============================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
