aws_region           = "us-east-1"
ami_id               = "ami-081b0a6eac00b4f53"
instance_type        = "t3.small"
project_name         = "twenty-crm-harish"
iam_instance_profile = "EC2S3AccessRole"
repo_url             = "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
repo_branch          = "harish-task13"
app_port             = 3000
ecr_repository_name  = "twenty-crm"

tags = {
  Project     = "Twenty CRM"
  Task        = "Task 14"
  Owner       = "Harish"
  ManagedBy   = "Terraform"
  Environment = "Internship"
}
