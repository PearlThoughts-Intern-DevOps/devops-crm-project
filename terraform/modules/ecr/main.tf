resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = var.repository_name
    Project = "Twenty CRM"
    Task    = "Task-14"
    Managed = "Terraform"
  }
}
