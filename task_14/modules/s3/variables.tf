variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
