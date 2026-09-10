aws_region        = "us-east-1"
project_name      = "shubham-singh-twenty-crm"
ami_id            = "ami-0b6d9d3d33ba97d99"
instance_type     = "t3.small"
key_pair_name     = "shubhamsingh-task07"
allowed_ssh_cidrs = ["0.0.0.0/0"]
app_port          = 2020
s3_bucket_name    = "shubham-singh-twenty-crm-storage"

common_tags = {
  Project     = "twenty-crm"
  Environment = "dev"
  ManagedBy   = "terraform"
  Owner       = "shubham-singh"
  Task        = "task-13"
}
twenty_image = "twentycrm/twenty:v2.35.0"
