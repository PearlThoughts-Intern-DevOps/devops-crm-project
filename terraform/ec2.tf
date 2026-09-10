resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.selected.id

  key_name = var.key_name

  iam_instance_profile = "EC2S3AccessRole"

  user_data = templatefile("${path.module}/user_data.sh", {
    s3_bucket_name = aws_s3_bucket.twenty_storage.bucket
  })

  tags = {
    Name        = "twenty-crm-task13"
    Environment = "Development"
    Project     = "Twenty CRM"
    Task        = "Task-13"
  }
}
