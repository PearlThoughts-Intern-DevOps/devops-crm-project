resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  tags = merge(var.tags, {
    Name = var.ecr_repository_name
  })
}

# Keep the repository tidy: expire untagged images after 14 days.
resource "aws_ecr_lifecycle_policy" "twenty_crm" {
  repository = aws_ecr_repository.twenty_crm.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
