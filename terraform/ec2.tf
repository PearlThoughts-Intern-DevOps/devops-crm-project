resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {})

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}"
    Project     = var.project_name
    Owner       = var.owner
    Environment = var.environment
    Task        = "16"
  }
}
