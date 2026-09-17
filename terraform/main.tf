# Deliberately NO user_data here. In earlier tasks the instance
# bootstrapped itself via a user_data script; this task splits those
# responsibilities -- Terraform provisions bare infrastructure only,
# and Ansible handles every configuration step (packages, Docker,
# directories, env vars, deployment, verification) over SSH afterward.
resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project_name}-${var.owner}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}
