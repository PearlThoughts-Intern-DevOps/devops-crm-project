variable "project_name" {
  description = "Project name used for the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags for S3 resources"
  type        = map(string)
}
