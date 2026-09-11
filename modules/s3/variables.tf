variable "bucket_name" {
  description = "Globally-unique name for the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Whether to enable bucket versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "block_public_access" {
  description = "Whether to block all public access to the bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
