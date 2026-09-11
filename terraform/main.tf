module "s3" {
  source = "./modules/s3"

  bucket_name       = local.bucket_name
  force_destroy     = var.s3_force_destroy
  versioning_status = var.s3_versioning_status
  sse_algorithm     = var.s3_sse_algorithm

  tags = merge(local.common_tags, {
    Name    = local.bucket_name
    Purpose = "Twenty CRM file storage"
  })
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  encryption_type      = var.ecr_encryption_type
  force_delete         = var.ecr_force_delete

  tags = merge(local.common_tags, {
    Name = var.ecr_repository_name
  })
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  security_group_ids          = [aws_security_group.twenty.id]
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile_name   = var.iam_instance_profile_name
  key_name                    = var.key_name
  root_volume_size            = var.root_volume_size

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    application_port       = var.application_port
    aws_region             = var.aws_region
    bucket_name            = module.s3.bucket_name
    docker_compose_sha256  = local.docker_compose_sha256
    docker_compose_version = local.docker_compose_version
    docker_compose = templatefile("${path.module}/docker-compose.yml.tftpl", {
      application_port = var.application_port
      aws_region       = var.aws_region
      bucket_name      = module.s3.bucket_name
      twenty_version   = var.twenty_version
    })
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })

  depends_on = [module.s3]
}