# ============================================================
# iam.tf — Using existing IAM instance profile created by admin
# Do NOT create new IAM role — use shared EC2ECRPullRole
# ============================================================

data "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2ECRPullRole"
}
