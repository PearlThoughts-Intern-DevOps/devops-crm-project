resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  user_data_replace_on_change = true

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
  -e STORAGE_S3_NAME=${var.s3_bucket_name} \
  -e STORAGE_S3_REGION=${var.aws_region} \
  -v twenty-data:/app/docker-data \
  ${var.twenty_image}

echo "Twenty CRM deployment completed."
EOF_USERDATA

  tags = {
    Name        = var.instance_name
    Project     = var.project
    Task        = var.task
    Environment = var.environment
  }
}
