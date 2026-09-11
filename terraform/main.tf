resource "aws_security_group" "twenty_crm" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = "dev"
    Project     = "twenty-crm"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3_access.name

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = aws_s3_bucket.twenty_crm.bucket
    container_port = var.container_port
  })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name        = var.instance_name
    Environment = "dev"
    Project     = "twenty-crm"
    ManagedBy   = "terraform"
  }
}
