variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "Task 13 requires us-east-1."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires t3.small only."
  }
}

variable "ami_id" {
  description = "Approved AMI ID for the EC2 instance"
  type        = string

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99",
    ], var.ami_id)
    error_message = "ami_id must be one of the two approved AMIs for Task 13."
  }
}

variable "existing_iam_role_name" {
  description = "Name of the pre-existing IAM role to attach to the EC2 instance"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave null to skip SSH key)"
  type        = string
  default     = null
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH into the instance. Set to your own IP/32 for safety."
  type        = string
  default     = "0.0.0.0/0"
}

variable "s3_bucket_name" {
  description = "Globally-unique name for the S3 bucket used as Twenty CRM's storage backend"
  type        = string
}

variable "project_name" {
  description = "Short name used in resource tags"
  type        = string
  default     = "twenty-crm-task13"
}

variable "owner" {
  description = "Owner tag value (e.g. your name)"
  type        = string
  default     = "fathima-fiza-c-p"
}

variable "github_repo_url" {
  description = "HTTPS URL of the repo containing the Twenty CRM docker-compose setup"
  type        = string
  default     = "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
}

variable "github_branch" {
  description = "Branch to check out on the EC2 instance"
  type        = string
  default     = "fiza-task5"
}
