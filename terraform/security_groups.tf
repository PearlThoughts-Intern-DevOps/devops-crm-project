resource "aws_security_group" "twenty" {
  name        = "${var.project_name}-${var.owner}-${var.environment}-sg"
  description = "Security group for Twenty CRM Task 16"
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
    Name        = "${var.project_name}-${var.owner}-${var.environment}-sg"
    Project     = var.project_name
    Owner       = var.owner
    Environment = var.environment
    Task        = "16"
  }
}
