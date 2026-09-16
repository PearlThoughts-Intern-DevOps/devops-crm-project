module "ec2" {
  source = "./modules/ec2"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = local.default_subnet_id
  security_group_ids = [aws_security_group.twenty_crm.id]
  key_name           = var.key_name
  instance_name      = var.instance_name
  app_port           = var.app_port
  twenty_image       = var.twenty_image
  project            = var.project
  task               = var.task
  environment        = var.environment
}

