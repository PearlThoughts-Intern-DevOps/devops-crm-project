terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: uncomment and configure if you want remote state
  # (S3 backend for your OWN Terraform state, separate from the
  # S3 bucket this project creates for Twenty CRM storage).
  #
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "task13/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
