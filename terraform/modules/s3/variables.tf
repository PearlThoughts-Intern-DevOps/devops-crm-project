variable "bucket_name" {
  description = "Globally unique name of the S3 bucket."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "S3 bucket name must contain between 3 and 63 characters."
  }
}

variable "force_destroy" {
  description = "Whether Terraform may delete a bucket containing objects."
  type        = bool
  default     = false
}

variable "versioning_status" {
  description = "Versioning status for the S3 bucket."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended"], var.versioning_status)
    error_message = "Versioning status must be Enabled or Suspended."
  }
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm for the S3 bucket."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "S3 encryption must be AES256 or aws:kms."
  }
}

variable "bucket_key_enabled" {
  description = "Whether to use an S3 bucket key for KMS encryption."
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether S3 blocks public ACLs."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether S3 blocks public bucket policies."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether S3 ignores public ACLs."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether S3 restricts public bucket policies."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the S3 bucket."
  type        = map(string)
  default     = {}
}