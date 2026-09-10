# An instance profile is required for EC2 to assume an IAM role — this
# does NOT create a new role or policy, it just wraps the EXISTING
# EC2S3AccessRole so it can be attached to the instance.
# An instance profile named EC2S3AccessRole already exists in this
# account with the role attached (verified via `aws iam
# get-instance-profile`). We do NOT create a new one — this IAM user
# lacks iam:CreateInstanceProfile — we just reference the existing
# profile by name directly on the EC2 instance below.

resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    description = "Twenty CRM server"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  iam_instance_profile   = var.existing_iam_role_name
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    github_repo_url = var.github_repo_url
    github_branch   = var.github_branch
    s3_bucket_name  = aws_s3_bucket.twenty_crm_storage.bucket
    aws_region      = var.aws_region
  })

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
    Owner   = var.owner
  }

  # Bucket must exist (with its config) before the instance boots and
  # tries to use it.
  depends_on = [
    aws_s3_bucket_versioning.twenty_crm_storage,
    aws_s3_bucket_server_side_encryption_configuration.twenty_crm_storage,
    aws_s3_bucket_public_access_block.twenty_crm_storage,
  ]
}
