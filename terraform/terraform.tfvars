aws_region     = "us-east-1"
project_name   = "twenty-crm"
instance_type  = "t3.small"
vpc_id         = "vpc-0c241509159132524"
subnet_id      = "subnet-078d52bfe579c74f2"
s3_bucket_name = "twenty-crm-storage-tannu-task-13"

ami_id               = "ami-0b6d9d3d33ba97d99"
key_name             = "tannu-task-7-key"
security_group_id    = "sg-0fbbf6b0659d81a04"
iam_instance_profile = "EC2S3AccessRole"

ecr_repository_name = "twenty-crm"