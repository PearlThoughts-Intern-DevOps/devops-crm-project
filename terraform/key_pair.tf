resource "tls_private_key" "task17_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "task17_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.task17_key.public_key_openssh
}

resource "local_file" "task17_pem" {
  content         = tls_private_key.task17_key.private_key_pem
  filename        = "${path.root}/${var.project_name}.pem"
  file_permission = "0400"
}