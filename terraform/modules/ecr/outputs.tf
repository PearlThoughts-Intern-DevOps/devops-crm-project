output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.twenty.name
}

output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.twenty.repository_url
}
