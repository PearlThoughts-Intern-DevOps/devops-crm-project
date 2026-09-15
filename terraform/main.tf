# ============================================================
# EXISTING DEFAULT VPC
# ============================================================

data "aws_vpc" "default" {
  default = true
}


# ============================================================
# EXISTING SUBNETS IN DEFAULT VPC
# ============================================================

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ============================================================
# SELECT FIRST EXISTING SUBNET
# ============================================================

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}



# LOAD BALANCER MODULE

module "alb" {
  source       = "./modules/alb"
  project_name = var.project_name
  vpc_id       = data.aws_vpc.default.id

  subnet_ids = slice(
    data.aws_subnets.default.ids,
    0,
    2
  )

  instance_id = module.ec2.instance_id
  app_port    = var.app_port
  tags        = var.tags
}

# ============================================================
# EC2 MODULE
# ============================================================

module "ec2" {
  source = "./modules/ec2"

  aws_region    = var.aws_region
  ami_id        = var.ami_id
  instance_type = var.instance_type
  project_name  = var.project_name

  repo_url    = var.repo_url
  repo_branch = var.repo_branch
  app_port    = var.app_port

  vpc_id    = data.aws_vpc.default.id
  subnet_id = data.aws_subnet.selected.id
  tags      = var.tags

  alb_security_group_id = module.alb.alb_security_group_id

}


moved {
  from = tls_private_key.crm_key
  to   = module.ec2.tls_private_key.crm_key
}

moved {
  from = aws_key_pair.crm_key
  to   = module.ec2.aws_key_pair.crm_key
}

moved {
  from = local_file.pem_file
  to   = module.ec2.local_file.pem_file
}

moved {
  from = aws_security_group.crm_sg
  to   = module.ec2.aws_security_group.crm_sg
}

moved {
  from = aws_instance.crm_server
  to   = module.ec2.aws_instance.crm_server
}