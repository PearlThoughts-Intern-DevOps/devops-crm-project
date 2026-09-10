resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  key_name = var.key_name

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name        = "Twenty-CRM"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
