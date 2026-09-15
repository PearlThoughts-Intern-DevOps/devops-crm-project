# ============================================================
# main.tf — Root module
# Calls EC2, ECR, S3 modules — Task 14
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Task        = "task-14"
    ManagedBy   = "terraform"
  }
}

# ── VPC ──────────────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-1"
  })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-2"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ── Existing IAM Instance Profile (reuse — do not recreate) ──────────────────
data "aws_iam_instance_profile" "ec2_profile" {
  name = var.iam_instance_profile_name
}

# ── S3 Module ────────────────────────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  bucket_name                    = "${var.project_name}-storage"
  force_destroy                  = var.s3_force_destroy
  versioning_enabled             = true
  sse_algorithm                  = "AES256"
  enable_lifecycle               = true
  noncurrent_version_expiry_days = 30
  tags                           = local.common_tags
}

# ── ECR Module ───────────────────────────────────────────────────────────────
module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.project_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  max_image_count      = 10
  tags                 = local.common_tags
}

# ── EC2 Module ───────────────────────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  project_name         = var.project_name
  vpc_id               = aws_vpc.main.id
  subnet_id            = aws_subnet.public_1.id
  instance_type        = var.instance_type
  key_pair_name        = var.key_pair_name
  iam_instance_profile = data.aws_iam_instance_profile.ec2_profile.name
  volume_size          = var.volume_size
  volume_type          = "gp3"

  ingress_rules = [
    {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Twenty CRM application"
      from_port   = var.app_port
      to_port     = var.app_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region     = var.aws_region
    app_port       = var.app_port
    app_name       = var.project_name
    s3_bucket_name = module.s3.bucket_name
    twenty_image   = var.twenty_image
    encryption_key = var.encryption_key
    app_secret     = var.app_secret
    pg_password    = var.pg_password
  })

  tags = local.common_tags

  depends_on = [
    aws_internet_gateway.main,
    module.s3,
    module.ecr
  ]
}
