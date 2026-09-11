resource "aws_ecr_repository" "twenty" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "twenty-crm"
  }
}
