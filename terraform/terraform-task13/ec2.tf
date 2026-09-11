resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.twenty_crm.id]

  key_name = var.key_name

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name

  lifecycle {
    ignore_changes = [
      user_data,
      tags
    ]
  }

  tags = {
    Name        = "twenty-crm"
    Project     = var.project_name
    Environment = "production"
  }
}
