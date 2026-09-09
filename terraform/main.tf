# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create ECR repository
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.project_name
  }
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

  # Use the existing IAM instance profile created by Ma'am
  iam_instance_profile = "EC2ECRPullRole"

  # 20 GB root volume
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # EC2 startup configuration
  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region            = var.aws_region
    ecr_repository_url    = aws_ecr_repository.twenty_crm.repository_url
    host_port             = var.host_port
    twenty_container_port = var.twenty_container_port
  })

  user_data_replace_on_change = true

tags = {
  Name = "Mujtaba-Task-12-PT"
}

}