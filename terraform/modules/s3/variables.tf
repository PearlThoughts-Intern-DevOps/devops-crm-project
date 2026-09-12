variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled"
  type        = string
  default     = "Enabled"
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use. Valid values: AES256, aws:kms"
  type        = string
  default     = "AES256"
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the S3 bucket"
  type        = map(string)
  default     = {}
}
