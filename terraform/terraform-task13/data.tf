data "aws_vpc" "default" {
  default = true
}

data "aws_iam_instance_profile" "ec2_s3" {
  name = "EC2S3AccessRole"
}