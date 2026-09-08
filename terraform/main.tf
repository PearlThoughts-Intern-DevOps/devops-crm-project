resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.selected.id

  tags = {
    Name        = var.ec2_name
    Application = "Twenty CRM"
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Application = "Twenty CRM"
    ManagedBy   = "Terraform"
  }
}