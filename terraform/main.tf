
module "ec2" {
  source = "./modules/ec2"

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = var.subnet_id
  security_group_id = aws_security_group.ec2.id
  server_url        = "http://${aws_lb.twenty_crm.dns_name}"
  project_name      = var.project_name
  aws_region        = var.aws_region
}