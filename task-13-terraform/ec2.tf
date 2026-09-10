resource "aws_security_group" "twenty_crm" {
  name = "twenty-crm-s3-ec2-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port = 2020
    to_port = 2020
    protocol = "tcp"
    cidr_blocks = [var.crm_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-crm-s3-ec2-sg"
  }
}
resource "aws_instance" "twenty_crm" {
  ami = "ami-0b6d9d3d33ba97d99"
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.default.ids[0]
  key_name = var.key_name

  iam_instance_profile = "EC2S3AccessRole"

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    s3_bucket_name = aws_s3_bucket.twenty_crm.bucket
    aws_region = var.aws_region
  })

  tags = {
    Name = var.instance_name
  }

  depends_on = [
    aws_s3_bucket.twenty_crm,
    aws_s3_bucket_public_access_block.twenty_crm,
    aws_s3_bucket_versioning.twenty_crm,
    aws_s3_bucket_server_side_encryption_configuration.twenty_crm
  ]
}
