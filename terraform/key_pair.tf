resource "tls_private_key" "crm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "crm_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.crm_key.public_key_openssh
}
