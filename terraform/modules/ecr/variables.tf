variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string

  validation {
    condition     = length(trimspace(var.repository_name)) > 0
    error_message = "ECR repository name cannot be empty."
  }
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether ECR scans images when they are pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type used by the ECR repository."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}

variable "force_delete" {
  description = "Whether Terraform may delete a repository containing images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the ECR repository."
  type        = map(string)
  default     = {}
}