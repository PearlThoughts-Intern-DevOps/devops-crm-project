# ============================================================
# modules/ecr/outputs.tf
# ============================================================

output "repository_url" {
  description = "Full ECR repository URL for docker push/pull"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = aws_ecr_repository.this.registry_id
}

output "docker_login_command" {
  description = "Command to authenticate Docker with this ECR registry"
  value       = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}"
}
