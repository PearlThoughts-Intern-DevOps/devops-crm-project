# ---------------------------------------------------------
# ECR Repository
# ---------------------------------------------------------

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name        = var.project_name
    Environment = "task-12"
    ManagedBy   = "Terraform"
  }
}


# ---------------------------------------------------------
# IAM Role for EC2
# Allows EC2 to pull the Docker image from ECR
# ---------------------------------------------------------

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = "task-12"
    ManagedBy   = "Terraform"
  }
}


# ---------------------------------------------------------
# ECR Read Permission for EC2
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ---------------------------------------------------------
# EC2 Instance Profile
# ---------------------------------------------------------

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2.name
}


# ---------------------------------------------------------
# EC2 Instance
# ---------------------------------------------------------

resource "aws_instance" "twenty_crm" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Use existing/default VPC subnet
  subnet_id = data.aws_subnets.default.ids[0]

  # Existing EC2 key pair
  key_name = var.key_name

  # Security group created in security.tf
  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  # IAM profile allowing ECR access
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  # EC2 startup configuration
  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region         = var.aws_region
    ecr_repository_url = aws_ecr_repository.twenty_crm.repository_url
    image_tag          = var.image_tag
    container_name     = var.container_name
    app_port           = var.app_port
  })

  user_data_replace_on_change = false

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = var.project_name
    Environment = "task-12"
    ManagedBy   = "Terraform"
  }
}
