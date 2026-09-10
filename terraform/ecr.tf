resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = var.ecr_repository_name
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
