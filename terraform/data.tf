# --- Use the existing/default VPC and subnet. Do NOT create a new VPC. ---

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick the first available subnet in the default VPC
data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

data "aws_caller_identity" "current" {}

# NOTE: we intentionally do NOT use `data "aws_iam_role"` to look up
# EC2S3AccessRole here — that requires iam:GetRole permission, which
# this IAM user doesn't have. We already know the role name, so we
# reference it directly by name in aws_iam_instance_profile in ec2.tf
# instead. This only needs permission to create an instance profile
# and iam:PassRole on that specific role, not iam:GetRole.
