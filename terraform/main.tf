module "ec2" {
  source = "./modules/ec2"

  instance_type = var.instance_type
  ami_id        = var.ami_id
  key_name      = var.key_name
  host_port     = var.host_port
  project_name  = var.project_name
}
