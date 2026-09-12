# -----------------------------------------------------------------------------
# Data Sources: Existing Default VPC and Subnets
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Module: S3 Storage Backend
# -----------------------------------------------------------------------------
module "s3" {
  source = "./modules/s3"

  bucket_name       = var.s3_bucket_name
  force_destroy     = true
  versioning_status = "Enabled"
  sse_algorithm     = "AES256"

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Module: Amazon ECR Private Container Registry
# -----------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Module: Amazon EC2 Instance & Security Group
# -----------------------------------------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  name                        = "${var.project_name}-${var.environment}-ec2"
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_id                      = data.aws_vpc.default.id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  allowed_cidr_blocks         = var.allowed_cidr_blocks
  security_group_name         = "${var.project_name}-${var.environment}-sg"
  associate_public_ip_address = true
  root_volume_size            = 20
  root_volume_type            = "gp3"
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user-data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = module.s3.bucket_name
    docker_image   = var.docker_image
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.s3,
    module.ecr
  ]
}

# -----------------------------------------------------------------------------
# State Migration: Preserve resource addresses from monolithic configuration
# -----------------------------------------------------------------------------
moved {
  from = aws_s3_bucket.twenty_crm_storage
  to   = module.s3.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.twenty_crm_storage
  to   = module.s3.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_versioning.twenty_crm_storage
  to   = module.s3.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.twenty_crm_storage
  to   = module.s3.aws_s3_bucket_server_side_encryption_configuration.this
}

moved {
  from = aws_security_group.twenty_crm
  to   = module.ec2.aws_security_group.this
}

moved {
  from = aws_instance.twenty_crm
  to   = module.ec2.aws_instance.this
}
