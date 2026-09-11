resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_s3_profile.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region     = var.aws_region
    app_port       = var.app_port
    app_name       = var.project_name
    s3_bucket_name = aws_s3_bucket.twenty_crm_storage.id
    twenty_image   = var.twenty_image
    encryption_key = var.encryption_key
    app_secret     = var.app_secret
    pg_password    = var.pg_password
  })

  depends_on = [aws_s3_bucket.twenty_crm_storage]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2"
  })
}
