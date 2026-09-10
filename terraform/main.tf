# Get the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets from the existing default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the existing IAM instance profile for S3 access
data "aws_iam_instance_profile" "ec2_s3_access" {
  name = var.iam_instance_profile_name
}

# Create S3 bucket for Twenty CRM storage
resource "aws_s3_bucket" "twenty_crm" {
  bucket_prefix = var.s3_bucket_prefix
  force_destroy = true

  tags = {
    Name    = var.project_name
    Project = "Twenty CRM"
    Task    = "Task-13"
    Managed = "Terraform"
  }
}

# Enable S3 versioning
resource "aws_s3_bucket_versioning" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Security group for EC2
resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Twenty CRM
  ingress {
    description = "Twenty CRM"
    from_port   = var.host_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  # Use the existing IAM instance profile provided for S3 access
  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3_access.name

  # 20 GB root volume
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # EC2 startup configuration
  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region            = var.aws_region
    s3_bucket_name        = aws_s3_bucket.twenty_crm.bucket
    host_port             = var.host_port
    twenty_container_port = var.twenty_container_port
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "Mujtaba-Task-13-PT"
    Project = "Twenty CRM"
    Task    = "Task-13"
    Managed = "Terraform"
  }
}