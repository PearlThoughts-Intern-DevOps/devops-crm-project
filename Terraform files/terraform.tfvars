aws_region             = "us-east-1"
instance_type          = "t3.small"
ami_id                 = "ami-081b0a6eac00b4f53" # or ami-0b6d9d3d33ba97d99
existing_iam_role_name = "EC2S3AccessRole"

s3_bucket_name      = "fathima-fiza-twenty-crm-task14"
ecr_repository_name = "twenty-crm"

project_name = "twenty-crm"
owner        = "fathima-fiza-c-p"

github_repo_url = "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
github_branch   = "fiza-task5"


# Tighten this to your own IP (e.g. "203.0.113.5/32") instead of open access
ssh_ingress_cidr = "0.0.0.0/0"
