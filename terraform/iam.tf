resource "aws_iam_role" "ec2_s3_access" {
  name = "EC2S3AccessRole"

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
    Name        = "EC2S3AccessRole"
    Project     = "devops-crm-project"
    Task        = "Task-13"
    Environment = "test"
  }
}

resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "EC2S3AccessRole"
  role = aws_iam_role.ec2_s3_access.name

  tags = {
    Name    = "EC2S3AccessRole"
    Project = "devops-crm-project"
    Task    = "Task-13"
  }
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
