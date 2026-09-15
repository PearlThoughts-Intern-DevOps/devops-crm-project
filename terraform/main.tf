# =========================
# VPC MODULE
# =========================

module "vpc" {
  source = "./modules/vpc"
}


# =========================
# EC2 MODULE
# =========================

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_ids[0]

  key_name = var.key_name

  aws_region = var.aws_region

  twenty_port = var.twenty_port

  environment  = var.environment
  project_name = var.project_name
}


# =========================
# ALB MODULE
# =========================

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids

  target_instance_id = module.ec2.instance_id
}


# =========================
# ALB -> EC2 :2020
# =========================

resource "aws_vpc_security_group_ingress_rule" "crm_from_alb" {
  security_group_id            = module.ec2.security_group_id
  referenced_security_group_id = module.alb.alb_security_group_id

  from_port   = 2020
  to_port     = 2020
  ip_protocol = "tcp"
}
