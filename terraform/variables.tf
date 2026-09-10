# variable "instance_name" {
#   description = "Value of the EC2 instance's Name tag."
#   type        = string
#   default     = "learn-terraform"
# }

# variable "instance_type" {
#   description = "The EC2 instance's type."
#   type        = string
#   default     = "t3.micro"
# }


variable "aws_region" {
  description = "AWS region"
  type        = string
  #   default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  #   default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  #   default     = "twenty-crm"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  #   default     = "t3.small"
}

# variable "ami_id" {
#   description = "AMI ID for the EC2 instance"
#   type        = string
# }

# variable "subnet_id" {
#   description = "Subnet ID for the EC2 instance"
#   type        = string
# }

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "docker_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}