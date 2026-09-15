# ============================================================
# modules/s3/variables.tf
# ============================================================

variable "bucket_name" {
  description = "Base name for S3 bucket — random suffix is appended"
  type        = string
}

variable "force_destroy" {
  description = "Allow destroy to delete bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "enable_lifecycle" {
  description = "Enable lifecycle rules on the bucket"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiry_days" {
  description = "Days before noncurrent object versions are permanently deleted"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
