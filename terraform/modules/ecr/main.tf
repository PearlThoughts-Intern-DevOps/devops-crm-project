resource "aws_ecr_repository" "crm" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name    = "${var.repository_name}-ecr"
    Service = "Twenty CRM Container Registry"
  })
}
