module "ec2" {
  source = "./modules/ec2"

  aws_region            = var.aws_region
  instance_type         = var.instance_type
  ami_id                = var.ami_id
  key_name              = var.key_name
  twenty_container_port = var.twenty_container_port
  host_port             = var.host_port
  project_name          = var.project_name
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  alb_name          = var.alb_name
  target_group_name = var.target_group_name
  host_port         = var.host_port
  ec2_instance_id   = module.ec2.instance_id
}

resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = var.host_port
  to_port                  = var.host_port
  protocol                 = "tcp"
  security_group_id        = module.ec2.security_group_id
  source_security_group_id = module.alb.alb_security_group_id
}