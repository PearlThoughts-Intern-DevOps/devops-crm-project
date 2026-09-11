output "repository_name" {
  description = "Amazon ECR repository name"
  value       = aws_ecr_repository.twenty_crm.name
}

output "repository_url" {
  description = "Amazon ECR repository URL"
  value       = aws_ecr_repository.twenty_crm.repository_url
}

output "repository_arn" {
  description = "Amazon ECR repository ARN"
  value       = aws_ecr_repository.twenty_crm.arn
}
