resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = templatefile(var.user_data_file, {
    twenty_image = var.twenty_image
  })

  user_data_replace_on_change = true

  tags = {
    Name        = var.project_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
