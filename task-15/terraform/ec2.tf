resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.instance_subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    twenty_app_port = var.twenty_app_port
    server_url      = "http://${aws_lb.twenty_alb.dns_name}"
  })

  tags = {
    Name = "${var.project_name}-instance"
  }
}