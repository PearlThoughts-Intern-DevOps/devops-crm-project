data "aws_subnet" "default" {
  id = var.subnet_id
}

data "aws_ami" "twenty_crm" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

data "aws_security_group" "twenty_crm" {
  id = var.security_group_id
}

data "aws_iam_instance_profile" "ec2_s3" {
  name = var.iam_instance_profile
}

resource "aws_instance" "twenty_crm" {
  ami           = data.aws_ami.twenty_crm.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.default.id

  key_name = var.key_name

  vpc_security_group_ids = [
    data.aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh", {
    s3_bucket_name = var.s3_bucket_name
    aws_region     = var.aws_region
  })

  tags = {
    Name        = "twenty-crm-server"
    Environment = "dev"
    Project     = "twenty-crm"
    Task        = "task-14"
  }
}
