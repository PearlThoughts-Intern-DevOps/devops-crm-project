# -----------------------------------------------------------------------------
# Amazon ECR
#
# Private container registry for Twenty CRM Docker images.
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  tags = {
    Name        = var.ecr_repository_name
    Project     = var.project_name
    Environment = var.environment
  }
}