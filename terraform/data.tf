# Existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Existing subnets inside the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Existing IAM instance profile that allows EC2 to pull from ECR
data "aws_iam_instance_profile" "ecr_pull" {
  name = var.iam_instance_profile_name
}