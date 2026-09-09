variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix — unique per student"
  type        = string
  default     = "shubham-singh-twenty-crm"
}

variable "ecr_repository_name" {
  description = "ECR repository name — unique per student"
  type        = string
  default     = "shubham-singh-twenty-crm"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "shubhamsingh-task07"
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port Twenty CRM runs on"
  type        = number
  default     = 2020
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "shubham-singh"
  }
}

variable "ami_id" {
  description = "AMI ID provided by admin — Ubuntu based"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}
