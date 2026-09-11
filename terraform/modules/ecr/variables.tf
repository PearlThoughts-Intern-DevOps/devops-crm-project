variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable vulnerability scanning when images are pushed"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
