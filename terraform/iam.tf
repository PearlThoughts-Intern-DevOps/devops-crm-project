# Use the existing EC2 instance profile provided for ECR pulls.
# No IAM role is created by Terraform because this AWS account
# does not grant the intern iam:CreateRole permission.

data "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "EC2ECRPullRole"
}
