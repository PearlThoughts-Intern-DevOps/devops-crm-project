variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This task must use us-east-1."
  }
}

variable "ami_id" {
  description = "Approved Amazon Linux AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains(
      [
        "ami-081b0a6eac00b4f53",
        "ami-0b6d9d3d33ba97d99"
      ],
      var.ami_id
    )

    error_message = "AMI must be one of the approved AMIs."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "This task requires t3.small."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-harish"
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "repo_url" {
  description = "PearlThoughts DevOps CRM repository"
  type        = string
  default     = "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
}

variable "repo_branch" {
  description = "Git branch containing the CRM deployment files"
  type        = string
  default     = "harish-task13"
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 3000
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "tags" {
  description = "Common tags for AWS resources"
  type        = map(string)

  default = {
    Project     = "Twenty CRM"
    Task        = "Task 14"
    Owner       = "Harish"
    ManagedBy   = "Terraform"
    Environment = "Internship"
  }
}
