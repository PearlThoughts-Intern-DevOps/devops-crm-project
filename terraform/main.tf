# -------------------------------------------------------------------
# Existing/default VPC and subnet
# -------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# -------------------------------------------------------------------
# Provided IAM instance profile
# -------------------------------------------------------------------

data "aws_iam_instance_profile" "ec2_s3_access" {
  name = var.iam_instance_profile
}

# -------------------------------------------------------------------
# ECR module
# -------------------------------------------------------------------

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name

  tags = {
    Name        = var.ecr_repository_name
    Project     = "Twenty CRM"
    Environment = var.environment
    Task        = "Task 14"
  }
}

# -------------------------------------------------------------------
# S3 module
# -------------------------------------------------------------------

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Project     = "Twenty CRM"
    Environment = var.environment
    Task        = "Task 14"
  }
}

# -------------------------------------------------------------------
# EC2 module
# -------------------------------------------------------------------

module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = data.aws_subnets.default.ids[0]
  vpc_id               = data.aws_vpc.default.id
  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3_access.name
  instance_name        = var.instance_name
  admin_ip             = "${var.admin_ip}/32"
  twenty_port          = var.twenty_port
  root_volume_size     = var.root_volume_size

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = module.s3.bucket_name
    twenty_port    = var.twenty_port
    instance_name  = var.instance_name
  })

  tags = {
    Name        = var.instance_name
    Project     = "Twenty CRM"
    Environment = var.environment
    Task        = "Task 14"
  }
}

