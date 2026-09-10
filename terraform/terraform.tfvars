aws_region              = "us-east-1"
instance_type           = "t3.small"
ami_id                  = "ami-081b0a6eac00b4f53" # or ami-0b6d9d3d33ba97d99
existing_iam_role_name  = "EC2S3AccessRole"

# Must be a GLOBALLY unique S3 bucket name (lowercase, no underscores)
s3_bucket_name          = "fathima-fiza-twenty-crm-task13"

project_name            = "twenty-crm-task5"
owner                   = "fathima-fiza-c-p"

github_repo_url         = "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
github_branch           = "fiza-fiza-task13" # your Task 13 branch, once created

# Optional: name of an existing EC2 key pair if you want SSH access
key_pair_name         = "task13-key"

# Tighten this to your own IP (e.g. "203.0.113.5/32") instead of open access
ssh_ingress_cidr        = "0.0.0.0/0"
