variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "task14"
}

variable "purpose" {
  description = "Purpose of the S3 bucket"
  type        = string
  default     = "Terraform module demonstration"
}
