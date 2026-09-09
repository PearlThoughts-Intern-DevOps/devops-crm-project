terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state is used for this task. For team use, replace with an
  # S3 + DynamoDB backend.
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "twenty-crm/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "twenty-crm"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
