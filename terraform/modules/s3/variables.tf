variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name (random suffix appended)"
  type        = string
}

variable "force_destroy" {
  description = "Allow deletion even if bucket contains objects"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}