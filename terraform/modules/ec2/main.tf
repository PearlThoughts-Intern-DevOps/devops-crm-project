resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile_name

  user_data = var.user_data

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}
