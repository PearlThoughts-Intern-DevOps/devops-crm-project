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

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

# NOTE: EC2S3AccessRole is referenced by name directly (see main.tf),
# not looked up via `data "aws_iam_role"` — this IAM user lacks
# iam:GetRole permission, and an instance profile with the same name
# already exists in the account with the role attached.
