# -----------------------------------------------------------------------------
# Amazon ECR
#
# A private container registry for Twenty CRM Docker images (e.g. the custom
# app extension image built in Task 5), so images can be pushed here instead
# of relying solely on the public twentycrm/twenty-app-dev image on Docker Hub.
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  tags = {
    Name        = var.ecr_repository_name
    Project     = var.project_name
    Environment = var.environment
  }
}
