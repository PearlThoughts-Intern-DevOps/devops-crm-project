resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  key_name                    = data.aws_key_pair.selected.key_name
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    tags                  = local.common_tags
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = merge(local.common_tags, {
    Name = "chirag-crm-dev-task-17-ec2"
  })
}
