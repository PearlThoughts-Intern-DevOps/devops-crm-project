resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.owner}-ecr"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}
