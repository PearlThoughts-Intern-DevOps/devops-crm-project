resource "aws_instance" "crm_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.crm_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ecr_pull.name
  key_name             = aws_key_pair.crm_key.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region   = var.aws_region
    ecr_repo_url = aws_ecr_repository.crm_repo.repository_url
    app_port     = var.app_port
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-server"
  }
}
