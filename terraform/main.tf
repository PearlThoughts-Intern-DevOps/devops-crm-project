resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Existing mentor-provided instance profile.
  # No IAM role, user, or policy is created by Terraform.
  iam_instance_profile = data.aws_iam_instance_profile.s3_access.name

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region  = var.aws_region
    bucket_name = aws_s3_bucket.twenty_storage.bucket
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}
