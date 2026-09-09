resource "aws_iam_role" "ecr_pull_role" {
  name = "EC2ECRPullRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ecr_pull_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ecr_pull_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecr_pull" {
  name = "EC2ECRPullRole"
  role = aws_iam_role.ecr_pull_role.name
}
