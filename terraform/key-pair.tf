resource "aws_key_pair" "task15" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}