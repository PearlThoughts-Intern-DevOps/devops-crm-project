aws_region   = "us-east-1"
project_name = "abhi-task-13"
environment  = "task-13"

vpc_id    = "vpc-0c241509159132524"
subnet_id = "subnet-078d52bfe579c74f2"

ami_id        = "ami-081b0a6eac00b4f53"
instance_type = "t3.small"
key_name      = "abhi-task7"

iam_instance_profile_name = "EC2S3AccessRole"

s3_bucket_name = "abhi-s3-task-13"

twenty_image = "twentycrm/twenty:v2.35.0"

ecr_repository_name = "twenty-crm"
