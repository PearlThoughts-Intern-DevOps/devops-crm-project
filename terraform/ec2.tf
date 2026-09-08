resource "aws_instance" "twenty_crm" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = local.default_subnet_id

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  tags = {
    Name = var.instance_name
  }
}
