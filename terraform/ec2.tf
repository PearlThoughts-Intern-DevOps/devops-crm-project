resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region   = var.aws_region
    ecr_repo_url = aws_ecr_repository.twenty_crm.repository_url
    image_tag    = var.image_tag
    app_port     = var.app_port
    app_name     = var.project_name
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2"
  })
}
