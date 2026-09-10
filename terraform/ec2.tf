resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    application_port       = var.application_port
    aws_region             = var.aws_region
    bucket_name            = aws_s3_bucket.twenty_storage.id
    docker_compose_sha256  = local.docker_compose_sha256
    docker_compose_version = local.docker_compose_version
    docker_compose = templatefile("${path.module}/docker-compose.yml.tftpl", {
      application_port = var.application_port
      aws_region       = var.aws_region
      bucket_name      = aws_s3_bucket.twenty_storage.id
      twenty_version   = var.twenty_version
    })
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })

  depends_on = [
    aws_s3_bucket_public_access_block.twenty_storage,
    aws_s3_bucket_server_side_encryption_configuration.twenty_storage,
    aws_s3_bucket_versioning.twenty_storage,
  ]
}
