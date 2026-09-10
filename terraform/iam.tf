# ============================================================
# iam.tf — Use existing IAM role assigned by admin
# Task 13: EC2S3AccessRole gives EC2 permission to access S3
# Do NOT create new IAM users, roles, or policies
# ============================================================

data "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "EC2S3AccessRole"
}
