
module "ec2" {
  source = "./modules/ec2"

  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  security_group_ids          = [aws_security_group.twenty.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.task15.key_name
  root_volume_size            = var.root_volume_size

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    application_port = var.application_port

    docker_compose_sha256  = local.docker_compose_sha256
    docker_compose_version = local.docker_compose_version
    server_url             = "http://${module.alb.dns_name}"
    docker_compose = templatefile("${path.module}/docker-compose.yml.tftpl", {
      application_port = var.application_port

      twenty_version = var.twenty_version
    })
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })


}


module "alb" {
  source = "./modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = sort(data.aws_subnets.default.ids)
  security_group_ids = [aws_security_group.alb.id]
  target_port        = var.application_port
  target_id          = module.ec2.instance_id
  health_check_path  = "/healthz"

  tags = merge(local.common_tags, {
    Purpose = "Twenty CRM public entry point"
  })
}