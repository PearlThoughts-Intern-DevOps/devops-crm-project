variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
}

variable "owner" {
  description = "Owner tag"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
