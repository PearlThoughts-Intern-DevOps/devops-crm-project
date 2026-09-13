resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = local.default_subnet_id


  user_data_replace_on_change = true

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_access.name

  user_data = <<EOF_USERDATA
#!/bin/bash
set -eux

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker pull ${var.twenty_image}

docker rm -f twenty 2>/dev/null || true

docker run -d \
  --name twenty \
  --restart unless-stopped \
  -p ${var.app_port}:2020 \
  -e NODE_PORT=2020 \
  -e STORAGE_TYPE=S_3 \
  -e STORAGE_S3_NAME=${aws_s3_bucket.twenty_storage.bucket} \
  -e STORAGE_S3_REGION=${var.aws_region} \
  -v twenty-data:/app/docker-data \
  ${var.twenty_image}

echo "Twenty CRM deployment completed."
EOF_USERDATA

  tags = {
    Name        = var.instance_name
    Project     = "devops-crm-project"
    Task        = "Task-13"
    Environment = "test"
  }

  depends_on = [
    aws_s3_bucket.twenty_storage,
    aws_s3_bucket_public_access_block.twenty_storage,
    aws_s3_bucket_versioning.twenty_storage,
    aws_s3_bucket_server_side_encryption_configuration.twenty_storage
  ]
}
